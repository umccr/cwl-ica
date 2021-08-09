#!/usr/bin/env

"""
Given a tool, expression or workflow, add a maintainer scope to an existing tool, expression or workflow
"""

from classes.command import Command
from utils.repo import read_yaml, get_user_yaml_path
from utils.logging import get_logger
from utils.errors import CheckArgumentError, UserNotFoundError, ItemDirectoryNotFoundError, MultipleAuthorsError
import fileinput

logger = get_logger()


class AddMaintainer(Command):
    """
    Usage defined in subclass
    """

    def __init__(self, command_argv, item_dir=None, item_type=None):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise each of our parameters
        self.cwl_file_path = None
        self.username = None
        # Get item types
        self.item_dir = item_dir
        self.item_type = item_type

        # Check if help has been called
        if self.args["help"]:
            self._help()

        # Confirm 'required' arguments are present and valid
        try:
            self.check_args()
        except CheckArgumentError:
            self._help(fail=True)

        # Get user object
        self.user_obj = self.get_user_obj()

    def __call__(self):
        """
        Add the 'maintainer' tag
        :return:
        """
        logger.info(f"Updating {self.item_type} '{self.cwl_file_path}' to acknowledge maintainer '{self.username}'")
        self.update_file()
        logger.info(f"Update complete")

    def get_user_obj(self):
        """
        Get the user object from user.yaml
        :return:
        """

        for user in read_yaml(get_user_yaml_path())["users"]:
            if user.get("username") == self.username:
                return user
        logger.error(f"Couldn't find user in {get_user_yaml_path()}")
        raise UserNotFoundError

    def validate_directory(self):
        """
        Confirm file is in the right directory
        :return:
        """
        if self.item_dir not in self.cwl_file_path.parents:
            logger.error(f"Expected to find {self.cwl_file_path} under {self.item_dir}")
            raise ItemDirectoryNotFoundError

    def update_file(self):
        """
        Update the file such that the maintainer user obj goes just under the author

        i.e

        from

        # Metadata
        s:author:
          class: s:Person
          s:name: Alexis Lucattini
          s:email: Alexis.Lucattini@umccr.org
          s:identifier: https://orcid.org/0000-0001-9754-647X

        to

        # Metadata
        s:author:
          class: s:Person
          s:name: Alexis Lucattini
          s:email: Alexis.Lucattini@umccr.org
          s:identifier: https://orcid.org/0000-0001-9754-647X

        s:maintainer:
          class: s:Person
          s:name: New User
          s:email: new.user@email.com
        :return:
        """
        in_authorship = False
        found_authorship = False

        for line in fileinput.input(files=self.cwl_file_path, inplace=True):
            print(line.rstrip())
            if line.strip() == "s:author:":
                if found_authorship:
                    logger.error("Don't know what to do with two authors")
                    raise MultipleAuthorsError
                in_authorship = True
                found_authorship = True
            if in_authorship and line.strip() == "":
                # Make sure we only go through this once
                in_authorship = False
                # Add maintainer
                print("s:maintainer:")
                print("  class: s:Person")
                print(f"  s:name: {self.user_obj.get('username')}")
                print(f"  s:email: {self.user_obj.get('email')}")
                if self.user_obj.get('identifier', None) is not None:
                    print(f"  s:identifier: {self.user_obj.get('identifier')}")
                # Print blank line
                print()

        if not found_authorship:
            logger.error("Could not find 'author' attribute. Cannot add maintainer without author")
            raise UserNotFoundError

    def check_args(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError
