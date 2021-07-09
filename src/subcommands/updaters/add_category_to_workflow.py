#!/usr/bin/env

"""
Add a category to a workflow
"""

from subcommands.updaters.add_category import AddCategory
from utils.repo import get_workflow_yaml_path
from classes.item_workflow import ItemWorkflow
from utils.errors import CheckArgumentError
from utils.logging import get_logger

logger = get_logger()


class AddCategoryToWorkflow(AddCategory):
    """Usage:
    cwl-ica [options] add-category-to-workflow help
    cwl-ica [options] add-category-to-workflow (--workflow-name name_of_workflow)
                                           (--category-name="category_name")

Description:
    Add an existing category to an existing workflow.
    Category must exist in category.yaml, please use cwl-ica category-init to add this category to category.yaml
    Workflow must exist in workflow.yaml, please use cwl-ica workflow-init to add this workflow to workflow.yaml
    All ica workflow objects will be updated across projects that contain this workflow

Options:
    --workflow-name=<the workflow name>                 Required, the name of the workflow
    --category-name=<the category name>                 Required, the name of the category

Example:
    cwl-ica add-category-to-workflow --workflow-name "dragen-wgs-qc" --category-name "dragen-workflows"
    """

    def __init__(self, command_argv):
        # Call super class
        super(AddCategoryToWorkflow, self).__init__(command_argv,
                                               item_yaml_path=get_workflow_yaml_path(),
                                               item_type_key="workflows",
                                               item_type="workflow")

    def check_args(self):
        """
        Checks --workflow-name is defined and exists, check --category-name is defined and exists
        :return:
        """
        # Check --workflow-path argument
        workflow_name = self.args.get("--workflow-name", None)

        if workflow_name is None:
            logger.error("--workflow-name not specified")
            raise CheckArgumentError

        self.name = workflow_name

        # Add project / check project in projects
        category_name = self.args.get("--category-name", None)

        if category_name is None:
            logger.error("--category-name not specified")
            raise CheckArgumentError

        self.category = category_name

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemWorkflow.from_dict(item_dict)