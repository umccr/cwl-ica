#!/usr/bin/env python3

"""
List all users registered in <CWL_ICA_REPO_PATH>/config/user.yaml
"""

from classes.command import Command
from utils.logging import get_logger
from docopt import docopt
import pandas as pd
from utils.repo import read_yaml, get_user_yaml_path
import os
import sys

logger = get_logger()


class ListUsers(Command):
    """Usage:
    cwl-ica [options] list-users help
    cwl-ica [options] list-users

Description:
    List all registered users in <CWL_ICA_REPO_PATH>/config/user.yaml

Example:
    cwl-ica list-users
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Check args
        self.check_args()

    def __call__(self):
        """
        Just run through this
        :return:
        """

        # Check project.yaml exists
        user_yaml_path = get_user_yaml_path()

        user_list = read_yaml(user_yaml_path)['users']

        # Create pandas df of user yaml path
        user_df = pd.DataFrame(user_list)

        # Write user to stdout
        user_df.to_markdown(sys.stdout, index=False)

    def check_args(self):
        """
        Check if --tenant-name is defined or CWL_ICA_DEFAULT_TENANT is present
        Or if --tenant-name is set to 'all'
        :return:
        """

        # Just make sure the user.yaml path exists
        _ = get_user_yaml_path()
