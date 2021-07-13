#!/usr/bin/env python3

"""
Register a ica run instance
"""

from subcommands.initialisers.run_init import RegisterRunInstance

class RegisterToolRunInstance(RegisterRunInstance):
    """Usage:
    cwl-ica [options] register-tool-run-instance help
    cwl-ica [options] register-tool-run-instance (--ica-workflow-run-instance-id ica_workflow_run_instance_id)
                                                 (--project-name the_project_name)
                                                 [--access-token ica_access_token]


Description:
    Register a run instance id for a given workflow / version in a project.
    If the workflow is from a linked project, you may need to provide an access token either through the --access-token
    cli parameter or the ICA_ACCESS_TOKEN environment variable

Options:
    --ica-workflow-run-instance-id=<the run instance id>  The ica workflow run instance id
    --project-name=<the project name>                     Required, the name of the project that the workflow version was created on. Must exist in project.yaml
    --access-token=<ica access token>                    The ICA ACCESS TOKEN if the run instance was executed in a linked project context

Environment Variables:
    ICA_ACCESS_TOKEN          Can be used as an alternative for --access-token

Example:
    cwl-ica register-tool-run-instance --project-name "development" --ica-workflow-run-instance-id "wfr.123456789"
    """

    def __init__(self, command_argv):
        """
        Initialiser
        """
        # Call super class - this calls checks args, gets run objects etc
        super(RegisterToolRunInstance, self).__init__(command_argv,
                                                      item_type="tool",
                                                      item_type_key="tools")