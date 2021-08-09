#!/usr/bin/env python3

"""
Copy the workflow submission template
"""

from utils.logging import get_logger
from subcommands.listers.list_runs import ListRuns
from utils.repo import get_tools_dir
from pathlib import Path

logger = get_logger()


class ListToolRuns(ListRuns):
    """Usage:
    cwl-ica [options] list-tool-runs help
    cwl-ica [options] list-tool-runs [--tool-path=<path/to/tool>]
                                     [--project=<project-name>]


Description:
    List all of the tool runs

Options:
    --tool-path=</path/to/tool>      Optional, select runs from just one cwl tool
    --project=<project-name>         Optional, select runs from just one project

Example:
    cwl-ica list-tool-runs --project development_workflows
    """

    def __init__(self, command_argv):
        # Call super class
        super().__init__(command_argv,
                         item_type_key="tools",
                         item_type="tool",
                         items_dir=get_tools_dir())

    def get_cwl_file_path_arg(self):
        """
        Get the cwl file path argument
        :return:
        """
        if self.args.get("--tool-path", None) is None:
            return None

        cwl_file_path = Path(self.args.get("--tool-path"))

        if not cwl_file_path.is_file():
            logger.error(f"Could not find cwl tool {self.args.get('--tool-path')}")
            raise FileNotFoundError

        return cwl_file_path