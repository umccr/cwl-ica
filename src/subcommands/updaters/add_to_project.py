#!/usr/bin/env python3

"""
Add a tool / workflow to a project yaml

Determine if production or not

If production, workflow is created, version is not created.

If non-production, workflow is created, version is created in project.yaml but not synced
"""

from classes.command import Command
from ruamel import yaml
from utils.repo import read_yaml, get_project_yaml_path
from utils.logging import get_logger
from classes.project import Project
from classes.project_production import ProductionProject
from utils.yaml import dump_yaml
from utils.errors import CheckArgumentError, ItemNotFoundError, ItemVersionNotFoundError, WorkflowVersionExistsError

logger = get_logger()


class AddToProject(Command):
    """
    Add an item to a project

    This calls very similar functions to initialiser but assumes that item already exists in 'item.yaml'
    """

    def __init__(self, command_argv, item_dir=None, item_yaml_path=None, item_type_key=None, item_type=None, item_suffix="cwl"):
        # Call super class
        super(AddToProject, self).__init__(command_argv)

        # CWL Object has a suite of basic uses such as the
        self.cwl_obj = None
        self.md5sum = None  # Part of the cwl_obj but different calculation for cwl-schema objects
        # We will have a name and a version for this tool/expression/workflow etc.
        self.name = None
        self.version = None
        self.cwl_file_path = None
        # Also assign the type in the subclass so this can be referenced in the call
        self.item_dir = item_dir
        self.item_yaml_path = item_yaml_path
        self.item_type = item_type  # tool / workflow
        self.item_type_key = item_type_key  # tools / workflows etc
        self.item_suffix = item_suffix
        # We will also store the item list yaml for re-writing
        self.items_list = None
        self.item = None
        self.item_version = None
        # Project
        self.project = None  # Project object

        # Check help
        self.check_length(command_argv)

        # Check if help has been called
        if self.args["help"]:
            self._help()

        # Confirm 'required' arguments are present and valid
        try:
            self.check_args()
        except CheckArgumentError:
            self._help(fail=True)

        # Steps in subclass
        # Check args
        # Get args
        # Read in tool.yaml / workflow.yaml / etc as object
        self.read_item_yaml()

        # Get item -> make sure item is not none
        self.item = self.get_item_from_item_list()

        if self.item is None:
            logger.error(f"Could not find item with name \"{self.name}\" in \"{self.get_item_yaml()}\"")
            raise ItemNotFoundError

        # Get version -> Check match -> Make sure version is not none
        self.item_version = self.get_item_version_from_item()

        if self.item_version is None:
            logger.error(f"Could not find item version in item \"{self.name}\" with version \"{self.version}\"")
            raise ItemVersionNotFoundError

        # Check item version is not in project
        for ica_workflow in self.get_project_ica_item_list():
            if ica_workflow.name == self.name:
                for version in ica_workflow.versions:
                    if version.name == self.version:
                        logger.error("This workflow already exists in this project")
                        raise WorkflowVersionExistsError

    def __call__(self):
        """
        Add the tool / workflow to the project
        :return:
        """
        # Call the item version to set the cwl object
        self.item_version()
        self.cwl_obj = self.item_version.cwl_obj

        # Add item to project
        logger.info(f"Adding {self.item_type} \"{self.name}/{self.version}\" to project \"{self.project.project_name}\"")
        self.project.add_item_to_project(self.item_type_key, self.cwl_obj,
                                         access_token=self.project.get_project_token(),
                                         categories=self.item.categories)

        # Now we need to write the projects yaml with the new workflow / version added
        logger.info("Updating project yaml")
        self.write_projects_yaml()

    # Get the item
    def get_item_yaml(self):
        """
        returns tool.yaml / workflow.yaml, global redefined in subclass
        :return:
        """
        return self.item_yaml_path

    def read_item_yaml(self):
        """
        Read an item.yaml like tool.yaml or workflow.yaml
        :return:
        """
        with open(self.get_item_yaml(), 'r') as item_yaml_h:
            self.items_list = yaml.main.round_trip_load(item_yaml_h)[self.item_type_key]

    def get_item_from_item_list(self):
        """
        Item will contain a name / version. Iterate through item list and then call
        the get_item_obj_from_dict method that is unique to this item class (and implemented in the subclass)
        :return:
        """
        for item in self.items_list:
            if item.get("name", None) == self.name:
                return self.get_item_obj_from_dict(item)
        else:
            return None

    # Get the item version
    def get_item_version_from_item(self):
        """
        Iterate through the versions of the item and return the version object that matches.
        Since the version is a sub-object of the item object, any updates to item_version will update item
        :return:
        """
        for version in self.item.versions:
            if version.name == self.version:
                return version
        return None

    def set_name_and_version_from_file_path(self):
        """
        Sets the name and version attributes from the path attribute
        :return:
        """
        self.name, self.version = self.cwl_file_path.absolute().relative_to(self.item_dir).stem.split("__")

    # Methods implemented in subclass
    @staticmethod
    def get_item_obj_from_dict(item):
        """
        Get item as an object (ItemTool etc.) from an ordered dict.
        Implemented in subclass as subclass defined object type
        :param item:
        :return:
        """
        raise NotImplementedError

    def get_project_ica_item_list(self):
        """
        Get the project ica item list through projects' either ica_tools_list or ica_workflows_list
        :return:
        """
        raise NotImplementedError

    def check_args(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError

    def check_project(self, project_arg):
        """
        Checks project attribute is in projects yaml
        :return:
        """

        projects_list = read_yaml(get_project_yaml_path())["projects"]

        for project_dict in projects_list:
            # Not the right project, skip it
            if not project_dict.get("project_name", None) == project_arg:
                continue

            # Check production
            if project_dict.get("production", False):
                self.project = ProductionProject.from_dict(project_dict)
            else:
                self.project = Project.from_dict(project_dict)

            # Got project, break loop
            break

        else:
            logger.error(f"Could not find project \"{self.project}\" in project.yaml. "
                         f"Please first run 'cwl-ica project-init' for this project")

    def write_projects_yaml(self):
        """
        Re-write projects dictionary
        :return:
        """

        all_projects_list = read_yaml(get_project_yaml_path())['projects']
        new_all_projects_list = all_projects_list.copy()

        for i, project_dict in enumerate(all_projects_list):
            if not project_dict.get("project_name") == self.project.project_name:
                continue
            new_all_projects_list[i] = self.project.to_dict()

        with open(get_project_yaml_path(), "w") as project_h:
            dump_yaml({"projects": new_all_projects_list}, project_h)
