#!/usr/bin/env python3

"""
Subclass of initialiser
"""

from subcommands.initialisers.initialiser import Initialiser
from utils.logging import get_logger
from pathlib import Path
from classes.item_version_expression import ItemVersionExpression
from classes.item_expression import ItemExpression
from utils.repo import get_expression_yaml_path, get_expressions_dir
from utils.errors import CheckArgumentError


logger = get_logger()


class ExpressionInitialiser(Initialiser):
    """Usage:
    cwl-ica [options] expression-init help
    cwl-ica [options] expression-init (--expression-path /path/to/expression.cwl)


Description:
    Add in a expression to 'expression.yaml' in the configuration folder.
    This should have been created with cwl-ica create-expression-from-template and then validated with expression-validate.
    We will also run a validation on the expression.


Options:
    --expression-path=<the expression path>                         Required, the path to the cwl expression

Example:
    cwl-ica expression-init --expression-path "expressions/flatten_array_file/1.0.0/flatten_array_file__1.0.0.cwl"
    """

    def __init__(self, command_argv):
        # Call super class
        super(ExpressionInitialiser, self).__init__(command_argv,
                                                    update_projects=False,
                                                    item_dir=get_expressions_dir(),
                                                    item_yaml_path=get_expression_yaml_path(non_existent_ok=True),
                                                    item_type_key="expressions",
                                                    item_type="expression",
                                                    item_suffix="cwl")

    def __call__(self):
        # Call the super class' call function
        super(ExpressionInitialiser, self).__call__()

    # Methods implemented in subclass
    def check_args(self):
        """
        Checks --expression-path exists
        For --projects, if set to --all, then checks if --tenants set or CWL_ICA_DEFAULT_TENANT set
        If --projects not set, checks CWL_ICA_DEFAULT_PROJECT
        :return:
        """

        # We will have a name and a version for this expression/expression/workflow etc.

        # Check --expression-path argument
        cwl_path = self.args.get("--expression-path", None)

        if cwl_path is None:
            logger.error("--expression-path not specified")
            raise CheckArgumentError

        # Convert to path type
        cwl_path = Path(cwl_path)

        self.check_cwl_path(cwl_path)

        self.cwl_file_path = cwl_path

        if not cwl_path.is_file():
            logger.error(f"--expression-path argument \"{cwl_path} could not be found")
            raise CheckArgumentError

        # Get the name and version attributes
        self.set_name_and_version_from_file_path()

    def create_item_object(self):
        """
        This creates the item object along with the first version of the item
        This also calls create_item_version and assigns item_version attribute
        :return:
        """
        return ItemExpression(name=self.name,
                              path=Path(self.name),
                              versions=[self.create_item_version_object()],
                              categories=self.categories_list)

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Read in an item object from a dictionary
        :return:
        """

        return ItemExpression.from_dict(item_dict)

    def create_item_version_object(self):
        """
        Create the item version for self.item and assign to item_version
        :return:
        """
        item_version = ItemVersionExpression(name=self.version,
                                             path=Path(self.version) / Path(self.cwl_file_path.resolve().name),
                                             md5sum=None,
                                             cwl_file_path=self.cwl_file_path)

        # We need to call the 'item version' to collect the md5sum attribute
        item_version()

        return item_version
