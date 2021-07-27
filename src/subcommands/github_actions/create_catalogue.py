#!/usr/bin/env python3

"""
Create the catalogue to point to all of the markdown files

Iterates through expression objects, tool objects and workflow objects

Initialises a workflow header and toc

Goes through all expressions names and lists versions with paths to help page and file path

Ditto for tools and categories but also adds in categories
"""

from classes.command import Command
from utils.logging import get_logger
from utils.repo import read_yaml, get_expression_yaml_path, get_tool_yaml_path, get_workflow_yaml_path

from pathlib import Path
from typing import Optional, List
from classes.item_expression import ItemExpression
from classes.item_tool import ItemTool
from classes.item_workflow import ItemWorkflow
from classes.item import Item
from classes.item_version import ItemVersion
from mdutils import MdUtils
from subcommands.github_actions.create_markdown_file import add_toc_line
from utils.miscell import get_markdown_file_from_cwl_path
from os.path import relpath

logger = get_logger()

class CreateCatalogue(Command):
    """Usage:
    cwl-ica [options] github-actions-create-catalogue help
    cwl-ica [options] github-actions-create-catalogue [--output-path=<"path to output file">]
                                                      [--title=<"name of catalogue">]

Description:
    Create the markdown catalogue that points to the help docs for each cwl expression, tool and workflow

Options:
    --output-path=<output path>          Optional defaults to 'cwl-ica-catalogue.md'
    --title=<catalogue title>            Optional defaults to 'UMCCR CWL-ICA Catalogue'

Example:
    cwl-ica github-actions-create-catalogue --output-path cwl-ica-catalogue.md
    """

    DEFAULT_OUTPUT_PATH = "cwl-ica-catalogue.md"
    DEFAULT_TITLE = "UMCCR CWL-ICA Catalogue"

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise values
        self.output_path = None  # type: Optional[Path]
        self.title = None  # type: Optional[str]
        self.expressions = None  # type: Optional[List[ItemExpression]]
        self.tools = None  # type: Optional[List[ItemTool]]
        self.workflows = None  # type: Optional[List[ItemWorkflow]]
        self.md_file_obj = None  # type: Optional[MdUtils]

        # Check args
        self.check_args()

    def __call__(self):
        """
        Just run through this
        :return:
        """

        logger.info("Getting the header section")
        self.md_file_obj = self.get_header_section(self.md_file_obj)

        logger.info("Getting the expressions section")
        self.md_file_obj = self.get_section("Expressions", self.md_file_obj, self.expressions)

        logger.info("Getting the tools section")
        self.md_file_obj = self.get_section("Tools", self.md_file_obj, self.tools)

        logger.info("Getting the workflows section")
        self.md_file_obj = self.get_section("Workflows", self.md_file_obj, self.workflows)

        # Write out md file object
        logger.info("Writing out markdown file")
        self.md_file_obj.create_md_file()

    def check_args(self):
        """
        Check if output path arg is set
        :return:
        """

        # Set output_path
        output_path_arg = self.args.get("--output-path", None)

        # Check if output arg is set
        if output_path_arg is None:
            self.output_path = Path(self.DEFAULT_OUTPUT_PATH)
        else:
            self.output_path = Path(output_path_arg)

        # Set title
        title_arg = self.args.get("--title", None)

        # Check if output arg is set
        if title_arg is None:
            self.title = self.DEFAULT_TITLE
        else:
            self.title = title_arg

        # Initialise mdutils
        self.md_file_obj = MdUtils(file_name=str(self.output_path), title=self.title)

        # Get expressions, tools and workflows objects
        self.expressions = [ItemExpression.from_dict(expression_dict)
                            for expression_dict in read_yaml(get_expression_yaml_path())["expressions"]]

        self.tools = [ItemTool.from_dict(tool_dict)
                      for tool_dict in read_yaml(get_tool_yaml_path())["tools"]]

        self.workflows = [ItemWorkflow.from_dict(workflow_dict)
                          for workflow_dict in read_yaml(get_workflow_yaml_path())["workflows"]]

    @staticmethod
    def get_header_section(md_file_obj: MdUtils) -> MdUtils:
        """
        Get the header section of the catalogue - literally just a manually generated table of contents
        :param md_file_obj:
        :return:
        """

        md_file_obj.new_header(level=2, title="Table of Contents", add_table_of_contents='n')

        md_file_obj = add_toc_line(md_file_obj, header_name="Expressions", link_text="Expressions")
        md_file_obj = add_toc_line(md_file_obj, header_name="Tools", link_text="Tools")
        md_file_obj = add_toc_line(md_file_obj, header_name="Workflows", link_text="Workflows")

        return md_file_obj

    def get_version_as_dot_point(self, md_file_obj: MdUtils, version: ItemVersion) -> MdUtils:
        """
        For a given version, get the
        :param md_file_obj:
        :param version:
        :return:
        """

        version_markdown_path = get_markdown_file_from_cwl_path(version.cwl_file_path).absolute()
        if not version_markdown_path.is_file():
            markdown_path_text = f"{version.name} :construction:"
        else:
            markdown_path_text = f"{version.name}"

        md_file_obj.new_line("  - {}".format(
            md_file_obj.new_inline_link(link=relpath(version_markdown_path, self.output_path.parent),
                                        text=markdown_path_text)
        ),
            wrap_width=0)

        return md_file_obj

    def get_section(self, section_name:str, md_file_obj: MdUtils, items) -> MdUtils:
        """
        Get the expressions, tools or workflows section
        :param section_name:
        :param md_file_obj:
        :param items:
        :return:
        """

        # Get the header
        md_file_obj.new_header(level=2, title=section_name, add_table_of_contents='n')

        # Add a mini TOC
        md_file_obj.new_header(level=3, title=f"{section_name} ToC", add_table_of_contents='n')

        item: Item
        for item in items:
            md_file_obj = add_toc_line(md_file_obj, header_name=item.name, link_text=item.name)

        # New line between toc and section
        md_file_obj.new_line("\n")

        # Now add items and each item version
        for item in items:
            # Add header
            md_file_obj.new_header(level=3, title=item.name, add_table_of_contents='n')

            # Add categories
            if section_name in ["tools", "workflows"]:
                if not len(item.categories) == 0:
                    md_file_obj.new_header(level=4, title="Categories", add_table_of_contents='n')
                    for category in item.categories:
                        md_file_obj.new_line(f"- {category}")
                    md_file_obj.new_line("\n")

            # Add versions
            item_version: ItemVersion
            for item_version in item.versions:
                version_markdown_path = get_markdown_file_from_cwl_path(item_version.cwl_file_path).absolute()
                md_file_obj.new_line("- {}".format(
                    md_file_obj.new_inline_link(link=relpath(version_markdown_path, self.output_path.parent),
                                                text=item_version.name)
                    ),
                    wrap_width=0
                )

            # New line between tools
            md_file_obj.new_line("\n")

        return md_file_obj