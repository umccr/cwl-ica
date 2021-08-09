#!/usr/bin/env python3

"""
Sync a tool to tool.yaml and to any projects set under --projects
"""

from subcommands.sync.sync import Sync
from utils.logging import get_logger
from utils.repo import get_tool_yaml_path, get_tools_dir
from pathlib import Path
from classes.item_tool import ItemTool
from utils.errors import CheckArgumentError


logger = get_logger()


class ToolSync(Sync):
    """Usage:
    cwl-ica [options] tool-sync help
    cwl-ica [options] tool-sync (--tool-path /path/to/tool.cwl)
                                [--projects="project[,additional-projects]"]
                                [--tenants="tenant-name[,additional-tenants]"]
                                [--force]


Description:
    Sync a tool to 'tool.yaml' in the configuration folder
    The tool should have been created with cwl-ica create-tool-from-template and then validated with tool-validate.
    The tool must exist in tool.yaml.  Please use cwl-ica tool-init to add this tool to tool.yaml.
    We will also run a validation on the tool before syncing.
    For each project listed, the workflow version is patched with this version.
    When --projects=all, --tenants is checked. If --tenants=all or --tenants is not defined and CWL_ICA_DEFAULT_TENANT
    is not defined then all projects across all tenants are def


Options:
    --tool-path=<the tool path>                         Required, the path to the cwl tool
    --projects=<the list of projects>                   Optional, the list of projects
    --tenants=<the list of tenants>                     Optional, the list of tenants
    --force                                             Optional, force sync even if modification time is ahead on ICA

Environment Variables:
    CWL_ICA_DEFAULT_PROJECT    Can be used as an alternative for --projects.
    CWL_ICA_DEFAULT_TENANT     Used when --projects=all.

Example:
    cwl-ica tool-sync --tool-path "tools/samtools-fastq/1.10/samtools-fastq__1.10.cwl"
    cwl-ica tool-sync --tool-path "tools/samtools-fastq/1.10/samtools-fastq__1.10.cwl" --projects "development"
    cwl-ica tool-sync --tool-path "tools/samtools-fastq/1.10/samtools-fastq__1.10.cwl" --projects "development,production"
    cwl-ica tool-sync --tool-path "tools/samtools-fastq/1.10/samtools-fastq__1.10.cwl" --projects "all" --tenants "umccr-dev"
    """

    # Overwrite global, get tools directory
    item_yaml_path = get_tool_yaml_path()

    item_type_key = "tools"   # Set in subclass
    item_type = "tool"       # Set in subclass

    def __init__(self, command_argv):
        # Call super class
        super(ToolSync, self).__init__(command_argv,
                                       update_projects=True,
                                       item_dir=get_tools_dir(),
                                       item_yaml_path=get_tool_yaml_path(),
                                       item_type_key="tools",
                                       item_type="tool",
                                       item_suffix="cwl")

    def check_args(self):
        """
        Just make sure that the G
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
            logger.error(f"--tool-path argument \"{cwl_path} could not be found")
            raise CheckArgumentError

        # Get the name and version attributes
        self.set_name_and_version_from_file_path()

        # Get projects
        self.set_projects_list()

        # Check force argument
        if self.args.get("--force", False):
            self.force = True

    @staticmethod
    def get_project_ica_item_list(project):
        """
        Get the project ica item list through projects' ica_tools_list
        :param project:
        :return:
        """
        return project.ica_tools_list

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemTool.from_dict(item_dict)
