#!/usr/bin/env python3

"""
All create-x-from-template classes will inherit this class and thne update their subfunctions as required
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
from string import ascii_letters, digits
from argparse import ArgumentError
from utils.globals import CWL_ICA_REPO_PATH_ENV_VAR
from utils.repo import get_user_yaml_path, read_yaml, get_tools_dir
from classes.cwl_tool import CWLTool
from utils.errors import UserNotFoundError, CheckArgumentError, InvalidNameError, InvalidVersionError
from semantic_version import Version

logger = get_logger()


class CreateFromTemplate(Command):
    """
    Usage defined in subclass
    """

    def __init__(self, command_argv, suffix="cwl"):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise each of our parameters
        self.name = None
        self.version = None
        self.username = None
        self.user_obj = None
        self.cwl_obj = None
        self.cwl_file_path = None
        self.suffix = suffix

        # Init requirements of subclass
        # Get args
        # Check length / add 'help' attribute if necessary
        # Check args

    def __call__(self):
        # Create directory structure
        self.cwl_file_path = self.get_cwl_file_path()

        if self.cwl_file_path.is_file():
            logger.error(f"File already exists at \"{self.cwl_file_path}\"")
            raise CheckArgumentError

        # Create cwl obj
        self.create_cwl_obj()

        # Call the cwl obj which then populates the file
        self.call_cwl_obj()

    # Functions implemented in subclass
    @staticmethod
    def get_args(command_argv):
        """
        :return:
        """
        raise NotImplementedError

    def check_args(self):
        """
        Check name, version and username are all defined
        :return:
        """
        raise NotImplementedError

    def get_top_dir(self, create_dir=False):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError

    def create_cwl_obj(self):
        """
        Create a cwl obj
        :return:
        """
        raise NotImplementedError

    @staticmethod
    def check_shlex_arg(arg_name, arg_val):
        """
        If argument contains characters outside of A-Z, 0-9, -, _, then fail
        :return:
        """

        illegal_chars = set(arg_val).difference(ascii_letters + digits + "-_")

        if not len(illegal_chars) == 0:
            logger.error("The following illegal characters were found in arg {arg_name}"
                         "{arg_chars}".format(
                            arg_name=arg_name,
                            arg_chars=", ".join(["\"%s\"" % char for char in illegal_chars])
                         ))
            raise InvalidNameError

    @staticmethod
    def check_shlex_version_arg(arg_name, arg_val):
        """
        Check the version arg is good
        :param arg_name:
        :param arg_val:
        :return:
        """

        version_is_good = True

        try:
            Version.parse(arg_val)
        except ValueError:
            version_is_good = False

        if not version_is_good:
            logger.error("Was not able to parse {arg_val} as a version for parameter {arg_name}".format(
                            arg_name=arg_name,
                            arg_val=arg_val
                         ))
            raise InvalidVersionError

    def set_user_obj(self):
        """
        Checks that --username is in user_yaml_path
        :return:
        """

        # Check user yaml
        user_yaml_path = get_user_yaml_path()
        user_list = read_yaml(user_yaml_path)['users']

        # User dict
        for user in user_list:
            username = user.get("username", None)
            if username == self.username:
                self.user_obj = user
                break
        else:
            logger.error(f"Could not find \"{self.username}\" in {user_yaml_path}. "
                         f"Please configure user with cwl-ica configure-user")
            raise UserNotFoundError

    def get_cwl_file_path(self):
        """
        Returns file under tools/<tool-name>/<tool-version>/<tool-name>-<tool-version>.cwl
        :return:
        """

        # Get directory
        items_path = self.get_top_dir(create_dir=True)

        # Get tool name
        item_path = Path(items_path) / \
                        Path(self.name) / \
                        Path(self.version) / \
                        Path(self.name + "__" + self.version + "." + self.suffix)

        # Create tool name path
        if not item_path.parent.is_dir():
            item_path.parent.mkdir(parents=True)

        # Return tool path
        return item_path

    def call_cwl_obj(self):
        """
        create the cwl_obj - used in call
        :return:
        """
        # Calls the cwl_obj attribute
        self.cwl_obj()
