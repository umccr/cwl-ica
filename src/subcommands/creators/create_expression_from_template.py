#!/usr/bin/env python3

"""
Create expression from template
Pulls in a cwl expression object and runs create_object() on it.
"""

from subcommands.creators.create_from_template import CreateFromTemplate
from utils.logging import get_logger
from docopt import docopt
from argparse import ArgumentError
from utils.repo import get_expressions_dir
from classes.cwl_expression import CWLExpression
from utils.errors import CheckArgumentError

logger = get_logger()


class CreateExpressionFromTemplate(CreateFromTemplate):
    """Usage:
    cwl-ica create-expression-from-template help
    cwl-ica create-expression-from-template (--expression-name="<name_of_expression>")
                                            (--expression-version="<expression_version>")
                                            (--username="<your_name>")


Description:
    We initialise a expression with all of the bells / schema and whistles.
    This creates a file under <CWL_ICA_REPO_PATH>/expressions/<expression_name>/<expression_version>/<expression_name>__<expression_version>.cwl

    The expression will have the bare minimum inputs and is ready for you to edit.
    This command does NOT register the expression under expression.yaml, should you change your mind, you can easily just delete the file.
    Remember that for each input and output that you add in a label attribute and a doc attribute.

    For readability purposes we recommend that you place the 'id' attribute of each input and output as the yaml key.
    Remember, that the username isn't necessarily the creator of the software, but the person building the CWLExpression file.

    The --username must be first registered in <CWL_ICA_REPO_PATH>/config/user.yaml.
    You may use the command "cwl-ica configure-user" to do that.

    We make sure that --expression-name and --expression-version are appropriate names for folders / files, no special characters or spaces.

    Make sure that the --expression-version argument is in x.y.z format.  If additional patch is required use
    x.y.z__<patch_string>.


Options:
    --expression-name=<expression_name>            Required, the name of the expression
    --expression-version=<expression_version>      Required, the version of the expression
    --username=<username>              Required, the username of the creator


Example
    cwl-ica create-expression-from-template --expression-name samexpressions-fastq --expression-version 1.10.0  --username "Alexis Lucattini"
    cwl-ica create-expression-from-template --expression-name create-fastq-list-csv  --expression-version 0.1.1__py3.7_pd1.2.2  --username "Alexis Lucattini"
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
        super(CreateExpressionFromTemplate, self).__call__()

        # Log to user
        logger.info(f"Created empty expression at \"{self.cwl_file_path}\"")

    @staticmethod
    def get_args(command_argv):
        """
        :return:
        """
        # Get arguments from commandline
        return docopt(__class__.__doc__, argv=command_argv, options_first=False)

    def check_args(self):
        """
        Check --expression-name, --expression-version and --username are defined
        Check --expression-name, --expression-version are appropriate
        Check --username is in user.yaml
        :return:
        """

        # Check defined and assign properties
        expression_name_arg = self.args.get("--expression-name", None)
        self.check_shlex_arg("--expression-name", expression_name_arg)
        if expression_name_arg is None:
            logger.error("--expression-name not defined")
            raise CheckArgumentError
        self.name = expression_name_arg

        expression_version_arg = self.args.get("--expression-version", None)
        self.check_shlex_version_arg("--expression-version", expression_version_arg)
        if expression_version_arg is None:
            logger.error("--expression-version not defined")
            raise CheckArgumentError
        self.version = expression_version_arg

        username_arg = self.args.get("--username", None)
        if username_arg is None:
            logger.error("--username not defined")
            raise CheckArgumentError
        self.username = username_arg
        self.set_user_obj()

    def get_top_dir(self, create_dir=False):
        """
        Returns <CWL_ICA_REPO_PATH>/expressions
        :return:
        """
        return get_expressions_dir(create_dir=create_dir)

    def create_cwl_obj(self):
        """
        Create a cwl object
        :return:
        """

        self.cwl_obj = CWLExpression(
            cwl_file_path=self.cwl_file_path,
            name=self.name,
            version=self.version,
            create=True,
            user_obj=self.user_obj
        )
