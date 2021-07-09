#!/usr/bin/env

"""
Add a category to a workflow
"""

from subcommands.updaters.add_maintainer import AddMaintainer
from utils.repo import get_workflows_dir
from utils.errors import CheckArgumentError
from utils.logging import get_logger
from pathlib import Path

logger = get_logger()


class AddMaintainerToWorkflow(AddMaintainer):
    """Usage:
    cwl-ica [options] add-maintainer-to-workflow help
    cwl-ica [options] add-maintainer-to-workflow (--workflow-path /path/to/workflow.cwl)
                                             (--username="maintainer_name")

Description:
    Add a user as a maintainer to a project
    Maintainer must exist in user.yaml, please first run cwl-ica configure-user if this user does not exist
    One may run this command multiple times to specify multiple maintainers of a workflow.
    The --username isn't necessarily the maintainer of the software, but the maintainer of the cwl code.

Options:
    --workflow-path=<the workflow name>               Required, the path to the cwl workflow
    --username=<the username>                 Required, the name of the maintainer

Example:
    cwl-ica add-maintainer-to-workflow --workflow-path "workflows/bwa-index/1.10.1/bwa-index__1.10.1.cwl" --username "Alexis Lucattini"
    """

    def __init__(self, command_argv):
        # Call super class
        super(AddMaintainerToWorkflow, self).__init__(command_argv,
                                                  item_dir=get_workflows_dir(),
                                                  item_type="workflow")

    def check_args(self):
        """
        Checks --workflow-name is defined and exists, check --username is defined and exists
        :return:
        """
        # Check --workflow-path argument
        workflow_path = self.args.get("--workflow-path", None)

        if workflow_path is None:
            logger.error("--workflow-path not specified")
            raise CheckArgumentError

        self.cwl_file_path = Path(workflow_path).absolute()

        # Get maintainer
        username = self.args.get("--username", None)
        if username is None:
            logger.error("--username not specified")
            raise CheckArgumentError
        self.username = username