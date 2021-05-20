#!/usr/bin/env python3

"""
Sync a schema to schema.yaml and to any projects set under --projects
"""

from subcommands.sync.sync import Sync
from utils.logging import get_logger
from utils.repo import get_schema_yaml_path, get_schemas_dir
from pathlib import Path
from classes.item_schema import ItemSchema
from utils.errors import CheckArgumentError


logger = get_logger()


class SchemaSync(Sync):
    """Usage:
    cwl-ica [options] schema-sync help
    cwl-ica [options] schema-sync (--schema-path /path/to/schema.cwl)


Description:
    Sync a schema to 'schema.yaml' in the configuration folder
    The schema should have been created with cwl-ica create-schema-from-template and then validated with schema-validate.
    The schema must exist in schema.yaml.  Please use cwl-ica schema-init to add this schema to schema.yaml.
    We will also run a validation on the schema before syncing.

Options:
    --schema-path=<the schema path>                         Required, the path to the cwl schema

Example:
    cwl-ica schema-sync --schema-path "schemas/samples_by_settings/1.0.0/samples_by_settings__1.0.0.cwl"
    """

    # Overwrite global, get schemas directory
    item_yaml_path = get_schema_yaml_path()

    item_type_key = "schemas"   # Set in subclass
    item_type = "schema"       # Set in subclass

    def __init__(self, command_argv):
        # Call super class
        super(SchemaSync, self).__init__(command_argv,
                                             update_projects=False,
                                             item_dir=get_schemas_dir(),
                                             item_yaml_path=get_schema_yaml_path(),
                                             item_type_key="schemas",
                                             item_type="schema",
                                             item_suffix="cwl")

    def check_args(self):
        """
        Checks --schema-path exists
        :return:
        """
        # Check --schema-path argument
        cwl_path = self.args.get("--schema-path", None)

        if cwl_path is None:
            logger.error("--schema-path not specified")
            raise CheckArgumentError

        # Convert to path type
        cwl_path = Path(cwl_path)

        self.cwl_file_path = cwl_path

        if not cwl_path.is_file():
            logger.error(f"--schema-path argument \"{cwl_path} could not be found")
            raise CheckArgumentError

        # Get the name and version attributes
        self.set_name_and_version_from_file_path()

    @staticmethod
    def get_project_ica_item_list(project):
        """
        Not relevant for schemas
        :param project:
        :return:
        """
        raise NotImplementedError

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemSchema.from_dict(item_dict)
