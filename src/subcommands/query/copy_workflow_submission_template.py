#!/usr/bin/env python3

"""
Copy the workflow submission template
"""

from utils.logging import get_logger
from subcommands.query.copy_submission_template import CopySubmissionTemplate

logger = get_logger()


class CopyWorkflowSubmissionTemplate(CopySubmissionTemplate):
    """Usage:
    cwl-ica [options] copy-workflow-submission-template help
    cwl-ica [options] copy-workflow-submission-template (--ica-workflow-run-instance-id=<run_instance_id>)
                                                        [--prefix=<prefix>]
                                                        [--curl]


Description:
    Copy the launch json and script for an ica submission of the workflow run

Options:
    --ica-workflow-run-instance-id=<run_instance_id>      Required, name of the ica workflow run instance id to copy from
    --prefix=<prefix>                                     Optional - prefix to the run name and the output files
    --curl                                                Optional, use the curl command over ica binary to launch workflow

Example:
    cwl-ica copy-workflow-submission-template --ica-workflow-run-instance-id wfr.123456789 --prefix validation-workflow
    """

    def __init__(self, command_argv):
        # Call super class
        super().__init__(command_argv,
                         item_type_key="workflows",
                         item_type="workflow")