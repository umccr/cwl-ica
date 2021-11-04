#!/usr/bin/env python3

"""
Create the tool submission template
"""

from utils.logging import get_logger
from subcommands.query.create_submission_template import CreateSubmissionTemplate
from utils.repo import get_tools_dir, get_tool_yaml_path
from classes.item_version_tool import ItemVersionTool
from pathlib import Path
from typing import Dict

logger = get_logger()


class CreateToolSubmissionTemplate(CreateSubmissionTemplate):
    """Usage:
    cwl-ica [options] create-tool-submission-template help
    cwl-ica [options] create-tool-submission-template (--tool-path=<path_to_tool>)
                                                          (--prefix=<path_to_output_prefix>)
                                                          (--project=<project_tool_belongs_to>)
                                                          (--launch-project=<project_to_launch_tool>)
                                                          [--curl]

Description:
    Create a ica tool submission template for a CWL tool

Options:
    --tool-path=<path_to_tool>                    Required: Path to a cwl tool
    --project=<project>                                   Required: Project the tool belongs to
    --launch-project<project>                             Optional: Linked project to launch from
    --prefix=<prefix>                                     Optional: prefix to the run name and the output files
    --curl                                                Optional: Use the curl command over ica binary to launch tool

Example:
    cwl-ica create-tool-submission-template --tool-path /path/to/tool --prefix submit-validation --project development_workflows --launch-project development
    """

    def __init__(self, command_argv):
        # Call super class
        super().__init__(command_argv,
                         item_type_key="tools",
                         item_type="tool",
                         item_dir=get_tools_dir(),
                         item_yaml_path=get_tool_yaml_path())

    def get_item_arg(self) -> Path:
        """
        Get --tool-path or --tool-path from args
        :return:
        """
        return Path(self.args.get("--tool-path", None))

    def version_loader(self, version: Dict, cwl_file_path: Path) -> ItemVersionTool:
        """
        Load ItemVersionTool
        :return:
        """
        version = version.copy()
        version['cwl_file_path'] = cwl_file_path
        return ItemVersionTool.from_dict(version)

    @staticmethod
    def get_json_for_input_attribute(input_type: str) -> Dict:
        """
        :return:
        """
        raise NotImplementedError

    @staticmethod
    def get_json_for_schema_input_attribute(schema_dict, optional=False):
        """
        :param schema_dict:
        :param optional:
        :return:
        """
        raise NotImplementedError

    def write_json_file(self):
        raise NotImplementedError