#!/usr/bin/env python3

"""
This is a subclass of command for validation commands
subclasses include
validate-expression
validate-tool
validate-schema
validate-workflow
"""

from classes.command import Command
from utils.logging import get_logger
from pathlib import Path
from string import ascii_letters, digits
from utils.errors import CWLFileNameError, CheckArgumentError, InvalidVersionError
from semantic_version import Version


logger = get_logger()


class Validate(Command):
    """
    This is the intermediate-class for the validate commander
    While most methods are created by the subclass, we can still assure the same call is completed on each
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super(Validate, self).__init__(command_argv)
        self.cwl_file_path = None
        self.cwl_obj = None
        self.name = None
        self.version = None

    def __call__(self):
        # We just validate obj to call
        self.validate_obj()

    # Defined in subclass
    def import_cwl_obj(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError

    def check_args(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError

    # Common methods
    def check_file(self):
        # Check file exists
        if not self.cwl_file_path.is_file():
            logger.error("Could not validate \"{self.cwl_file_path}\" because file did not exist")

    def split_name_version(self, items_dir):
        """
        Returns name and version, attributes based on path
        :return:
        """

        name_version_path = Path(self.cwl_file_path).absolute().relative_to(items_dir)

        name_version_file_split = name_version_path.name.split("__", 1)

        if len(name_version_file_split) < 2:
            logger.error(f"Could not split name and version from {name_version_path.name}. "
                         f"Please name under {items_dir} as "
                         f"<name>/<version>/<name>__<version>.cwl.")
            raise CWLFileNameError

        name_file = name_version_file_split[0]
        version_file = name_version_file_split[1]
        version_file = Path(version_file).resolve().stem

        name_dir = name_version_path.parent.parent.name
        version_dir = name_version_path.parent.name

        if not name_file == name_dir:
            logger.error(f"CWL file has incorrect naming convention, please name under {items_dir} as"
                         f"<name>/<version>/<name>__<version>.cwl. "
                         f"But got first <name> as {name_dir} and second <name> as {name_file}")
            raise CWLFileNameError

        if not version_file == version_dir:
            logger.error(f"CWL file has incorrect naming convention, please name under {items_dir} as"
                         f"<name>/<version>/<name>__<version>.cwl.  "
                         f"But got first <version> as {version_dir} and second <version> as {version_file}")
            raise CWLFileNameError

        return name_file, version_file

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


    def validate_obj(self):
        """
        Call the cwl_obj to validate it
        :return:
        """
        self.cwl_obj.validate_object()
