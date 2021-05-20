#!/usr/bin/env python3

"""
Validate a cwl expression
"""

from subcommands.validators.validate import Validate
from utils.logging import get_logger
from argparse import ArgumentError
from utils.repo import get_expressions_dir
from classes.cwl_expression import CWLExpression
from pathlib import Path
from utils.errors import CheckArgumentError

logger = get_logger()


class ExpressionValidate(Validate):
    """Usage:
    cwl-ica expression-validate help
    cwl-ica expression-validate (--expression-path="<path_to_cwl_expression>")

Description:
    Validate a CWL File of CommandLineExpression. This must be done prior to registering the expression with the "cwl-ica expression-init" command.
    The CWL expression must be in the expressions/ directory under CWL_ICA_REPO_PATH

Options:
    --expression-path=<expression_path>      Required, the path to the cwl expression

Example
    cwl-ica expression-validate --expression-path expressions/flatten-2d-array/1.0.0/flatten-2d-array__1.0.0.cwl
    """

    def __init__(self, command_argv):
        """
        Check arguments - check cwl file path exists
        Import cwl object
        :param command_argv:
        """
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
        super(ExpressionValidate, self).__call__()

    def check_args(self):
        """
        Check --expression-path exists
        :return:
        """

        # Check defined and assign properties
        expression_path_arg = self.args.get("--expression-path", None)
        if expression_path_arg is None:
            logger.error("--expression-path not defined")
            raise CheckArgumentError
        self.cwl_file_path = Path(expression_path_arg)
        # Checks cwl_file_path
        self.check_file()

        # Make sure file path exists
        self.name, self.version = self.split_name_version(items_dir=self.get_top_dir())

        # Check name
        self.check_shlex_arg("--expression-path", self.name)

        # Check version
        self.check_shlex_version_arg("--expression-path", self.version)

        # Set cwl obj
        self.cwl_obj = self.import_cwl_obj()

    def import_cwl_obj(self):
        """
        Create a cwl object
        :return:
        """

        return CWLExpression(
            cwl_file_path=self.cwl_file_path,
            name=self.name,
            version=self.version,
            create=False,
            user_obj=None
        )

    @staticmethod
    def get_top_dir(create_dir=False):
        """
        Returns <CWL_ICA_REPO_PATH>/expressions
        :return:
        """
        return get_expressions_dir(create_dir=create_dir)
