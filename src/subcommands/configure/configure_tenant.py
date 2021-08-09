#!/usr/bin/env python3

"""
Configure the tenant.yaml inside the config directory

The two options are tenant-id and tenant-name.

If tenant.yaml already exists inside the configuration directory just append the tenant name and id to the list.

The tenant.yaml file should like this

- tenant_id: "YXDZ...1"
  tenant_name: "UMCCR"
- tenant_id: "YXDZ...2"
  tenant_name: "UMCCR-dev"

Although having to configure tenants seems unnecessary, there may be usecases where distinguishing between tenant ids
becomes very useful when an organisation has multiple tenants or when it comes to adding in a new project from another tenant.
"""

from ruamel.yaml.comments import CommentedMap as OrderedDict
from classes.command import Command
from utils.logging import get_logger
from docopt import docopt
from pathlib import Path
from utils.yaml import dump_yaml
from argparse import ArgumentError
from utils.repo import get_tenant_yaml_path,  read_yaml
from utils.conda import get_conda_activate_dir
from utils.errors import TenantExistsError, CheckArgumentError

logger = get_logger()


class ConfigureTenant(Command):
    """Usage:
    cwl-ica [options] configure-tenant help
    cwl-ica [options] configure-tenant (--tenant-id="<tenant_id>")
                                       (--tenant-name="<tenant_name>")
                                       [--set-as-default]

Description:
    Configure the tenant.yaml.  Please check "${CWL_ICA_REPO_PATH}/config/tenant.yaml" first to
    see if you need to update this file. Run this command multiple times to populate the file with multiple tenants

Options:
    --tenant-id=<tenant-id>         The tenant id
    --tenant-name=<your name>       The tenant name
    --set-as-default                Set as the default tenant  (Can be done later through set default tenant, if no other tenant exists, this parameter is not necessary)

Example:
    cwl-ica configure-tenant --tenant-id "abcdef" --tenant-name "UMCCR-dev"
    cwl-ica configure-tenant --tenant-id "ghixyz" --tenant-name "UMCCR" --set-as-default
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise each of our parameters
        self.tenant_id = None
        self.tenant_name = None
        self.is_default = False

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
        tenant_yaml_path = get_tenant_yaml_path(non_existent_ok=True)

        if not tenant_yaml_path.is_file():
            tenant_list = []
        else:
            logger.debug("Reading in tenants")
            tenant_list = read_yaml(tenant_yaml_path).get('tenants', [])

        if len(tenant_list) == 0:
            logger.debug("Couldn't find any tenants, setting this tenant as the default tenant")
            self.is_default = True

        logger.debug("Iterating through existing tenants")
        for tenant in tenant_list:
            # Make sure tenant id and tenant name are unique
            tenant_id = tenant.get("tenant_id", None)
            logger.debug(f"Got tenant id of \"{tenant_id}")
            tenant_name = tenant.get("tenant_name", None)
            logger.debug(f"Got tenant name of \"{tenant_name}")
            if tenant_name == self.tenant_name:
                logger.error(f"Tenant name \"{tenant_name}\" already exists in \"{tenant_yaml_path}\"")
                raise TenantExistsError
            if tenant_name == self.tenant_name:
                logger.error(f"Tenant id \"{tenant_id}\" already exists in \"{tenant_yaml_path}\"")
                raise TenantExistsError

        # Add in tenant id and tenant name to tenant yaml dict
        tenant_list.append(OrderedDict(
            {
                "tenant_id": self.tenant_id,
                "tenant_name": self.tenant_name
            }
        ))

        tenant_dict = {
            "tenants": tenant_list
        }

        # Write out tenant
        logger.debug(f"Writing tenant.yaml of length \"{len(tenant_list)}\" to \"{tenant_yaml_path}\"")
        logger.info(f"Adding \"{self.tenant_name}\" to \"{tenant_yaml_path}\"")
        with open(tenant_yaml_path, 'w') as tenant_h:
            dump_yaml(tenant_dict, tenant_h)
        # Set default
        if self.is_default:
            logger.info(f"Setting this tenant (name: \"{self.tenant_name}\", id: \"{self.tenant_id}\" as default")
            logger.info("You will need to reactivate your conda environment for this to take effect")
            # Create a tenant.sh in the conda activate.d dir
            activate_dir = get_conda_activate_dir()

            tenant_activate_path = Path(activate_dir) / Path("default_tenant.sh")

            with open(tenant_activate_path, 'w') as tenant_h:
                tenant_h.write(f"export CWL_ICA_DEFAULT_TENANT=\"{self.tenant_name}\"\n")


    @staticmethod
    def get_args(command_argv):
        """
        :return:
        """
        # Get arguments from commandline
        return docopt(__class__.__doc__, argv=command_argv, options_first=False)

    def check_args(self):
        """
        Perform the following checks:
        * --tenant-id is defined
        * --tenant-name is defined
        * ENV VAR: CWL_ICA_REPO_PATH exists and points to an existing repository
        :return:
        """
        # Check tenant-id is present
        tenant_id_arg = self.args.get("--tenant-id", None)
        if tenant_id_arg is None:
            logger.error("Please specify --tenant-id")
            raise CheckArgumentError
        self.tenant_id = tenant_id_arg

        # Check tenant-name is present
        tenant_name_arg = self.args.get("--tenant-name", None)
        if tenant_name_arg is None:
            logger.error("Please specify --tenant-name")
            raise CheckArgumentError
        self.tenant_name = tenant_name_arg

        # Check set-as-default present
        set_default_arg = self.args.get("--set-as-default", False)
        if set_default_arg:
            self.is_default = True
