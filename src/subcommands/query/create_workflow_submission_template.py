#!/usr/bin/env python3

"""
Create the workflow submission template
"""

from utils.logging import get_logger
from subcommands.query.create_submission_template import CreateSubmissionTemplate
from utils.repo import get_workflows_dir, get_workflow_yaml_path
from classes.item_version_workflow import ItemVersionWorkflow
from pathlib import Path
from typing import Dict

logger = get_logger()


class CreateWorkflowSubmissionTemplate(CreateSubmissionTemplate):
    """Usage:
    cwl-ica [options] create-workflow-submission-template help
    cwl-ica [options] create-workflow-submission-template (--workflow-path=<path_to_workflow>)
                                                          (--prefix=<path_to_output_prefix>)
                                                          (--project=<project_workflow_belongs_to>)
                                                          (--launch-project=<project_to_launch_workflow>)
                                                          [--curl]

Description:
    Create a ica workflow submission template for a CWL workflow

Options:
    --workflow-path=<path_to_workflow>                    Required: Path to a cwl workflow
    --project=<project>                                   Required: Project the workflow belongs to
    --launch-project<project>                             Optional: Linked project to launch from
    --prefix=<prefix>                                     Optional: prefix to the run name and the output files
    --curl                                                Optional: Use the curl command over ica binary to launch workflow

Example:
    cwl-ica create-workflow-submission-template --workflow-path /path/to/workflow --prefix submit-validation --project development_workflows --launch-project development
    """

    def __init__(self, command_argv):
        # Call super class
        super().__init__(command_argv,
                         item_type_key="workflows",
                         item_type="workflow",
                         item_dir=get_workflows_dir(),
                         item_yaml_path=get_workflow_yaml_path())

    def get_item_arg(self) -> Path:
        """
        Get --workflow-path or --tool-path from args
        :return:
        """
        return Path(self.args.get("--workflow-path", None))

    def version_loader(self, version: Dict, cwl_file_path: Path) -> ItemVersionWorkflow:
        """
        Load ItemVersionWorkflow
        :return:
        """
        version = version.copy()
        version['cwl_file_path'] = cwl_file_path
        return ItemVersionWorkflow.from_dict(version)

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