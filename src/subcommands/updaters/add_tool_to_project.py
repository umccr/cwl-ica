#!/usr/bin/env python3

"""
Add a tool to a project
"""

from subcommands.updaters.add_to_project import AddToProject
from utils.repo import get_tool_yaml_path, get_tools_dir
from pathlib import Path
from classes.item_tool import ItemTool
from utils.errors import CheckArgumentError
from utils.logging import get_logger

logger = get_logger()


class AddToolToProject(AddToProject):
    """Usage:
    cwl-ica [options] add-tool-to-project help
    cwl-ica [options] add-tool-to-project (--tool-path /path/to/tool.cwl)
                                          [--project="project_name"]

Description:
    Add an existing tool from 'tool.yaml' to a project
    The tool must exist in tool.yaml.  Please use cwl-ica tool-init to add this tool to tool.yaml.
    We will also run a validation on the tool before syncing.
    For each project listed, the workflow version is patched with this version.


Options:
    --tool-path=<the tool path>                         Required, the path to the cwl tool
    --project=<the project to add the workflow to>      Required, the project name

Example:
    cwl-ica add-tool-to-project --tool-path "tools/samtools-fastq/1.10/samtools-fastq__1.10.cwl" --project "development"
    """

    def __init__(self, command_argv):
        # Call super class
        super(AddToolToProject, self).__init__(command_argv,
                                               item_dir=get_tools_dir(),
                                               item_yaml_path=get_tool_yaml_path(),
                                               item_type_key="tools",
                                               item_type="tool",
                                               item_suffix="cwl")

    def check_args(self):
        """
        Checks --tool-path exists
        For --projects, if set to --all, then checks if --tenants set of CWL_ICA_DEFAULT_TENANT set
        If --projects not set, checks CWL_ICA_DEFAULT_PROJECT
        :return:
        """
        # Check --tool-path argument
        cwl_path = self.args.get("--tool-path", None)

        if cwl_path is None:
            logger.error("--tool-path not specified")
            raise CheckArgumentError

        # Convert to path type
        cwl_path = Path(cwl_path)

        self.cwl_file_path = cwl_path

        if not cwl_path.is_file():
            logger.error(f"--tool-path argument \"{cwl_path}\" could not be found")
            raise CheckArgumentError

        # Get the name and version attributes
        self.set_name_and_version_from_file_path()

        # Add project / check project in projects
        project_arg = self.args.get("--project", None)

        if project_arg is None:
            logger.error("--project not specified")
            raise CheckArgumentError

        # Check project argument is in projects -> Adds project object to project
        self.check_project(project_arg)

    def get_project_ica_item_list(self):
        """
        Get the project ica item list through projects' ica_tools_list
        :return:
        """
        return self.project.ica_tools_list

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemTool.from_dict(item_dict)
