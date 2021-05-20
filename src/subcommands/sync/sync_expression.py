#!/usr/bin/env python3

"""
Sync a expression to expression.yaml and to any projects set under --projects
"""

from subcommands.sync.sync import Sync
from utils.logging import get_logger
from utils.repo import get_expression_yaml_path, get_expressions_dir
from pathlib import Path
from classes.item_expression import ItemExpression
from utils.errors import CheckArgumentError


logger = get_logger()


class ExpressionSync(Sync):
    """Usage:
    cwl-ica [options] expression-sync help
    cwl-ica [options] expression-sync (--expression-path /path/to/expression.cwl)


Description:
    Sync a expression to 'expression.yaml' in the configuration folder
    The expression should have been created with cwl-ica create-expression-from-template and then validated with expression-validate.
    The expression must exist in expression.yaml.  Please use cwl-ica expression-init to add this expression to expression.yaml.
    We will also run a validation on the expression before syncing.

Options:
    --expression-path=<the expression path>                         Required, the path to the cwl expression

Example:
    cwl-ica expression-sync --expression-path "expressions/flatten_array_file/1.0.0/flatten_array_file__1.0.0.cwl"
    """

    # Overwrite global, get expressions directory
    item_yaml_path = get_expression_yaml_path()

    item_type_key = "expressions"   # Set in subclass
    item_type = "expression"       # Set in subclass

    def __init__(self, command_argv):
        # Call super class
        super(ExpressionSync, self).__init__(command_argv,
                                             update_projects=False,
                                             item_dir=get_expressions_dir(),
                                             item_yaml_path=get_expression_yaml_path(),
                                             item_type_key="expressions",
                                             item_type="expression",
                                             item_suffix="cwl")

    def check_args(self):
        """
        Checks --expression-path exists
        :return:
        """
        # Check --expression-path argument
        cwl_path = self.args.get("--expression-path", None)

        if cwl_path is None:
            logger.error("--expression-path not specified")
            raise CheckArgumentError

        # Convert to path type
        cwl_path = Path(cwl_path)

        self.cwl_file_path = cwl_path

        if not cwl_path.is_file():
            logger.error(f"--expression-path argument \"{cwl_path} could not be found")
            raise CheckArgumentError

        # Get the name and version attributes
        self.set_name_and_version_from_file_path()

    @staticmethod
    def get_project_ica_item_list(project):
        """
        Not relevant for expressions
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
        return ItemExpression.from_dict(item_dict)
