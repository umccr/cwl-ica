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
from docopt import docopt
from pathlib import Path
import re
import requests
from urllib.parse import urlparse
from argparse import ArgumentError
from utils.repo import get_user_yaml_path, read_yaml
from utils.errors import UserExistsError, CheckArgumentError
from ruamel.yaml.comments import CommentedMap as OrderedDict
from utils.yaml import dump_yaml


EMAIL_REGEX = r"^(\w|\.|\_|\-)+[@](\w|\_|\-|\.)+[.]\w{2,3}$"
CWL_ICA_REPO_ACTIVATE_D_FILENAME = "cwl-ica-repo-path.sh"

logger = get_logger()


class ConfigureUser(Command):
    """Usage:
    cwl-ica [options] configure-user help
    cwl-ica [options] configure-user (--username=<"your_name">)
                                     (--email=<"your_email">)
                                     [--identifier=<"your_orcid_url">]
                                     [--set-as-default]


Description:
    Set the username, and user's email and user orcid identifier inside <CWL_ICA_REPO_PATH>/config/user.yaml
    The username, user email and identifier are present in the label of each tool and workflow.

Options:
    --username=<your name>          Required, your name
    --email=<your email>            Required, your email
    --identifier=<your orcid id>    Optional, your https://orcid.org/ url
    --set-as-default                Optional, set this user as your default user (Can be done later through cwl-ica set-default-user, if no other user exists, this parameter is not necessary)

Example:
    cwl-ica configure-user --username "Alexis Lucattini" --email "Alexis.Lucattini@umccr.org"
    cwl-ica configure-user --username "Alexis Lucattini" --email "Alexis.Lucattini@umccr.org" --identifier "https://orcid.org/0000-0001-9754-647X"
    cwl-ica configure-user --username "New User" --email "New.User@umccr.org" --set-as-default
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise each of our parameters
        self.username = None
        self.email = None
        self.identifier = None
        self.user_yaml_dict = None
        self.default = False

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
        # Get user yaml dict
        user_yaml_path = get_user_yaml_path(non_existent_ok=True)

        logger.debug(f"Found yaml path to be \"{user_yaml_path}\"")
        if not user_yaml_path.is_file():
            user_list = []
        else:
            logger.debug("Reading in yaml file")
            user_list = read_yaml(user_yaml_path).get('users', [])

        for user in user_list:
            # Make sure username does not yet exist here
            username = user.get("username", None)
            if username == self.username:
                logger.error(f"Username \"{username}\" has already been created in \"{user_yaml_path}\"")
                raise UserExistsError

        # Set user object
        user_obj = OrderedDict({
            "username": self.username,
            "email": self.email
        })

        # Add in identifier if it exists
        if self.identifier is not None:
            user_obj["identifier"] = self.identifier

        user_list.append(user_obj)

        user_dict = {
            "users": user_list
        }

        # Write out yaml
        logger.info(f"Adding \"{self.username}\" to \"{user_yaml_path}\"")
        with open(user_yaml_path, 'w') as users_h:
            dump_yaml(user_dict, users_h)

        if self.default:
            logger.info("Exporting default user to activate.d directory")
            logger.info("You will need to reactivate your conda environment for this to take effect")
            activate_dir = get_conda_activate_dir()

            user_activate_path = Path(activate_dir) / "default_user.sh"

            with open(user_activate_path, 'w') as user_h:
                user_h.write(f"export CWL_ICA_DEFAULT_USER=\"{self.username}\"\n")

    def check_args(self):
        """
        Perform the following checks:
        * --username is defined
        * --email is an email
        * --identifier is a url
        :return:
        """
        # Check username is defined
        username_arg = self.args.get("--username", None)
        logger.debug(f"Got username to be \"{username_arg}\"")
        if username_arg is None:
            logger.error("Please specify --username")
            raise CheckArgumentError
        self.username = username_arg

        # Check email is defined
        email_arg = self.args.get("--email", None)
        logger.debug(f"Got email to be \"{email_arg}\"")
        if email_arg is None:
            logger.error("Please specify --email")
            raise CheckArgumentError
        # Check email matches regex
        if re.compile(EMAIL_REGEX).match(email_arg) is None:
            logger.error("--email \"{email}\" is not a proper email address".format(email=email_arg))
            raise CheckArgumentError
        self.email = email_arg

        # Check orcid url is a valid url
        orcid_arg = self.args.get("--identifier", None)
        logger.debug(f"Got orcid arg to be \"{orcid_arg}\"")
        if orcid_arg is not None:
            url_parse_obj = urlparse(orcid_arg)

            # Check scheme is 'https'
            if not url_parse_obj.scheme == "https" or not url_parse_obj.netloc == "orcid.org":
                logger.error(f"--identifier must be a link to https://orcid.org but got {orcid_arg} instead")
                raise CheckArgumentError

            # Check valid url
            logger.info("Checking orcid ID exists")
            status_code = requests.get(orcid_arg).status_code
            if not status_code == 200:
                logger.error(f"Could not find url {orcid_arg}. Got status code {status_code}")
                raise CheckArgumentError

            # Assign to self
            self.identifier = orcid_arg

        # Check --set-as-default parameter
        set_as_default_arg = self.args.get("--set-as-default", False)
        logger.info(f"Got set as default arg to be \"{set_as_default_arg}\"")
        if set_as_default_arg:
            self.default = True
