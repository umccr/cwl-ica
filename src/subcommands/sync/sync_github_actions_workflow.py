#!/usr/bin/env python3

"""
Sync all workflows across all projects - to be run in github-actions
"""

from subcommands.sync.sync_github_actions import SyncGitHubActions
from utils.logging import get_logger
from utils.repo import get_workflow_yaml_path, get_workflows_dir
from classes.item_workflow import ItemWorkflow
import os

logger = get_logger()


class SyncGitHubActionsWorkflow(SyncGitHubActions):
    """Usage:
    cwl-ica [options] github-actions-sync-workflows help
    cwl-ica [options] github-actions-sync-workflows

Description:
    Sync all workflows across all projects (including production projects).
    Projects marked with the 'production' attribute as true will have a workflow version created that matches the
    git commit of the latest commit to this pull-request to be merged to the main branch


Environment Variables:
    CWL_ICA_ACCESS_TOKEN_<PROJECT_NAME>  For each project that needs to be synced
    GIT_COMMIT_ID                        The latest commit id - the first seven characters are used as the version tag

Example:
    cwl-ica github-actions-sync-workflows
    """

    # Overwrite global, get workflows directory
    item_yaml_path = get_workflow_yaml_path()

    item_type_key = "workflows"   # Set in subclass
    item_type = "workflow"       # Set in subclass

    def __init__(self, command_argv):
        # Call super class
        super(SyncGitHubActionsWorkflow, self).__init__(command_argv,
                                                    item_dir=get_workflows_dir(),
                                                    item_yaml_path=get_workflow_yaml_path(),
                                                    item_type_key="workflows",
                                                    item_type="workflow",
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
        Get the project ica item list through projects' ica_workflows_list
        :param project:
        :return:
        """
        return project.ica_workflows_list

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemWorkflow.from_dict(item_dict)

    @staticmethod
    def get_item_yaml():
        """
        Returns the workflow item yaml
        :return:
        """
        return get_workflow_yaml_path(non_existent_ok=True)
