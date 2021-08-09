#!/usr/bin/env python3

"""
Configure the conda env to assign the following variables

CWL_ICA_REPO_PATH=/path/to/repository

Then add username and email to <repo_path>/config/user.yaml

First check with the user that the details provided are correct.

Make sure one is not overwriting the current env vars.

All variables are written to ${CONDA_PREFIX}/etc/conda/activate.d/cwl-ica.sh
The variables are unset at ${CONDA_PREFIX}/etc/conda/activate.d/cwl-ica.sh
"""

from classes.command import Command
from utils.conda import get_conda_activate_dir
from utils.logging import get_logger
from pathlib import Path
from argparse import ArgumentError
from utils.globals import CWL_ICA_REPO_PATH_ENV_VAR
from utils.errors import CheckArgumentError

EMAIL_REGEX = r"^(\w|\.|\_|\-)+[@](\w|\_|\-|\.)+[.]\w{2,3}$"
CWL_ICA_REPO_ACTIVATE_D_FILENAME = "cwl-ica-repo-path.sh"

logger = get_logger()


class ConfigureRepo(Command):
    """Usage:
    cwl-ica [options] configure-repo help
    cwl-ica [options] configure-repo (--repo-path=<abs_repo_path>)

Description:
    Configure the path to the repository,
    Path to repo is set in ${CONDA_PREFIX}/etc/conda/activate.d, therefore
    You MUST reactivate the environment after running this command.
    The repository directory must already exist.

Options:
    --repo-path=<abs repo path>     Required, path to local cwl-ica repository

Example:
    cwl-ica configure-repo --repo-path /abs/path/to/cwl-ica/
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise each of our parameters
        self.repository_path = None

        # Check help
        logger.debug("Checking args length")
        self.check_length(command_argv)

        # Check if help has been called
        if self.args["help"]:
            self._help()

        # Confirm 'required' arguments are present and valid
        try:
            logger.debug("Checking args")
            self.check_args()
        except ArgumentError:
            self._help(fail=True)

    def __call__(self):
        # Add repo path to conda init
        logger.info(f"Setting repo path environment variable into "
                    f"conda activate.d directory to \"{self.repository_path}\"")
        logger.info("You will need to reactivate your conda environment for this to take effect")
        self.add_repo_path_to_conda_init()

    def check_args(self):
        """
        Perform the following checks:

        * --repo-path is defined and directory exists
        * --username is defined
        * --email is an email
        :return:
        """
        # Check repository path is defined and a path
        repository_path_arg = self.args.get("--repo-path", None)
        logger.debug(f"Found --repo-path arg to be {repository_path_arg}")
        if repository_path_arg is None:
            logger.error("Please specify --repo-path")
            raise CheckArgumentError
        # Convert repository path to Path object, check directory exists
        repository_path = Path(repository_path_arg)
        if not repository_path.is_dir():
            logger.error(f"--repo-path arg \"{repository_path}\" does not exist")
            raise CheckArgumentError
        self.repository_path = repository_path

    def add_repo_path_to_conda_init(self):
        """
        Add repo path to conda
        :return:
        """
        # Get activate.d dir
        activate_dir = get_conda_activate_dir()

        cwl_ica_activate_d_file_path = Path(activate_dir) / Path(CWL_ICA_REPO_ACTIVATE_D_FILENAME)
        with open(cwl_ica_activate_d_file_path, "w") as file_h:
            file_h.write("export {env_var_name}=\"{repo_path}\"\n".format(
                env_var_name=CWL_ICA_REPO_PATH_ENV_VAR,
                repo_path=self.repository_path.absolute()
            ))


