#!/usr/bin/env python3

"""
Call is subclass dependent
For all this means creating the item in the .yaml file 
For tool and workflow this comprises writing the object to each of the project objects
"""

from classes.command import Command
from classes.project import Project
from classes.project_production import ProductionProject
from utils.logging import get_logger
from ruamel import yaml
from utils.repo import get_project_yaml_path, read_yaml, get_tenant_yaml_path
import os
from utils.errors import CheckArgumentError, ItemVersionExistsError, ItemDirectoryNotFoundError
from pathlib import Path
from utils.yaml import dump_yaml

logger = get_logger()

# tool_dir / name / version / name__version etc.


class Initialiser(Command):
    """
    The initialiser is based over three parts
    * Initialise cwl object and import it / validate it -> most components defined in the subclass
    * Import the project yaml object, check projects are registered -> method created here, called in subclass
    * Import the categories yaml object, check categories are registered -> method created here, called in subclass

    The call is then defined in this class
    """

    def __init__(self, command_argv, update_projects=True, item_dir=None, item_yaml_path=None, item_type_key=None, item_type=None, item_suffix="cwl"):
        # Call super class
        super(Initialiser, self).__init__(command_argv)

        # CWL Object has a suite of basic uses such as the
        self.cwl_obj = None
        self.md5sum = None  # Part of the cwl_obj but different calculation for cwl-schema objects
        self.update_projects = update_projects
        # We will have a name and a version for this tool/expression/workflow etc.
        self.name = None
        self.version = None
        self.cwl_file_path = None
        # Also assign the type in the subclass so this can be referenced in the call
        self.item_dir = item_dir
        self.item_type_key = item_type_key  # tools / workflows etc
        self.item_type = item_type  # tool / workflow
        self.item_yaml_path = item_yaml_path
        self.item_suffix = item_suffix
        # We will also store the item list yaml for re-writing
        self.items_list = None
        self.item = None
        self.item_version = None
        # Tenants
        self.tenants_list = None  # Str list of tenants
        # Project
        self.projects = []  # List of project objects
        self.project_list = None  # Str list of projects
        # Categories
        self.categories = []  # List of category objects
        self.categories_list = None  # str list of categories

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
        if not Path(self.item_yaml_path).is_file():
            self.items_list = []
        else:
            self.items_list = read_yaml(self.item_yaml_path)[self.item_type_key]
        # Get item -> Check version is not the same
        self.item = self.get_item_from_item_list()

        if self.item is None:
            self.item = self.create_item_object()
            self.item_version = self.item.versions[0]
            self.add_item_to_items_list()
        else:
            self.check_unique_version()
            self.item_version = self.create_item_version_object()
            # We need to create the item version
            self.add_item_version_to_item()
            # Extend categories list with existing categories
            if self.item_type in ["tool", "workflow"]:
                self.categories = list(set(self.categories + self.item.categories))

        # Make sure that this workflow doesn't already exist
        # Add in the item yaml to the item yaml dict
        # Store this value in the obj s.t we can re-write item_yaml list once we're done.
        # Validate CWL object
        # Collect md5sum of CWL Object
        # Then if projects is defined, import the project dictionary
        if self.update_projects and self.project_list is not None:
            self.set_projects()

        # Update cwl_obj and md5sum attributes
        self.cwl_obj = self.item_version.cwl_obj
        self.md5sum = self.item_version.md5sum

    def __call__(self):
        """
        Call is generic but not all functions called in here are, does the three main steps
        * Writes the item to the item yaml
            * tool.yaml, expression.yaml, workflow.yaml and schema.yaml all follow the same conventions
              with the exception of categories in tools and workflows
        * Adds workflow/tool to project -> for production projects this means adding the version with
          the __GIT_COMMIT_ID__ extension in the id.
            * For expressions and schemas this component is overwritten / skipped and just the item yaml is written out
        :return:
        """
        # Write out the item yaml
        logger.info(f"Updating \"{self.get_item_yaml()}\"")
        self.write_item_yaml()

        # Write out projects
        if not len(self.projects) == 0:
            logger.info(f"Adding \"{self.item_type}\" to projects")
            self.add_item_to_projects()
            logger.info(f"Updating \"{get_project_yaml_path()}\"")
            self.write_projects_yaml()

    # Methods implemented in subclass
    def check_args(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError

    def create_item_object(self):
        """
        This creates the item object along with the first version of the item
        This also calls create_item_version and assigns item_version attribute
        :return:
        """
        raise NotImplementedError

    def create_item_version_object(self):
        """
        Create the item version for self.item and assign to item_version
        :return:
        """
        raise NotImplementedError

    def set_cwl_obj(self):
        """
        Get the CWL workflow, assign to cwl_obj, implemented in subclass
        :return:
        """
        self.cwl_obj = self.item_version.cwl_obj
        self.md5sum = self.item_version.md5sum

    @staticmethod
    def get_item_obj_from_dict(item):
        """
        Get item as an object (ItemTool etc.) from an ordered dict.
        :param item:
        :return:
        """
        raise NotImplementedError

    def get_item_yaml(self):
        """
        returns tool.yaml / workflow.yaml, global redefined in subclass
        :return:
        """
        return self.item_yaml_path

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

    def check_cwl_path(self, cwl_path):
        """
        Check that the cwl path exists under item_dir
        :return:
        """
        # Check path is relative to item path
        if not cwl_path.absolute().relative_to(self.item_dir):
            logger.error(f"Expected item of type \"{self.item_type}\" to be in \"{self.item_dir}\"")
            raise ItemDirectoryNotFoundError

    def check_unique_version(self):
        """
        Check there's no overlapping unique version
        :return:
        """
        for version in self.item.versions:
            if version.name == self.version:
                logger.error(f"Version already exists in \"{self.item_type}.yaml\"")
                raise ItemVersionExistsError

    # Common methods (set_tenants_list and set_projects_list used only in tool-init and workflow-init)
    def set_tenants_list(self):
        """
        Gets tenants argument from --tenants
        :return:
        """
        # Pull in tenants list
        tenants_list = read_yaml(get_tenant_yaml_path())['tenants']

        # Get tenants arg
        tenants_arg = self.args.get("--tenants", None)

        # Check if tenants list is defined
        if tenants_arg is None:
            default_tenant_env = os.environ.get("CWL_ICA_DEFAULT_TENANT", None)
            if default_tenant_env is None:
                self.tenants_list = [tenant_dict.get("tenant_id", None) for tenant_dict in tenants_list]
            else:
                self.tenants_list = [tenant_dict.get("tenant_id", None) for tenant_dict in tenants_list
                                     if tenant_dict.get("tenant_name", None) == default_tenant_env]
        elif tenants_arg == "all":
            self.tenants_list = [tenant_dict.get("tenant_id", None) for tenant_dict in tenants_list]
        else:
            self.tenants_list = [tenant_dict.get("tenant_id", None) for tenant_dict in tenants_list
                                 if tenant_dict.get("tenant_name", None) in ','.split(tenants_arg)]

    def set_projects_list(self):
        """
        Sets the projects list from the --projects attribute
        :return:
        """
        # Set projects
        projects_arg = self.args.get("--projects", None)
        # Read project yaml
        projects_list = read_yaml(get_project_yaml_path())["projects"]

        # Check if projects defined
        if projects_arg is not None and not projects_arg == "all":
            # Split project by comma separated values
            self.project_list = projects_arg.split(",")
        elif projects_arg == "all":
            # Iterate through all projects
            for project_dict in projects_list:
                # Check tenants
                if project_dict.get("tenant_id", None) not in self.tenants_list:
                    continue
                self.project_list.append(project_dict.get("project_name"))
        elif os.environ.get("CWL_ICA_DEFAULT_PROJECT", None) is not None:
            self.project_list = [os.environ.get("CWL_ICA_DEFAULT_PROJECT")]
        else:
            # Split project by comma separated values
            self.project_list = []

    def set_name_and_version_from_file_path(self):
        """
        Sets the name and version attributes from the path attribute
        :return:
        """
        self.name, self.version = self.cwl_file_path.resolve().stem.split("__")

    def set_categories_list(self):
        """
        Sets the list of categories
        :return:
        """
        categories_arg = self.args.get("--categories")
        if categories_arg is not None:
            # Categories
            self.categories_list = categories_arg.split(",")  # str list of categories
        else:
            self.categories_list = []

    def set_projects(self):
        """
        Sets project objects based on our projects str list
        :return:
        """

        all_projects_list = read_yaml(get_project_yaml_path())['projects']

        for project_name_l in self.project_list:
            for project_dict in all_projects_list:
                project_name_d = project_dict.get("project_name", None)
                if project_name_d == project_name_l:
                    if project_dict.get("production", False):
                        self.projects.append(ProductionProject.from_dict(project_dict))
                    else:
                        self.projects.append(Project.from_dict(project_dict))
                    break
            else:
                # We didn't find a match for this project in the projects list
                logger.warning(f"Could not find \"{project_name_l}\" in project.yaml. Skipping project")

    def read_item_yaml(self):
        """
        Read an item.yaml like tool.yaml or workflow.yaml
        :return:
        """
        with open(self.get_item_yaml(), 'r') as item_yaml_h:
            self.items_list = yaml.main.round_trip_load(item_yaml_h)[self.item_type_key]

    def add_item_to_items_list(self):
        """
        Add the cwl obj item yaml to workflow.yaml or tool.yaml etc
        :return:
        """
        self.items_list.append(self.item.to_dict())

    def add_item_version_to_item(self):
        """
        Add an item version to an item
        :return:
        """
        self.item.versions.append(self.item_version.to_dict())

    def add_item_to_projects(self):
        """
        Adds the cwl obj item yaml to the projects dict
        :return:
        """

        # Carefully editing a list of objects in place...
        for project in self.projects:
            project_access_token = project.get_project_token()
            # Project is a project object
            project.add_item_to_project(self.item_type_key, self.cwl_obj,
                                        access_token=project_access_token, categories=self.categories_list)

    def write_projects_yaml(self):
        """
        Re-write projects dictionary
        :return:
        """

        all_projects_list = read_yaml(get_project_yaml_path())['projects']
        new_all_projects_list = all_projects_list.copy()

        for i, project_dict in enumerate(all_projects_list):
            if project_dict.get("project_name") not in [project.project_name for project in self.projects]:
                continue
            for j, project_obj in enumerate(self.projects):
                if not project_dict.get("project_name") == project_obj.project_name:
                    continue
                # Update the project object with the new project dict
                new_all_projects_list[i] = project_obj.to_dict()

        with open(get_project_yaml_path(), "w") as project_h:
            dump_yaml({"projects": new_all_projects_list}, project_h)

    def write_item_yaml(self):
        """
        Mostly static method
        :return:
        """

        # Check if we have any tools registered
        if not Path(self.get_item_yaml()).is_file():
            all_items_list = []
        else:
            all_items_list = read_yaml(self.get_item_yaml())[self.item_type_key]

        new_all_items_list = [item.copy() for item in all_items_list]

        for i, item in enumerate(all_items_list):
            if item.get("name") == self.name:
                new_all_items_list[i] = self.item.to_dict()
                break
        else:
            new_all_items_list.append(self.item.to_dict())

        with open(self.get_item_yaml(), "w") as item_yaml_h:
            dump_yaml({self.item_type_key: new_all_items_list}, item_yaml_h)
