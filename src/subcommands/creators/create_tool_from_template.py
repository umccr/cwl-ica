#!/usr/bin/env python3

"""
Create tool from template
Pulls in a cwl tool object and runs create_object() on it.
"""

from subcommands.creators.create_from_template import CreateFromTemplate
from utils.logging import get_logger
from docopt import docopt
from argparse import ArgumentError
from utils.repo import get_tools_dir
from classes.cwl_tool import CWLTool
from utils.errors import CheckArgumentError
import os

logger = get_logger()


class CreateToolFromTemplate(CreateFromTemplate):
    """Usage:
    cwl-ica create-tool-from-template help
    cwl-ica create-tool-from-template (--tool-name="<name_of_tool>")
                                      (--tool-version="<tool_version>")
                                      [--username="<your_name>"]


Description:
    We initialise a tool with all of the bells / schema and whistles.
    This creates a file under <CWL_ICA_REPO_PATH>/tools/<tool_name>/<tool_version>/<tool_name>__<tool_version>.cwl

    The tool will have the bare minimum inputs and is ready for you to edit.
    This command does NOT register the tool under tool.yaml, should you change your mind, you can easily just delete the file.
    Remember that for each input and output that you add in a label attribute and a doc attribute.

    For readability purposes we recommend that you place the 'id' attribute of each input and output as the yaml key.
    Remember, that the username isn't necessarily the creator of the software, but the person building the CWLTool file.

    The --username must be first registered in <CWL_ICA_REPO_PATH>/config/user.yaml.
    You may use the command "cwl-ica configure-user" to do that.

    We make sure that --tool-name and --tool-version are appropriate names for folders / files, no special characters or spaces.

    Make sure that the --tool-version argument is in x.y.z format.  If additional patch is required use
    x.y.z__<patch_string>.


Options:
    --tool-name=<tool_name>            Required, the name of the tool
    --tool-version=<tool_version>      Required, the version of the tool
    --username=<username>              Optional, the username of the creator, may be omitted if CWL_ICA_DEFAULT_USER env var is set


EnvironmentVariables:
    CWL_ICA_DEFAULT_USER               Saves having to use --username


Example
    cwl-ica create-tool-from-template --tool-name samtools-fastq --tool-version 1.10.0  --username "Alexis Lucattini"
    cwl-ica create-tool-from-template --tool-name create-fastq-list-csv  --tool-version 0.1.1__py3.7_pd1.2.2  --username "Alexis Lucattini"
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

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
        super(CreateToolFromTemplate, self).__call__()

        # Log to user
        logger.info(f"Created empty tool at \"{self.cwl_file_path}\"")

    @staticmethod
    def get_args(command_argv):
        """
        :return:
        """
        # Get arguments from commandline
        return docopt(__class__.__doc__, argv=command_argv, options_first=False)

    def check_args(self):
        """
        Check --tool-name, --tool-version and --username are defined
        Check --tool-name, --tool-version are appropriate
        Check --username is in user.yaml
        :return:
        """

        # Check defined and assign properties
        tool_name_arg = self.args.get("--tool-name", None)
        self.check_shlex_arg("--tool-name", tool_name_arg)
        if tool_name_arg is None:
            logger.error("--tool-name not defined")
            raise CheckArgumentError
        self.name = tool_name_arg

        tool_version_arg = self.args.get("--tool-version", None)
        self.check_shlex_version_arg("--tool-version", tool_version_arg)
        if tool_version_arg is None:
            logger.error("--tool-version not defined")
            raise CheckArgumentError
        self.version = tool_version_arg

        username_arg = self.args.get("--username", None)

        username_env = os.environ.get("CWL_ICA_DEFAULT_USER", None)

        if username_arg is None and username_env is None:
            logger.error("Please specify the --username parameter or set a default user through "
                         "'cwl-ica set-default-user' then reactivate the conda env")
            raise CheckArgumentError

        self.username = username_arg if username_arg is not None else username_env

        self.set_user_obj()

    def get_top_dir(self, create_dir=False):
        """
        Returns <CWL_ICA_REPO_PATH>/tools
        :return:
        """
        return get_tools_dir(create_dir=create_dir)

    def create_cwl_obj(self):
        """
        Create a cwl object
        :return:
        """

        self.cwl_obj = CWLTool(
            cwl_file_path=self.cwl_file_path,
            name=self.name,
            version=self.version,
            create=True,
            user_obj=self.user_obj
        )
