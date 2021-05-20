#!/usr/bin/env python3

"""
Sync all tools across all projects - to be run in github-actions
"""

from subcommands.sync.sync_github_actions import SyncGitHubActions
from utils.logging import get_logger
from utils.repo import get_tool_yaml_path, get_tools_dir
from classes.item_tool import ItemTool
import os

logger = get_logger()


class SyncGitHubActionsTool(SyncGitHubActions):
    """Usage:
    cwl-ica [options] github-actions-sync-tools help
    cwl-ica [options] github-actions-sync-tools

Description:
    Sync all tools across all projects (including production projects).
    Projects marked with the 'production' attribute as true will have a workflow version created that matches the
    git commit of the latest commit to this pull-request to be merged to the main branch


Environment Variables:
    CWL_ICA_ACCESS_TOKEN_<PROJECT_NAME>  For each project that needs to be synced
    GIT_COMMIT_ID                        The latest commit id - the first seven characters are used as the version tag

Example:
    cwl-ica github-actions-sync-tools
    """

    # Overwrite global, get tools directory
    item_yaml_path = get_tool_yaml_path()

    item_type_key = "tools"   # Set in subclass
    item_type = "tool"       # Set in subclass

    def __init__(self, command_argv):
        # Call super class
        super(SyncGitHubActionsTool, self).__init__(command_argv,
                                                    item_dir=get_tools_dir(),
                                                    item_yaml_path=get_tool_yaml_path(),
                                                    item_type_key="tools",
                                                    item_type="tool",
                                                    item_suffix="cwl")

    def check_args(self):
        """
        Checks GIT_COMMIT_ID env var exists
        """
        if os.environ.get("GIT_COMMIT_ID", None) is None:
            logger.error("Could not get \"GIT_COMMIT_ID\" env var")
            raise EnvironmentError

    @staticmethod
    def get_project_ica_item_list(project):
        """
        Get the project ica item list through projects' ica_tools_list
        :param project:
        :return:
        """
        return project.ica_tools_list

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemTool.from_dict(item_dict)

    @staticmethod
    def get_item_yaml():
        """
        Returns the tool item yaml
        :return:
        """
        return get_tool_yaml_path(non_existent_ok=True)
