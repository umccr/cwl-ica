#!/usr/bin/env python3

"""
List all users registered in <CWL_ICA_REPO_PATH>/config/user.yaml
"""

from classes.command import Command
from utils.logging import get_logger
import pandas as pd
from utils.repo import read_yaml, get_tenant_yaml_path
import sys

logger = get_logger()


class ListTenants(Command):
    """Usage:
    cwl-ica [options] list-tenants help
    cwl-ica [options] list-tenants

Description:
    List all registered tenants in <CWL_ICA_REPO_PATH>/config/tenant.yaml

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
        tenant_yaml_path = get_tenant_yaml_path()

        tenant_list = read_yaml(tenant_yaml_path)['tenants']

        # Create pandas df of  tenant yaml path
        tenant_df = pd.DataFrame(tenant_list)

        # Write tenant to stdout
        tenant_df.to_markdown(sys.stdout, index=False)

    def check_args(self):
        """
        Check if --tenant-name is defined or CWL_ICA_DEFAULT_TENANT is present
        Or if --tenant-name is set to 'all'
        :return:
        """

        # Just make sure the tenant.yaml path exists
        _ = get_tenant_yaml_path()
