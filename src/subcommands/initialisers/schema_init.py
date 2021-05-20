#!/usr/bin/env python3

"""
Subclass of initialiser
"""

from subcommands.initialisers.initialiser import Initialiser
from utils.logging import get_logger
from pathlib import Path
from classes.item_version_schema import ItemVersionSchema
from classes.item_schema import ItemSchema
from utils.repo import get_schema_yaml_path, get_schemas_dir
from utils.errors import CheckArgumentError


logger = get_logger()


class SchemaInitialiser(Initialiser):
    """Usage:
    cwl-ica [options] schema-init help
    cwl-ica [options] schema-init (--schema-path /path/to/schema.cwl)


Description:
    Add in a schema to 'schema.yaml' in the configuration folder.
    This should have been created with cwl-ica create-schema-from-template and then validated with schema-validate.
    We will also run a validation on the schema.

Options:
    --schema-path=<the schema path>                         Required, the path to the cwl schema

Example:
    cwl-ica schema-init --schema-path "schemas/samples_by_settings/1.0.0/samples_by_settings__1.0.0.cwl"
    """

    def __init__(self, command_argv):
        # Call super class
        super(SchemaInitialiser, self).__init__(command_argv,
                                                update_projects=False,
                                                item_dir=get_schemas_dir(),
                                                item_yaml_path=get_schema_yaml_path(non_existent_ok=True),
                                                item_type_key="schemas",
                                                item_type="schema",
                                                item_suffix="yaml")

    def __call__(self):
        # Call the super class' call function
        super(SchemaInitialiser, self).__call__()

    # Methods implemented in subclass
    def check_args(self):
        """
        Checks --schema-path exists
        For --projects, if set to --all, then checks if --tenants set or CWL_ICA_DEFAULT_TENANT set
        If --projects not set, checks CWL_ICA_DEFAULT_PROJECT
        :return:
        """

        # We will have a name and a version for this schema/schema/workflow etc.

        # Check --schema-path argument
        cwl_path = self.args.get("--schema-path", None)

        if cwl_path is None:
            logger.error("--schema-path not specified")
            raise CheckArgumentError

        # Convert to path type
        cwl_path = Path(cwl_path)

        self.check_cwl_path(cwl_path)

        self.cwl_file_path = cwl_path

        if not cwl_path.is_file():
            logger.error(f"--schema-path argument \"{cwl_path} could not be found")
            raise CheckArgumentError

        # Get the name and version attributes
        self.set_name_and_version_from_file_path()

    def create_item_object(self):
        """
        This creates the item object along with the first version of the item
        This also calls create_item_version and assigns item_version attribute
        :return:
        """
        return ItemSchema(name=self.name,
                          path=Path(self.name),
                          versions=[self.create_item_version_object()],
                          categories=self.categories_list)

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Read in an item object from a dictionary
        :return:
        """

        return ItemSchema.from_dict(item_dict)

    def create_item_version_object(self):
        """
        Create the item version for self.item and assign to item_version
        :return:
        """
        item_version = ItemVersionSchema(name=self.version,
                                         path=Path(self.version) / Path(self.cwl_file_path.resolve().name),
                                         md5sum=None,
                                         cwl_file_path=self.cwl_file_path)

        # We need to call the 'item version' to collect the md5sum attribute
        item_version()

        return item_version
