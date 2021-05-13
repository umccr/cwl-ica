#!/usr/bin/env python3

"""
Subclass of initialiser
"""

from subcommands.initialisers.initialiser import Initialiser
from utils.logging import get_logger
from pathlib import Path
from classes.item_version_tool import ItemVersionTool
from classes.item_tool import ItemTool
from utils.repo import get_tool_yaml_path, get_tools_dir
from utils.errors import CheckArgumentError


logger = get_logger()


class ToolInitialiser(Initialiser):
    """Usage:
    cwl-ica [options] tool-init help
    cwl-ica [options] tool-init (--tool-path /path/to/tool.cwl)
                                [--projects="project[,additional-projects]"]
                                [--tenants="tenant-name[,additional-tenants]"]
                                [--categories="comma,separated,list"]


Description:
    Add in a tool to 'tool.yaml' in the configuration folder.
    The should have been created with cwl-ica create-tool-from-template and then validated with tool-validate.
    We will also run a validation on the tool.
    For each project listed, a new workflow id is created if no other version of this tool exists.
    A workflow version is also created for non-production projects.
    When --projects=all, --tenants is checked. If --tenants=all or --tenants is not defined and CWL_ICA_DEFAULT_TENANT
    is not defined then all projects across all tenants are def


Options:
    --tool-path=<the tool path>                         Required, the path to the cwl tool
    --projects=<the list of projects>                   Optional, the list of projects
    --tenants=<the list of tenants>                     Optional, the list of tenants
    --categories=<a list of categories for this tool>   A list of categories, a short summary of the project

Environment Variables:
    CWL_ICA_DEFAULT_PROJECT    Can be used as an alternative for --projects.
    CWL_ICA_DEFAULT_TENANT     Used when --projects=all.

Example:
    cwl-ica tool-init --tool-path "tools/samtools-fastq/1.10/samtools-fastq__1.10.cwl"
    cwl-ica tool-init --tool-path "tools/samtools-fastq/1.10/samtools-fastq__1.10.cwl" --projects "development" --categories 'File Format Conversion'
    cwl-ica tool-init --tool-path "tools/samtools-fastq/1.10/samtools-fastq__1.10.cwl" --projects "development,production" --categories 'File Format Conversion,Samtools Subcommands'
    """

    def __init__(self, command_argv):
        # Call super class
        super(ToolInitialiser, self).__init__(command_argv,
                                              update_projects=True,
                                              item_dir=get_tools_dir(),
                                              item_yaml_path=get_tool_yaml_path(non_existent_ok=True),
                                              item_type_key="tools",
                                              item_type="tool",
                                              item_suffix="cwl")

    def __call__(self):
        # Call the super class' call function
        super(ToolInitialiser, self).__call__()

    # Methods implemented in subclass
    def check_args(self):
        """
        Checks --tool-path exists
        For --projects, if set to --all, then checks if --tenants set or CWL_ICA_DEFAULT_TENANT set
        If --projects not set, checks CWL_ICA_DEFAULT_PROJECT
        :return:
        """

        # We will have a name and a version for this tool/expression/workflow etc.

        # Check --tool-path argument
        cwl_path = self.args.get("--tool-path", None)

        if cwl_path is None:
            logger.error("--tool-path not specified")
            raise CheckArgumentError

        # Convert to path type
        cwl_path = Path(cwl_path)

        self.check_cwl_path(cwl_path)

        self.cwl_file_path = cwl_path

        if not cwl_path.is_file():
            logger.error(f"--tool-path argument \"{cwl_path} could not be found")
            raise CheckArgumentError

        # Get the name and version attributes
        self.set_name_and_version_from_file_path()

        # Get tenants
        self.set_tenants_list()

        # Get projects
        self.set_projects_list()

        # Set categories
        self.set_categories_list()

    def create_item_object(self):
        """
        This creates the item object along with the first version of the item
        This also calls create_item_version and assigns item_version attribute
        :return:
        """
        return ItemTool(name=self.name,
                        path=Path(self.name),
                        versions=[self.create_item_version_object()],
                        categories=self.categories_list)

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Read in an item object from a dictionary
        :return:
        """

        return ItemTool.from_dict(item_dict)

    def create_item_version_object(self):
        """
        Create the item version for self.item and assign to item_version
        :return:
        """
        item_version = ItemVersionTool(name=self.version,
                                       path=Path(self.version) / Path(self.cwl_file_path.resolve().name),
                                       md5sum=None,
                                       cwl_file_path=self.cwl_file_path)

        # We need to call the 'item version' to collect the md5sum attribute
        item_version()

        return item_version
