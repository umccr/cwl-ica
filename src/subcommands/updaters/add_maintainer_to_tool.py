#!/usr/bin/env

"""
Add a category to a tool
"""

from subcommands.updaters.add_maintainer import AddMaintainer
from utils.repo import get_tools_dir
from utils.errors import CheckArgumentError
from utils.logging import get_logger
from pathlib import Path

logger = get_logger()


class AddMaintainerToTool(AddMaintainer):
    """Usage:
    cwl-ica [options] add-maintainer-to-tool help
    cwl-ica [options] add-maintainer-to-tool (--tool-path /path/to/tool.cwl)
                                             (--username="maintainer_name")

Description:
    Add a user as a maintainer to a project
    Maintainer must exist in user.yaml, please first run cwl-ica configure-user if this user does not exist
    One may run this command multiple times to specify multiple maintainers of a tool.
    The --username isn't necessarily the maintainer of the software, but the maintainer of the cwl code.

Options:
    --tool-path=<the tool name>               Required, the path to the cwl tool
    --username=<the username>                 Required, the name of the maintainer

Example:
    cwl-ica add-maintainer-to-tool --tool-path "tools/bwa-index/1.10.1/bwa-index__1.10.1.cwl" --username "Alexis Lucattini"
    """

    def __init__(self, command_argv):
        # Call super class
        super(AddMaintainerToTool, self).__init__(command_argv,
                                                  item_dir=get_tools_dir(),
                                                  item_type="tool")

    def check_args(self):
        """
        Checks --tool-name is defined and exists, check --username is defined and exists
        :return:
        """
        # Check --tool-path argument
        tool_path = self.args.get("--tool-path", None)

        if tool_path is None:
            logger.error("--tool-path not specified")
            raise CheckArgumentError

        self.cwl_file_path = Path(tool_path).absolute()

        # Get maintainer
        username = self.args.get("--username", None)
        if username is None:
            logger.error("--username not specified")
            raise CheckArgumentError
        self.username = username