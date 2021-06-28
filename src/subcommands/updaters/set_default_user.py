#!/usr/bin/env python3

"""
Updates the default user through the conda env var CWL_ICA_DEFAULT_USER
"""

from classes.command import Command
from utils.conda import get_conda_activate_dir
from utils.logging import get_logger
from docopt import docopt
from pathlib import Path
import re
import requests
from urllib.parse import urlparse
from ruamel.yaml import YAML, RoundTripDumper, dump as yaml_dump
from utils.globals import CWL_ICA_REPO_PATH_ENV_VAR
from utils.repo import get_user_yaml_path, read_yaml
from utils.errors import UserNotFoundError, CheckArgumentError

EMAIL_REGEX = r"^(\w|\.|\_|\-)+[@](\w|\_|\-|\.)+[.]\w{2,3}$"
CWL_ICA_REPO_ACTIVATE_D_FILENAME = "cwl-ica-repo-path.sh"

logger = get_logger()


class SetDefaultUser(Command):
    """Usage:
    cwl-ica [options] set-default-user help
    cwl-ica [options] set-default-user (--username=<"your_name">)


Description:
    Set the default user by specifying the username.  User must be registered in `<CWL_ICA_REPO_PATH>/config/user.yaml`

Options:
    --username=<your name>          Required, your name

Example:
    cwl-ica set-default-user --username "New User"
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise each of our parameters
        self.username = None

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
        except CheckArgumentError:
            self._help(fail=True)

        # Confirm user already exists in user.yaml
        # Get user yaml dict
        user_yaml_path = get_user_yaml_path(non_existent_ok=False)  # This will fail if user does not exist

        user_list = read_yaml(user_yaml_path).get('users', [])

        for user in user_list:
            # Make sure username does exist
            username = user.get("username", None)
            if username == self.username:
                break
        else:
            logger.error(f"Username \"{self.username}\" must first be created in \"{user_yaml_path}\"")
            raise UserNotFoundError

    def __call__(self):
        logger.info(f"Setting \"{self.username}\" as default tenant in conda activate.d directory")
        # Write to conda repo
        activate_dir = get_conda_activate_dir()

        user_activate_path = Path(activate_dir) / "default_user.sh"

        with open(user_activate_path, 'w') as user_h:
            user_h.write(f"export CWL_ICA_DEFAULT_USER=\"{self.username}\"\n")

        logger.info(
            "Default user updated, please deactivate and reactivate your conda environment to complete the process")

    def check_args(self):
        """
        Perform the following checks:
        * --username is defined
        :return:
        """
        # Check username is defined
        username_arg = self.args.get("--username", None)
        logger.debug(f"Got \"{username_arg}\" for --username")
        if username_arg is None:
            logger.error("Please specify --username")
            raise CheckArgumentError
        self.username = username_arg
