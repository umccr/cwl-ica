#!/usr/bin/env python3

"""
List all projects registered in <CWL_ICA_REPO_PATH>/config/projects.yaml
"""

from classes.command import Command
from utils.logging import get_logger
from docopt import docopt
import pandas as pd
from utils.repo import get_tenant_yaml_path, read_yaml, get_project_yaml_path
import os
import sys
from utils.errors import TenantNotFoundError

logger = get_logger()


class ListProjects(Command):
    """Usage:
    cwl-ica [options] list-projects help
    cwl-ica [options] list-projects [--tenant-name=<"tenant_name">]

Description:
    List all available projects, if --tenant-name is not set then tenants from all projects are returned.
    If env var CWL_ICA_DEFAULT_TENANT is set and you wish to view projects across all tenants, set --tenant-name to 'all'

Options:
    --tenant-name=<tenant name>          Optional, filter by tenant-name.

Environment Variables:
    CWL_ICA_DEFAULT_TENANT    Can be used as an alternative for --tenant-name.

Example:
    cwl-ica list-projects --tenant-name "all"
    cwl-ica list-projects --tenant-name "tenant name"
    cwl-ica list-projects
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise values
        self.tenant_name = None

        # Check args
        self.check_args()

    def __call__(self):
        """
        Just run through this
        :return:
        """

        # Check project.yaml exists
        project_yaml_path = get_project_yaml_path()

        project_list = read_yaml(project_yaml_path)['projects']

        # Create pandas df of project yaml path
        project_df = pd.DataFrame(project_list)

        # Write project to stdout
        project_df[["project_name", "project_id", "project_description", "production"]].\
            to_markdown(sys.stdout, index=False)

        # Create a new line character
        print()

    def check_args(self):
        """
        Check if --tenant-name is defined or CWL_ICA_DEFAULT_TENANT is present
        Or if --tenant-name is set to 'all'
        :return:
        """

        tenant_arg = self.args.get("--tenant-name", None)

        # Check if tenant arg is set
        if tenant_arg is None:
            tenant_arg = os.environ.get("CWL_ICA_DEFAULT_TENANT", None)

        # Check if tenant arg is set to all
        if tenant_arg is None or tenant_arg == "all":
            self.tenant_name = None
        else:
            self.tenant_name = tenant_arg

        # If tenant_name is set, make sure it's present in tenant.yaml
        if self.tenant_name is not None:
            tenant_yaml_path = get_tenant_yaml_path()
            tenant_list = read_yaml(tenant_yaml_path)['tenants']
            for tenant in tenant_list:
                if tenant.get("tenant_name", None) == self.tenant_name:
                    break
            else:
                logger.error(f"Tenant name set to \"{self.tenant_name}\" but "
                             f"could not find this tenant name in \"{tenant_yaml_path}\"\n")
                raise TenantNotFoundError

        # Just make sure the project.yaml path exists
        _ = get_project_yaml_path()
