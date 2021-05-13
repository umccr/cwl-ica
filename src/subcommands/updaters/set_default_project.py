#!/usr/bin/env python3

"""
Updates the default project through the conda env var CWL_ICA_DEFAULT_PROJECT
"""

from classes.command import Command
from utils.conda import get_conda_activate_dir
from utils.logging import get_logger
from pathlib import Path
from argparse import ArgumentError
from utils.repo import get_project_yaml_path, read_yaml
from utils.errors import CheckArgumentError, ProjectNotFoundError

EMAIL_REGEX = r"^(\w|\.|\_|\-)+[@](\w|\_|\-|\.)+[.]\w{2,3}$"
CWL_ICA_REPO_ACTIVATE_D_FILENAME = "cwl-ica-repo-path.sh"

logger = get_logger()


class SetDefaultProject(Command):
    """Usage:
    cwl-ica [options] set-default-project help
    cwl-ica [options] set-default-project (--project-name=<"your_project">)

Description:
    Set the default project by specifying the project name.  Project must be registered in `<CWL_ICA_REPO_PATH>/config/project.yaml`

Options:
    --project-name=<project name>          Required, the project name to become the default project name

Example:
    cwl-ica set-default-project --project-name "project name"
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise each of our parameters
        self.project_name = None

        # Check help
        self.check_length(command_argv)

        # Check if help has been called
        if self.args["help"]:
            self._help()

        # Confirm 'required' arguments are present and valid
        try:
            self.check_args()
        except ArgumentError:
            self._help(fail=True)

        # Confirm project already exists in project.yaml
        # Get project yaml dict
        project_yaml_path = get_project_yaml_path(non_existent_ok=False)  # This will fail if project does not exist

        project_list = read_yaml(project_yaml_path).get('projects', [])

        for project in project_list:
            # Make sure projectname does exist
            project_name = project.get("project_name", None)
            if project_name == self.project_name:
                break
        else:
            logger.error(f"Project \"{self.project_name}\" must first be created in \"{project_yaml_path}\"")
            raise ProjectNotFoundError

    def __call__(self):
        # Write to conda repo
        activate_dir = get_conda_activate_dir()

        project_activate_path = Path(activate_dir) / "default_project.sh"

        with open(project_activate_path, 'w') as project_h:
            project_h.write(f"export CWL_ICA_DEFAULT_PROJECT=\"{self.project_name}\"\n")

    def check_args(self):
        """
        Perform the following checks:
        * --project-name is defined
        :return:
        """
        # Check project name is defined
        project_arg = self.args.get("--project-name", None)
        if project_arg is None:
            logger.error("Please specify --project-name")
            raise CheckArgumentError
        self.project_name = project_arg
