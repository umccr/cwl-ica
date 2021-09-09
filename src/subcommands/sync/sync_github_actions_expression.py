#!/usr/bin/env python3

"""
Sync all expressions across all projects - to be run in github-actions
"""

from subcommands.sync.sync_github_actions import SyncGitHubActions
from utils.logging import get_logger
from utils.repo import get_expression_yaml_path, get_expressions_dir
from classes.item_expression import ItemExpression
from utils.miscell import write_item_yaml

logger = get_logger()


class SyncGitHubActionsExpression(SyncGitHubActions):
    """Usage:
    cwl-ica [options] github-actions-sync-expressions help
    cwl-ica [options] github-actions-sync-expressions

Description:
    Sync all expressions in expression.yaml.

Example:
    cwl-ica github-actions-sync-expressions
    """

    # Overwrite global, get expressions directory
    item_yaml_path = get_expression_yaml_path()

    item_type_key = "expressions"   # Set in subclass
    item_type = "expression"       # Set in subclass

    def __init__(self, command_argv):
        # Call super class
        super(SyncGitHubActionsExpression, self).__init__(command_argv,
                                                    item_dir=get_expressions_dir(),
                                                    item_yaml_path=get_expression_yaml_path(),
                                                    item_type_key="expressions",
                                                    item_type="expression",
                                                    item_suffix="cwl")

    def __call__(self):
        # Iterate through each item, determine if to update or not
        for item in self.items:
            for version in item.versions:
                # Call the version to set the cwl_obj
                version()
                # Update version md5sum
                version.md5sum = version.cwl_obj.md5sum

        # Write out items yaml
        logger.info(f"Writing out updated \"{self.item_type}\"(s) to \"{self.get_item_yaml()}\"")
        write_item_yaml(self.items, self.item_type_key, self.get_item_yaml())

    def check_args(self):
        """
        No arguments to check
        """
        pass

    @staticmethod
    def get_projects():
        """
        Projects not functional for expressions
        :return:
        """
        return None


    @staticmethod
    def get_project_ica_item_list(project):
        """
        Projects not functional for expressions
        :param project:
        :return:
        """
        return None

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemExpression.from_dict(item_dict)

    @staticmethod
    def get_item_yaml():
        """
        Returns the expression item yaml
        :return:
        """
        return get_expression_yaml_path(non_existent_ok=True)
