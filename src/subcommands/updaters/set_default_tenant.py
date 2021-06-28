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
from argparse import ArgumentError
from utils.globals import CWL_ICA_REPO_PATH_ENV_VAR
from utils.repo import get_tenant_yaml_path, read_yaml
from utils.errors import CheckArgumentError, TenantNotFoundError

EMAIL_REGEX = r"^(\w|\.|\_|\-)+[@](\w|\_|\-|\.)+[.]\w{2,3}$"
CWL_ICA_REPO_ACTIVATE_D_FILENAME = "cwl-ica-repo-path.sh"

logger = get_logger()


class SetDefaultTenant(Command):
    """Usage:
    cwl-ica [options] set-default-tenant help
    cwl-ica [options] set-default-tenant (--tenant-name=<"tenant_name">)


Description:
    Set the default tenant by specifying the tenant name.  Tenant must be registered in `<CWL_ICA_REPO_PATH>/config/tenant.yaml`

Options:
    --tenant-name=<tenant name>          Required, the tenant name to become the default tenant name

Example:
    cwl-ica set-default-tenant --tenant-name "tenant name"
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise each of our parameters
        self.tenant_name = None

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

        # Confirm user already exists in user.yaml
        # Get user yaml dict
        tenant_yaml_path = get_tenant_yaml_path(non_existent_ok=False)  # This will fail if tenant does not exist

        tenant_list = read_yaml(tenant_yaml_path).get('tenants', [])

        for tenant in tenant_list:
            # Make sure tenantname does exist
            tenant_name = tenant.get("tenant_name", None)
            if tenant_name == self.tenant_name:
                break
        else:
            logger.error(f"Username \"{self.tenant_name}\" must first be created in \"{tenant_yaml_path}\""
                         f"You can view the list of registered tenants through the 'cwl-ica list-tenants' command")
            raise TenantNotFoundError

    def __call__(self):
        logger.info(f"Setting \"{self.tenant_name}\" in conda activate.d directory")
        # Write to conda repo
        activate_dir = get_conda_activate_dir()

        tenant_activate_path = Path(activate_dir) / "default_tenant.sh"

        with open(tenant_activate_path, 'w') as tenant_h:
            tenant_h.write(f"export CWL_ICA_DEFAULT_TENANT=\"{self.tenant_name}\"\n")

        logger.info(
            "Default tenant updated, please deactivate and reactivate your conda environment to complete the process")

    def check_args(self):
        """
        Perform the following checks:
        * --tenant-name is defined
        :return:
        """
        # Check tenant name is defined
        tenant_arg = self.args.get("--tenant-name", None)
        logger.debug(f"Got \"{tenant_arg}\" as default tenant")
        if tenant_arg is None:
            logger.error("Please specify --tenant-name")
            raise CheckArgumentError
        self.tenant_name = tenant_arg
