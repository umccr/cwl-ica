#!/usr/bin/env

"""
Add a category to a expression
"""

from subcommands.updaters.add_maintainer import AddMaintainer
from utils.repo import get_expressions_dir
from utils.errors import CheckArgumentError
from utils.logging import get_logger
from pathlib import Path

logger = get_logger()


class AddMaintainerToExpression(AddMaintainer):
    """Usage:
    cwl-ica [options] add-maintainer-to-expression help
    cwl-ica [options] add-maintainer-to-expression (--expression-path /path/to/expression.cwl)
                                                   (--username="maintainer_name")

Description:
    Add a user as a maintainer to a project
    Maintainer must exist in user.yaml, please first run cwl-ica configure-user if this user does not exist
    One may run this command multiple times to specify multiple maintainers of a expression.
    The --username isn't necessarily the maintainer of the software, but the maintainer of the cwl code.

Options:
    --expression-path=<the expression name>               Required, the path to the cwl expression
    --username=<the username>                 Required, the name of the maintainer

Example:
    cwl-ica add-maintainer-to-expression --expression-path "expressions/bwa-index/1.10.1/bwa-index__1.10.1.cwl" --username "Alexis Lucattini"
    """

    def __init__(self, command_argv):
        # Call super class
        super(AddMaintainerToExpression, self).__init__(command_argv,
                                                  item_dir=get_expressions_dir(),
                                                  item_type="expression")

    def check_args(self):
        """
        Checks --expression-name is defined and exists, check --username is defined and exists
        :return:
        """
        # Check --expression-path argument
        expression_path = self.args.get("--expression-path", None)

        if expression_path is None:
            logger.error("--expression-path not specified")
            raise CheckArgumentError

        self.cwl_file_path = Path(expression_path).absolute()

        # Get maintainer
        username = self.args.get("--username", None)
        if username is None:
            logger.error("--username not specified")
            raise CheckArgumentError
        self.username = username