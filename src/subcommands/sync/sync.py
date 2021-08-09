#!/usr/bin/env python

"""
Parent sync command.
This will update the md5sum attribute in a tool.yaml / workflow.yaml

First we validate the object, then we compare this to the md5sum of the project.
For each project specified, we compare the md5sum of the version against the updated md5sum.
"""

from classes.command import Command
from classes.project import Project
from classes.project_production import ProductionProject
from utils.repo import get_tenant_yaml_path, read_yaml, get_project_yaml_path
import os
from ruamel import yaml
from utils.logging import get_logger
from utils.errors import ItemNotFoundError, ItemVersionNotFoundError, CheckArgumentError
from utils.yaml import dump_yaml
from utils.miscell import get_name_version_tuple_from_cwl_file_path

logger = get_logger()


class Sync(Command):
    """
    The sync command is a parent class, but most definitions are found in here.
    First we check args. Then get the items list, item object and item version object.
    We check which projects hold this version, if --all is used but some projects do not have this
    workflow version, then a warning is thrown. Projects that have not had the x-init do not apply.
    Any project that is a production project is also skipped.
    We then get the item and item version objects and then re-write out the project yaml based on the new workflow version and id
    """

    def __init__(self, command_argv, update_projects=True, item_dir=None, item_yaml_path=None, item_type_key=None, item_type=None, item_suffix="cwl"):
        """
        After checking args
        :param command_argv:
        """
        # Get args
        super(Sync, self).__init__(command_argv)

        # CWL Object has a suite of basic uses such as the
        self.cwl_obj = None
        self.cwl_packed_obj = None
        self.md5sum = None  # Part of the cwl_obj but different calculation for cwl-schema objects
        # We will have a name and a version for this tool/expression/workflow etc.
        self.name = None
        self.version = None
        self.cwl_file_path = None
        # Also assign the type in the subclass so this can be referenced in the call
        self.item_dir = item_dir
        self.item_type = item_type  # tool / workflow
        self.item_type_key = item_type_key  # tools / workflows etc
        self.item_yaml_path = item_yaml_path
        self.item_suffix = item_suffix
        # We will also store the item list yaml for re-writing
        self.items_list = None    # List of items
        self.item = None          # Item object
        self.item_version = None  # ItemVersion object
        # Tenants
        self.tenants_list = None  # Str list of tenants
        # Project
        self.projects = None  # List of project objects
        self.project_list = None  # Str list of projects
        self.update_projects = update_projects  # True for tools and workflows, false for expressions and schemas
        self.force = False

        # Check args
        try:
            self.check_args()
        except CheckArgumentError:
            self._help(fail=True)

        # Read in tool.yaml / workflow.yaml / etc as object
        self.read_item_yaml()

        # Get item -> Check match
        self.item = self.get_item_from_item_list()

        if self.item is None:
            logger.error(f"Could not find item with name \"{self.name}\" in \"{self.get_item_yaml()}\"")
            raise ItemNotFoundError

        # Get version -> Check match
        self.item_version = self.get_item_version_from_item()

        if self.item_version is None:
            logger.error(f"Could not find item version in item \"{self.name}\" with version \"{self.version}\"")
            raise ItemVersionNotFoundError

        # Get cwl object from item version
        self.cwl_obj = self.get_cwl_obj()

        # Now get the packed object for the definition
        self.cwl_packed_obj = self.get_cwl_packed_obj()

        # Assign the md5sum of the cwl_obj to the sync object attribute
        self.md5sum = self.cwl_obj.md5sum

    def __call__(self):
        """
        Here we compare the item version and the ICA workflow version
        :return:
        """
        # Update item with new md5sum for this workflow
        logger.info(f"Getting new \"{self.item_type}\" version CWL object")
        self.update_item_version()

        # Write out new item yaml with the updated md5sum for this tool
        logger.info(f"Updating \"{self.item_type}\" yaml.")
        self.write_item_yaml()

        # Compare item md5sum with the preexisting ica workflow md5sum
        if self.update_projects:  # Only for tools and versions
            logger.info("Updating project definitions on ICA")
            for project in self.projects:
                logger.info(f"Updating project \"{project.project_name}\"")
                # Get the access token
                access_token = project.get_project_token()
                # Get workflow
                ica_workflow = self.get_ica_workflow(project)
                # Get workflow version
                ica_workflow_version = self.get_ica_workflow_version(ica_workflow)
                # Now sync the item version with the project
                project.sync_item_version_with_project(ica_workflow_version, self.md5sum, self.cwl_packed_obj, force=self.force)

            # Update project yaml
            logger.info("Updating project yaml")
            self.write_projects_yaml()

    def filter_projects(self):
        """
        Called by check_args in subclass - get relevant projects by
        1. Removing all production projects from the list
        2. Removing any projects where the item or item version does not exist
        :return:
        """
        new_projects = []

        for project in self.projects:
            if project.is_production:
                logger.info(f"Project \"{project.project_name}\" is a production project. "
                            f"This workflow will be synced on a merge to the main branch.  Skipping for now")
                # Skip this
                continue
            for item in self.get_project_ica_item_list(project):
                if item.name == self.name:
                    for version in item.versions:
                        if version.name == self.version:
                            new_projects.append(project)
                            # We've had a version match
                            break
                    else:
                        logger.warning(f"Omitting project \"{project.project_name}\". "
                                       f"It does not contain the {self.item_type} version \"{self.version}\"")
                    # We've had a name match
                    break
            else:
                logger.warning(f"Omitting project \"{project.project_name}\". "
                               f"It does not contain the {self.item_type} \"{self.name}\"")

        # Check length of projects
        if len(new_projects) == 0:
            # Oh dear, none of the projects we assigned were able to be synced
            logger.error("No projects can be synced")
            raise CheckArgumentError

        # Reassign the projects as the filtered list of projects
        self.projects = new_projects

        # Reassign projects_list just in case it's used elsewhere
        new_projects_list = []
        for project in self.projects:
            new_projects_list.append(project.project_name)
        self.project_list = new_projects_list

    # Set name and version from file path
    def set_name_and_version_from_file_path(self):
        """
        Sets the name and version attributes from the path attribute
        :return:
        """
        self.name, self.version = get_name_version_tuple_from_cwl_file_path(self.cwl_file_path, items_dir=self.item_dir)

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

    # Get the ICA workflow
    def get_ica_workflow(self, project_object):
        """
        Get the ica workflow attribute for a given project object
        This uses the sync object name attribute to connect with the workflow of the same name under item_key
        for a given project. This function is used to filter out projects that do not have this item.
        A warning is thrown if a project is selected that does NOT have this item.
        This does not include production projects that are already omitted
        :return:
        """
        for ica_workflow in self.get_project_ica_item_list(project_object):
            if ica_workflow.name == self.name:
                return ica_workflow

    # Get the ICA workflow version
    def get_ica_workflow_version(self, ica_workflow):
        """
        Get the ica worklfow version attribute for a given project object
        This uses the sync object version attribute to connect with the workflow version of the same name under item_key
        for a given project. This function is used to filter out projects that do not have this item version.
        A warning is thrown if a project is selected that does NOT have this item version
        This does not include production projects that are already omitted
        For production projects, we will need to extend the for-loop to
        ica_workflow_version_name to also end with ("__GIT_COMMIT_ID__")
        :return:
        """
        for version in ica_workflow.versions:
            if version.name == self.version:
                return version

    # Update item in item yaml
    def update_item_version(self):
        """
        :return:
        """
        self.item_version.md5sum = self.cwl_obj.md5sum

    # Patch ICA workflow version
    def update_ica_workflow_version(self, workflow_version_obj, access_token):
        """
        Runs a PATCH request against the ica workflow version object.
        :return:
        """
        workflow_version_obj.sync_workflow_version(self.cwl_packed_obj, access_token)

    # Classes implemented in subclass
    def check_args(self):
        """
        Defined in subclass, assigns name, version and cwl_file_path, then assign tenants and projects.
        :return:
        """
        raise NotImplementedError

    def get_cwl_obj(self):
        """
        Defined in the subclass as subclass knows the cwl type from the item_version object
        :return:
        """
        # Create the cwl object
        self.item_version.set_cwl_object()
        return self.item_version.cwl_obj

    @staticmethod
    def get_project_ica_item_list(project):
        """
        Implemented in subclass
        Will return either the tools attribute or the workflows attribute of the project
        :return:
        """
        raise NotImplementedError

    @staticmethod
    def get_item_obj_from_dict(item):
        """
        Get item as an object (ItemTool etc.) from an ordered dict.
        Implemented in subclass as subclass defined object type
        :param item:
        :return:
        """
        raise NotImplementedError

    def get_cwl_packed_obj(self):
        """
        Bit hacky and poor naming convention, returns the packed object which should be part of the cwl_obj
        :return:
        """
        return self.cwl_obj.cwl_packed_obj

    def set_tenants_list(self):
        """
        Gets tenants argument from --tenants
        :return:
        """
        # Pull in tenants list
        tenants_list = read_yaml(get_tenant_yaml_path())

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
        # Assign the project_list first
        if projects_arg is None and os.environ.get("CWL_ICA_DEFAULT_PROJECT", None) is None:
            self.project_list = []
        elif projects_arg == "all":
            # Iterate through all projects
            for project_dict in projects_list:
                # Check tenants
                if project_dict.get("tenant_id", None) not in self.tenants_list:
                    continue
                self.project_list.append(project_dict.get("project_name"))
        elif projects_arg is None:
            self.project_list = []
        else:
            # Split project by comma separated values
            self.project_list = projects_arg.split(",")

        # Read in the appropriate project objects
        self.projects = []
        for project_dict in projects_list:
            # Skip projects we're not working on
            if project_dict.get("project_name") not in self.project_list:
                continue

            if project_dict.get("production"):
                self.projects.append(ProductionProject.from_dict(project_dict))
            else:
                self.projects.append(Project.from_dict(project_dict))

        # Filter projects
        if not len(self.projects) == 0:
            self.filter_projects()

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
                new_all_projects_list[i] = project_obj.to_dict()

        with open(get_project_yaml_path(), "w") as project_h:
            dump_yaml({"projects": new_all_projects_list}, project_h)

    def write_item_yaml(self):
        """
        Mostly static method
        :return:
        """

        all_items_list = read_yaml(self.item_yaml_path)[self.item_type_key]

        new_all_items_list = [item.copy() for item in all_items_list]

        for i, item in enumerate(all_items_list):
            if item.get("name") == self.name:
                new_all_items_list[i] = self.item.to_dict()

        with open(self.item_yaml_path, "w") as item_yaml_h:
            dump_yaml({self.item_type_key: [item_dict for item_dict in new_all_items_list]},
                      item_yaml_h)
