#!/usr/bin/env python3

"""
Validate a cwl schema
"""

from subcommands.validators.validate import Validate
from utils.logging import get_logger
from docopt import docopt
from argparse import ArgumentError
from utils.repo import get_schemas_dir
from classes.cwl_schema import CWLSchema
from pathlib import Path
from utils.errors import CheckArgumentError

logger = get_logger()


class SchemaValidate(Validate):
    """Usage:
    cwl-ica schema-validate help
    cwl-ica schema-validate (--schema-path="<path_to_cwl_schema>")

Description:
    Validate a CWL File of CommandLineExpression. This must be done prior to registering the schema with the "cwl-ica schema-init" command.
    The CWL schema must be in the schemas/ directory under CWL_ICA_REPO_PATH

Options:
    --schema-path=<schema_path>      Required, the path to the cwl schema

Example
    cwl-ica schema-validate --schema-path schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
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
        super(SchemaValidate, self).__call__()

    def check_args(self):
        """
        Check --schema-path exists
        :return:
        """

        # Check defined and assign properties
        schema_path_arg = self.args.get("--schema-path", None)
        if schema_path_arg is None:
            logger.error("--schema-path not defined")
            raise CheckArgumentError
        self.cwl_file_path = Path(schema_path_arg)
        # Checks cwl_file_path
        self.check_file()

        # Make sure file path exists
        self.name, self.version = self.split_name_version(items_dir=self.get_top_dir())

        # Check name
        self.check_shlex_arg("--schema-path", self.name)

        # Check version
        self.check_shlex_version_arg("--schema-path", self.version)

        # Set cwl obj
        self.cwl_obj = self.import_cwl_obj()

    def import_cwl_obj(self):
        """
        Create a cwl object
        :return:
        """

        return CWLSchema(
            cwl_file_path=self.cwl_file_path,
            name=self.name,
            version=self.version,
            create=False,
            user_obj=None
        )

    @staticmethod
    def get_top_dir(create_dir=False):
        """
        Returns <CWL_ICA_REPO_PATH>/schemas
        :return:
        """
        return get_schemas_dir(create_dir=create_dir)
