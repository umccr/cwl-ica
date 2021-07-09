#!/usr/bin/env python3

"""
Check a given api-key-script works for a project

1. Import a project object
2. Get api_key_name attribute

Run the subprocess command to confirm the api-key script works
"""

from classes.command import Command
from utils.logging import get_logger
from utils.repo import read_yaml, get_project_yaml_path
from utils.errors import CheckArgumentError, ProjectNotFoundError, CWLApiKeyNotFoundError
from os import environ, access, X_OK
from pathlib import Path
from utils.subprocess_handler import run_subprocess_proc

logger = get_logger()


class ValidateApiKeyScript(Command):
    """Usage:
    cwl-ica [options] validate-api-key-script help
    cwl-ica [options] validate-api-key-script ( --project-name=<name_of_project> )

Description:
    Confirm your api-key script works for a given project, takes the "project_api_key_name" attribute from project.yaml and
    runs the equivalent to the following through subprocess:

    export PROJECT_API_KEY_PATH=project.project_api_key_name
    "${CWL_ICA_API_KEY_SH}"

Example:
    cwl-ica validate-api-key-script --project-name=development_workflows
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise vars
        self.project_name = None

        # Check args
        self.check_args()

        # Get api key name
        self.project_api_key_name = self.get_api_key_name()

        # Check env vars
        if environ.get("CWL_ICA_API_KEY_SH", None) is None:
            logger.error("Could not find env var 'CWL_ICA_API_KEY_SH'")
            raise CWLApiKeyNotFoundError

        self.cwl_api_key_file = Path(environ.get("CWL_ICA_API_KEY_SH"))
        # Check env var points to a file
        if not self.cwl_api_key_file.is_file():
            logger.error(f"Env var CWL_ICA_API_KEY_SH '{self.cwl_api_key_file}' does not point to a file")
            raise CWLApiKeyNotFoundError
        # Check env var is executable
        if not access(self.cwl_api_key_file, X_OK):
            logger.error(f"Env var CWL_ICA_API_KEY_SH '{self.cwl_api_key_file} points to a file, "
                         f"however this file does not have executable permissions for this user")
            raise CWLApiKeyNotFoundError

    def __call__(self):
        """
        Call the subprocess command to check the api key script
        :return:
        """

        # Create a replica of the existing environment, just updating the PROJECT_API_KEY_PATH env var
        new_env = environ.copy()
        new_env["PROJECT_API_KEY_PATH"] = self.project_api_key_name

        # Run CWL_ICA_API_KEY_SH script
        get_api_key_returncode, get_api_key_stdout, get_api_key_stderr = \
            run_subprocess_proc([str(self.cwl_api_key_file)], env=new_env, capture_output=True)

        # Get stdout
        if get_api_key_stdout is not None and get_api_key_returncode == 0:
            logger.info(f"Ran the command {self.cwl_api_key_file} with PROJECT_API_KEY_PATH"
                        f"set to {self.project_api_key_name}")
            logger.info(f"Does this look like the right api-key? Run in --debug mode to confirm")
            logger.info(f"{get_api_key_stdout[0:2]}{'*'*(len(get_api_key_stdout)-4)}{get_api_key_stdout[-3:-1]}")

    def check_args(self):
        """
        Checks done in callback - just config configuration directory exists
        :return:
        """

        # Get project name
        project_name = self.args.get("--project-name", None)

        if project_name is None:
            logger.error("Could not get argument --project-name")
            raise CheckArgumentError

        self.project_name = project_name

    def get_api_key_name(self):
        """
        Get the api key name for a given project
        :return:
        """
        for project_dict in read_yaml(get_project_yaml_path())["projects"]:
            if project_dict.get("project_name") == self.project_name:
                return project_dict.get("project_api_key_name")
        logger.error(f"Could not find project name '{self.project_name}' in project.yaml")
        raise ProjectNotFoundError
