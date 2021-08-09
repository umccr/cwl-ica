#!/usr/bin/env python3

"""
Copy the workflow submission template
"""

from utils.logging import get_logger
from subcommands.listers.list_runs import ListRuns
from utils.repo import get_workflows_dir
from pathlib import Path

logger = get_logger()


class ListWorkflowRuns(ListRuns):
    """Usage:
    cwl-ica [options] list-workflow-runs help
    cwl-ica [options] list-workflow-runs [--workflow-path=<path/to/workflow>]
                                         [--project=<project-name>]


Description:
    List all of the workflow runs

Options:
    --workflow-path=</path/to/workflow>      Optional, select runs from just one cwl workflow
    --project=<project-name>         Optional, select runs from just one project

Example:
    cwl-ica list-workflow-runs --project development_workflows
    """

    def __init__(self, command_argv):
        # Call super class
        super().__init__(command_argv,
                         item_type_key="workflows",
                         item_type="workflow",
                         items_dir=get_workflows_dir())

    def get_cwl_file_path_arg(self):
        """
        Get the cwl file path argument
        :return:
        """
        if self.args.get("--workflow-path", None) is None:
            return None

        cwl_file_path = Path(self.args.get("--workflow-path"))

        if not cwl_file_path.is_file():
            logger.error(f"Could not find cwl workflow {self.args.get('--workflow-path')}")
            raise FileNotFoundError

        return cwl_file_path