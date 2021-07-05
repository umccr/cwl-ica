#!/usr/bin/env python3

"""
Confirm that all the yamls in config/ are valid yaml files
"""

from classes.command import Command
from utils.logging import get_logger
from utils.repo import read_yaml, \
    get_configuration_path, get_project_yaml_path, get_tenant_yaml_path, get_category_yaml_path, \
    get_user_yaml_path, get_expression_yaml_path,  get_schema_yaml_path,  get_tool_yaml_path, get_workflow_yaml_path
from ruamel.yaml.error import YAMLError
import sys

logger = get_logger()


class ValidateConfigYamls(Command):
    """Usage:
    cwl-ica [options] validate-config-yamls help
    cwl-ica [options] validate-config-yamls

Description:
    Confirm the yaml files in config/ are legitimate.

Example:
    cwl-ica validate-config-yamls
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        self.config_path = None

        # Check args
        self.check_args()

    def __call__(self):
        """
        Validate each yaml is a valid yaml
        :return:
        """

        # Get yamls

        configuration_path = get_configuration_path()
        project_yaml_path = get_project_yaml_path(non_existent_ok=True)
        tenant_yaml_path = get_tenant_yaml_path(non_existent_ok=True)
        category_yaml_path = get_category_yaml_path(non_existent_ok=True)
        user_yaml_path = get_user_yaml_path(non_existent_ok=True)
        expression_yaml_path = get_expression_yaml_path(non_existent_ok=True)
        schema_yaml_path = get_schema_yaml_path(non_existent_ok=True)
        tool_yaml_path = get_tool_yaml_path(non_existent_ok=True)
        workflow_yaml_path = get_workflow_yaml_path(non_existent_ok=True)

        error_count = 0

        for yaml_file in [project_yaml_path, tenant_yaml_path, category_yaml_path,
                          user_yaml_path, expression_yaml_path, schema_yaml_path, tool_yaml_path, workflow_yaml_path]:

            # Check file exists first
            if not yaml_file.is_file():
                continue

            # Now try load it
            try:
                yaml_obj = read_yaml(yaml_file)
                logger.info(f"Loaded {yaml_file} successfully")
            except YAMLError:
                logger.error(f"Could not load {yaml_file}. Please amend the file")
                error_count += 1

        if error_count > 0:
            logger.error(f"{error_count} files were unable to be loaded. Please amend these files before committing")
            sys.exit(1)

    def check_args(self):
        """
        Checks done in callback - just config configuration directory exists
        :return:
        """

        self.config_path = get_configuration_path()