#!/usr/bin/env python3

"""
List all users registered in <CWL_ICA_REPO_PATH>/config/category.yaml
"""

from classes.command import Command
from utils.logging import get_logger
import pandas as pd
from utils.repo import read_yaml, get_category_yaml_path
import sys

logger = get_logger()


class ListCategories(Command):
    """Usage:
    cwl-ica [options] list-categories help
    cwl-ica [options] list-categories

Description:
    List all categories in <CWL_ICA_REPO_PATH>/config/category.yaml

Example:
    cwl-ica list-categories
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Check args
        self.check_args()

    def __call__(self):
        """
        Just run through this
        :return:
        """

        # Check category.yaml exists
        category_yaml_path = get_category_yaml_path()

        category_list = read_yaml(category_yaml_path)['categories']

        # Create pandas df of category yaml path
        category_df = pd.DataFrame(category_list)

        # Write category to stdout
        category_df.to_markdown(sys.stdout, index=False)

        # Create new line character
        print()

    def check_args(self):
        """
        Check category yaml exists
        :return:
        """

        # Just make sure the category.yaml path exists
        _ = get_category_yaml_path()
