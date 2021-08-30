#!/usr/bin/env python3

"""
Create a markdown help page for this tool

"""


from utils.logging import get_logger
from subcommands.github_actions.create_markdown_file import CreateMarkdownFile
from argparse import ArgumentError
from utils.repo import get_tools_dir, get_tool_yaml_path
from utils.errors import CheckArgumentError, ItemNotFoundError
from pathlib import Path
from classes.item_tool import ItemTool
from utils.miscell import get_name_version_tuple_from_cwl_file_path, \
    get_markdown_file_from_cwl_path, \
    cwl_id_to_path
from utils.repo import read_yaml
from mdutils import MdUtils

logger = get_logger()


class CreateToolMarkdownFile(CreateMarkdownFile):
    """Usage:
    cwl-ica github-actions-create-tool-markdown help
    cwl-ica github-actions-create-tool-markdown (--tool-path="<path-to-cwl-tool>")


Description:
    Create a markdown file for a cwl tool - this script is designed to be called by github actions


Options:
    --tool-path=<tool path>            Creation of the tool path

EnvironmentVariables:
    GITHUB_SERVER_URL                          The server we're running on (probably https://github.com)
    GITHUB_REPOSITORY                          This GitHub repository, probably 'umccr/cwl-ica'

Example
    cwl-ica github-actions-create-tool-markdown --tool-path tools/dragen-germline/3.7.5/dragen-germline__3.7.5.cwl
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv,
                         item_type="tool",
                         item_type_key="tools",
                         items_dir=get_tools_dir())

        # Collect arguments
        self.args: dict = self.get_args(command_argv)

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

    def check_args(self):
        """
        Check --tool-path exists
        Set cwl_file_path, name and version
        Import the item object
        Import the cwl item
        Import the cwl object
        Check env vars
        :return:
        """

        # Check defined and assign properties
        tool_path_arg = self.args.get("--tool-path", None)
        if tool_path_arg is None:
            logger.error("--tool-path not defined")
            raise CheckArgumentError

        # Check tool path is file
        tool_path_arg = Path(tool_path_arg)
        if not tool_path_arg.is_file():
            logger.error(f"--tool-path argument '{tool_path_arg}' does not exist")
            raise CheckArgumentError

        # Get cwl file path
        self.cwl_file_path = tool_path_arg

        # Get markdown path from cwl file path
        self.markdown_path = get_markdown_file_from_cwl_path(self.cwl_file_path)

        # Create markdown directory if it doesn't exist
        if not self.markdown_path.parent.is_dir():
            self.markdown_path.parent.mkdir(parents=True, exist_ok=True)

        # Get item name and item version
        self.item_name, self.item_version = get_name_version_tuple_from_cwl_file_path(self.cwl_file_path,
                                                                                      items_dir=get_tools_dir())

        # Import the item object
        self.import_item_obj()

        # Import the item version object
        self.import_item_version_obj()

        # Get ICA tool versions
        self.projects, self.workflows, self.workflow_versions = self.get_ica_workflow_versions()

        if self.is_markdown_md5sum_match() and self.is_markdown_project_match() and self.is_run_match():
            logger.info(f"Md5sum matches, projects match and runs match. Skipping creation of {self.markdown_path}")
            self.create_markdown = False
            return

        # Import the cwl object
        self.import_cwl_obj()

        # Get the cwl name
        self.cwl_name = cwl_id_to_path(self.cwl_obj.id)


    def import_item_obj(self):
        """
        Import the item object
        :return:
        """
        items_list = [ItemTool.from_dict(tool_dict)
                      for tool_dict in read_yaml(get_tool_yaml_path())["tools"]
                      if tool_dict.get("name") == self.item_name]

        if len(items_list) == 0:
            raise ItemNotFoundError

        self.item_obj: ItemTool = items_list[0]

    def get_uses_section(self, md_file_obj: MdUtils):
        """
        Not implemented in tools
        """
        raise NotImplementedError

    def get_steps_section(self, md_file_obj: MdUtils):
        """
        Not implemented for tools
        """
        raise NotImplementedError

    def get_visual_section(self, md_file_obj: MdUtils):
        """
        Not implemented for tools
        """
        raise NotImplementedError
