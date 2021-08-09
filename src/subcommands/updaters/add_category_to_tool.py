#!/usr/bin/env

"""
Add a category to a tool
"""

from subcommands.updaters.add_category import AddCategory
from utils.repo import get_tool_yaml_path
from classes.item_tool import ItemTool
from utils.errors import CheckArgumentError
from utils.logging import get_logger

logger = get_logger()


class AddCategoryToTool(AddCategory):
    """Usage:
    cwl-ica [options] add-category-to-tool help
    cwl-ica [options] add-category-to-tool (--tool-name name_of_tool)
                                           (--category-name="category_name")

Description:
    Add an existing category to an existing tool.
    Category must exist in category.yaml, please use cwl-ica category-init to add this category to category.yaml
    Tool must exist in tool.yaml, please use cwl-ica tool-init to add this tool to tool.yaml
    All ica workflow objects will be updated across projects that contain this tool

Options:
    --tool-name=<the tool name>                         Required, the name of the tool
    --category-name=<the category name>                 Required, the name of the category

Example:
    cwl-ica add-category-to-tool --tool-name "bwa-index" --category-name "alignment"
    """

    def __init__(self, command_argv):
        # Call super class
        super(AddCategoryToTool, self).__init__(command_argv,
                                               item_yaml_path=get_tool_yaml_path(),
                                               item_type_key="tools",
                                               item_type="tool")

    def check_args(self):
        """
        Checks --tool-name is defined and exists, check --category-name is defined and exists
        :return:
        """
        # Check --tool-path argument
        tool_name = self.args.get("--tool-name", None)

        if tool_name is None:
            logger.error("--tool-name not specified")
            raise CheckArgumentError

        self.name = tool_name

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
        return ItemTool.from_dict(item_dict)