#!/usr/bin/env python3

"""
Create tool from template
Pulls in a cwl tool object and runs create_object() on it.
"""

from subcommands.creators.create_from_template import CreateFromTemplate
from utils.logging import get_logger
from docopt import docopt
from argparse import ArgumentError
from utils.repo import get_workflows_dir
from classes.cwl_workflow import CWLWorkflow
from utils.errors import CheckArgumentError

logger = get_logger()


class CreateWorkflowFromTemplate(CreateFromTemplate):
    """Usage:
    cwl-ica create-workflow-from-template help
    cwl-ica create-workflow-from-template (--workflow-name="<name_of_workflow>")
                                      (--workflow-version="<workflow_version>")
                                      (--username="<your_name>")


Description:
    We initialise a workflow with all of the bells / schema and whistles.
    This creates a file under <CWL_ICA_REPO_PATH>/workflows/<workflow_name>/<workflow_version>/<workflow_name>__<workflow_version>.cwl

    The workflow will have the bare minimum inputs and is ready for you to edit.
    This command does NOT register the tool under workflow.yaml, should you change your mind, you can easily just delete the file.
    Remember that for each input and output that you add in a label attribute and a doc attribute.

    For readability purposes we recommend that you place the 'id' attribute of each input and output as the yaml key.
    Remember, that the username isn't necessarily the creator of the software, but the person building the CWLWorkflow file.

    The --username must be first registered in <CWL_ICA_REPO_PATH>/config/user.yaml.
    You may use the command "cwl-ica configure-user" to do that.

    We make sure that --workflow-name and --workflow-version are appropriate names for folders / files, no special characters or spaces.

    Make sure that the --workflow-version argument is in x.y.z format.  If additional patch is required use
    x.y.z__<patch_string>.


Options:
    --workflow-name=<workflow_name>            Required, the name of the workflow
    --workflow-version=<workflow_version>      Required, the version of the workflow
    --username=<username>              Required, the username of the creator


Example
    cwl-ica create-workflow-from-template --workflow-name fastq-to-bam --workflow-version 1.0.0--3.7.5  --username "Alexis Lucattini"
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Collect arguments
        self.args: dict = self.get_args(command_argv)

        # Check help
        self.check_length(command_argv)

        # Check if help has been called
        if self.args["help"]:
            self._help()

        # Confirm 'required' arguments are present and valid
        try:
            self.check_args()
        except ArgumentError:
            self._help(fail=True)

    def __call__(self):
        super(CreateWorkflowFromTemplate, self).__call__()

        # Log to user
        logger.info(f"Created empty workflow at \"{self.cwl_file_path}\"")

    @staticmethod
    def get_args(command_argv):
        """
        :return:
        """
        # Get arguments from commandline
        return docopt(__class__.__doc__, argv=command_argv, options_first=False)

    def check_args(self):
        """
        Check --workflow-name, --workflow-version and --username are defined
        Check --workflow-name, --workflow-version are appropriate
        Check --username is in user.yaml
        :return:
        """

        # Check defined and assign properties
        workflow_name_arg = self.args.get("--workflow-name", None)
        self.check_shlex_arg("--workflow-name", workflow_name_arg)
        if workflow_name_arg is None:
            logger.error("--workflow-name not defined")
            raise CheckArgumentError
        self.name = workflow_name_arg

        workflow_version_arg = self.args.get("--workflow-version", None)
        self.check_shlex_version_arg("--workflow-version", workflow_version_arg)
        if workflow_version_arg is None:
            logger.error("--workflow-version not defined")
            raise CheckArgumentError
        self.version = workflow_version_arg

        username_arg = self.args.get("--username", None)
        if username_arg is None:
            logger.error("--username not defined")
            raise CheckArgumentError
        self.username = username_arg
        self.set_user_obj()

    def get_top_dir(self, create_dir=False):
        """
        Returns <CWL_ICA_REPO_PATH>/workflows
        :return:
        """
        return get_workflows_dir(create_dir=create_dir)

    def create_cwl_obj(self):
        """
        Create a cwl object
        :return:
        """

        self.cwl_obj = CWLWorkflow(
            cwl_file_path=self.cwl_file_path,
            name=self.name,
            version=self.version,
            create=True,
            user_obj=self.user_obj
        )
