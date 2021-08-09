#!/usr/bin/env python3

"""
Add an existing category to an existing tool or workflow

Updates the workflow object across projects on ICA with the additional category

Updates workflow.yaml / tool.yaml

Errors if tool / workflow already contains said category

Takes in --tool-name or --workflow-name as possible choices
Takes in --category-name as standard choice
"""

from classes.command import Command
from ruamel import yaml
from utils.repo import read_yaml, get_project_yaml_path, get_category_yaml_path
from utils.logging import get_logger
from classes.project import Project
from classes.project_production import ProductionProject
from utils.yaml import dump_yaml
from utils.errors import CheckArgumentError, ItemNotFoundError, CategoryNotFoundError

logger = get_logger()

class AddCategory(Command):
    """
    Add category to an item
    """

    def __init__(self, command_argv, item_yaml_path=None, item_type_key=None, item_type=None):
        # Call super class
        super(AddCategory, self).__init__(command_argv)
        self.item_yaml_path = item_yaml_path
        self.item_type_key = item_type_key
        self.item_type = item_type
        self.name = None  # Name of the item to add the category to
        self.item_obj = None
        self.category = None
        self.projects_list = []

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

        # Set item obj
        self.get_item_obj()

        # Get project item name
        self.get_projects_from_item_name()

        # Check category
        self.check_categories_obj()

        # Set categories list
        self.set_categories_list()

    def __call__(self):
        """
        Run through the required steps
        :return:
        """

        logger.info(f"Updating {self.item_yaml_path.name}")
        self.write_item_yaml()

        # Update each of the workflows for each of the projects
        if len(self.projects_list) > 0:
            logger.info(f"Updating {self.item_type_key} on projects")
            self.update_projects()

    def get_project_ica_item_list(self, project):
        """
        Get ica_tools_list or ica_workflows_list
        :return:
        """
        if self.item_type_key == "tools":
            return project.ica_tools_list
        elif self.item_type_key == "workflows":
            return project.ica_workflows_list
        else:
            logger.error(f"Don't support this item type {self.item_type_key}")
            raise ItemNotFoundError

    def get_projects_from_item_name(self):
        """
        Return projects that contain said workflow
        :return:
        """

        # Check if name matches --tool-name or --workflow-name
        # Add project to list
        projects_list = read_yaml(get_project_yaml_path())["projects"]
        for project_dict in projects_list:
            # Read in project
            if project_dict.get("production"):
                project = ProductionProject.from_dict(project_dict)
            else:
                project = Project.from_dict(project_dict)
            # Get item type
            project_ica_item_list = self.get_project_ica_item_list(project)
            # Get project item list
            for project_ica_item in project_ica_item_list:
                if project_ica_item.name == self.name:
                    self.projects_list.append(project)
                    continue

    def get_item_obj(self):
        """
        Get the item object that matches by name
        :return:
        """
        for item_dict in self.get_item_yaml():
            if item_dict.get("name") == self.name:
                self.item_obj = self.get_item_obj_from_dict(item_dict)
                break
        else:
            logger.error(f"Could not find {self.name} in {self.item_yaml_path}")
            raise ItemNotFoundError

    def get_item_yaml(self):
        """
        Get the item yaml based on yaml path and type key
        :return:
        """
        return read_yaml(self.item_yaml_path)[self.item_type_key]

    def check_categories_obj(self):
        """
        Get the category object
        :return:
        """
        categories_list = read_yaml(get_category_yaml_path())["categories"]
        # Confirm name in categories yaml
        if self.category not in [category_l.get('name') for category_l in categories_list]:
            logger.error(f"Please initialise category '{self.category}' with cwl-ica category-init")
            raise CategoryNotFoundError

    def set_categories_list(self):
        """
        Append the category
        :return:
        """
        # Check category isn't already there
        if self.category in self.item_obj.categories:
            logger.error("Category already exists for this workflow")

        # Setting item category list
        self.item_obj.categories.append(self.category)

    def write_item_yaml(self):
        """
        Write out the item yaml with the additional category
        :return:
        """
        new_items_list = []

        for item in self.get_item_yaml():
            if item.get('name') == self.name:
                new_items_list.append(self.item_obj.to_dict())
            else:
                new_items_list.append(item)

        # Write out project
        with open(self.item_yaml_path, 'w') as item_yaml_h:
            dump_yaml({self.item_type_key: new_items_list}, item_yaml_h)

    def update_projects(self):
        """
        Sync workflows for each project with the new category attribute
        :return:
        """
        # Iterate through projects list
        for project in self.projects_list:
            # Get Project ICA item list
            project_ica_item_list = self.get_project_ica_item_list(project)
            # Iterate through item list
            for ica_item in project_ica_item_list:
                if ica_item.name == self.name:
                    # Sync workflow
                    logger.info(f"Updating workflow ID {ica_item.ica_workflow_id} on project {project.project_name}")
                    ica_item.update_ica_workflow_item(access_token=project.get_project_token(), categories=self.item_obj.categories)

    @staticmethod
    def get_item_obj_from_dict(item):
        """
        Get item as an object (ItemTool etc.) from an ordered dict.
        Implemented in subclass as subclass defined object type
        :param item:
        :return:
        """
        raise NotImplementedError


    def check_args(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError


