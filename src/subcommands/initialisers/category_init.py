#!/usr/bin/env python3

"""
Create a new category in category.yaml
"""

from classes.command import Command
from utils.logging import get_logger
from argparse import ArgumentError
from ruamel.yaml.comments import CommentedMap as OrderedDict
from utils.repo import get_category_yaml_path, read_yaml, get_cwl_ica_repo_path, get_project_yaml_path
from utils.errors import CategoryExistsError, CheckArgumentError
from utils.yaml import dump_yaml, to_multiline_string

logger = get_logger()


class CategoryInit(Command):
    """Usage:
    cwl-ica [options] category-init help
    cwl-ica [options] category-init (--name="<name_of_category>")
                                    [--description="<Description_of_category>"]

Description:
    Initialises a category in ${CWL_ICA_REPO_PATH}/config/category.yaml
    Categories are like tags and can be used as a filter to search for workflows / tools.
    A tool / workflow may have multiple categories.

Options:
    --name=<"name of category">                                 Required, the name of the category
    --description=<"A little description of the category">      Required, whats the theme

Example:
    cwl-ica category-init --name "dragen" --description "Tool / Workflow uses dragen"
    cwl-ica category-init --name "Alignment" --description "Tool / Workflow aligns read-level data as bams"
    """

    def __init__(self, command_argv):
        """
        1. Read category.yaml if it already exists
        2. If it does, make sure this category doesn't already exist
        :param command_argv:
        """
        # Collect args from doc strings
        super(CategoryInit, self).__init__(command_argv)

        # Initialise properties
        self.category_name = None
        self.category_description = None

        # Check if help has been called
        if self.args["help"]:
            self._help()

        # Confirm 'required' arguments are present and valid
        try:
            logger.debug("Checking args")
            self.check_args()
        except CheckArgumentError:
            self._help(fail=True)

    def __call__(self):
        """
        Write category to category.yaml
        :return:
        """
        # Add category to yaml
        self.add_category_to_category_yaml()

        # Let user know
        logger.info(f"Added category \"{self.category_name}\" to \"{get_category_yaml_path()}\"")

    def check_args(self):
        # Check name is defined
        if self.args.get("--name", None) is None:
            logger.error("Category name is not defined. Please specify with --name")
            raise CheckArgumentError
        self.category_name = self.args.get("--name")

        # Check description is defined
        if self.args.get("--description", None) is None:
            logger.error("Category description is not defined. Please specify with --description")
            raise CheckArgumentError
        self.category_description = self.args.get("--description")

    def add_category_to_category_yaml(self):
        # Read category yaml
        category_yaml_path = get_category_yaml_path(non_existent_ok=True)
        if not category_yaml_path.is_file():
            category_list = []
        else:
            category_list = read_yaml(category_yaml_path).get('categories', [])

        # Make sure category name is yet to exist in list of categories
        for category in category_list:
            category_name = category.get("name", None)
            if category_name == self.category_name:
                logger.error(f"Category {category_name} already exists in {category_yaml_path}")
                raise CategoryExistsError

        # Append category
        category_list.append(OrderedDict({
            "name": self.category_name,
            "description": to_multiline_string(self.category_description)
        }))

        category_dict = {
            "categories": category_list
        }

        # Write category
        with open(category_yaml_path, 'w') as category_h:
            dump_yaml(category_dict, category_h)
