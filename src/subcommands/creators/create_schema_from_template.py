#!/usr/bin/env python3

"""
Create expression from template
Pulls in a cwl expression object and runs create_object() on it.
"""

from subcommands.creators.create_from_template import CreateFromTemplate
from utils.logging import get_logger
from docopt import docopt
from argparse import ArgumentError
from utils.repo import get_schemas_dir
from classes.cwl_schema import CWLSchema
from utils.errors import CheckArgumentError

logger = get_logger()


class CreateSchemaFromTemplate(CreateFromTemplate):
    """Usage:
    cwl-ica create-schema-from-template help
    cwl-ica create-schema-from-template (--schema-name="<name_of_schema>")
                                        (--schema-version="<schema_version>")

Description:
    We initialise a schema with all of the bells / schema and whistles.
    This creates a file under <CWL_ICA_REPO_PATH>/schema/<schema_name>/<schema_version>/<schema_name>__<schema_version>.yaml

    The schema will have the bare minimum inputs and is ready for you to edit.
    This command does NOT register the schema under schema.yaml, should you change your mind, you can easily just delete the file.
    Remember that for each input and output that you add in a label attribute and a doc attribute.

    For readability purposes we recommend that you place the 'id' attribute of each input and output as the yaml key.

    We make sure that --schema-name and --schema-version are appropriate names for folders / files, no special characters or spaces.

    Make sure that the --schema-version argument is in x.y.z format.  If additional patch is required use
    x.y.z__<patch_string>.


Options:
    --schema-name=<schema_name>            Required, the name of the schema
    --schema-version=<schema_version>      Required, the version of the schema

Example
    cwl-ica create-schema-from-template --schema-name fastq-list-row --schema-version 1.10.0
    cwl-ica create-schema-from-template --schema-name settings-by-samples --schema-version 0.1.1
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv, suffix="yaml")

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
        super(CreateSchemaFromTemplate, self).__call__()

        # Log to user
        logger.info(f"Created empty schema at \"{self.cwl_file_path}\"")

    @staticmethod
    def get_args(command_argv):
        """
        :return:
        """
        # Get arguments from commandline
        return docopt(__class__.__doc__, argv=command_argv, options_first=False)

    def check_args(self):
        """
        Check --schema-name, --schema-version are defined
        Check --schema-name, --schema-version are appropriate
        :return:
        """

        # Check defined and assign properties
        schema_name_arg = self.args.get("--schema-name", None)
        self.check_shlex_arg("--schema-name", schema_name_arg)
        self.check_conformance("--schema-name", schema_name_arg)
        if schema_name_arg is None:
            logger.error("--schema-name not defined")
            raise CheckArgumentError
        self.name = schema_name_arg

        schema_version_arg = self.args.get("--schema-version", None)
        self.check_shlex_version_arg("--schema-version", schema_version_arg)
        if schema_version_arg is None:
            logger.error("--schema-version not defined")
            raise CheckArgumentError
        self.version = schema_version_arg

    def get_top_dir(self, create_dir=False):
        """
        Returns <CWL_ICA_REPO_PATH>/schema
        :return:
        """
        return get_schemas_dir(create_dir=create_dir)

    def create_cwl_obj(self):
        """
        Create a cwl object
        :return:
        """

        self.cwl_obj = CWLSchema(
            cwl_file_path=self.cwl_file_path,
            name=self.name,
            version=self.version,
            create=True
        )
