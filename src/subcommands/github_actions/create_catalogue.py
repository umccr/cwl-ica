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
from classes.item_version_expression import ItemVersionExpression
from classes.item_tool import ItemTool
from classes.item_version_tool import ItemVersionTool
from classes.item_workflow import ItemWorkflow
from classes.item_version_workflow import ItemVersionWorkflow
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
        self.md_file_obj = self.get_expressions_section(self.md_file_obj)

        logger.info("Getting the tools section")
        self.md_file_obj = self.get_tools_section(self.md_file_obj)

        logger.info("Getting the workflows section")
        self.md_file_obj = self.get_workflows_section(self.md_file_obj)

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

        md_file_obj.new_header(level=2, title="TOC", add_table_of_contents='n')

        add_toc_line(md_file_obj, header_name="Expressions", link_text="Expressions")
        add_toc_line(md_file_obj, header_name="Tools", link_text="Tools")
        add_toc_line(md_file_obj, header_name="Workflows", link_text="Workflows")

        return md_file_obj


    def get_expressions_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Get the expressions section of the catalogue
        :param md_file_obj:
        :return:
        """
        md_file_obj.new_header(level=2, title="Expressions", add_table_of_contents='n')

        # Iterate through items
        for expression in self.expressions:
            md_file_obj.new_header(level=3, title=expression.name, add_table_of_contents='n')
            md_file_obj.new_header(level=4, title="Versions", add_table_of_contents='n')

            version: ItemVersionExpression
            for version in expression.versions:
                md_file_obj.new_line(f"- {version.name}")
                # Get help page link
                version_markdown_path = get_markdown_file_from_cwl_path(version.cwl_file_path).absolute()
                if not version_markdown_path.is_file():
                    markdown_path_text = "CWL Help Page :construction:"
                else:
                    markdown_path_text = "CWL Help Page"
                md_file_obj.new_line("  - {}".format(
                        md_file_obj.new_inline_link(link=relpath(version_markdown_path, self.output_path.parent),
                                                    text=markdown_path_text)
                    ),
                    wrap_width=0)
                md_file_obj.new_line("  - {}".format(
                        md_file_obj.new_inline_link(link=relpath(version.cwl_file_path, self.output_path.parent),
                                                    text="CWL File Path")
                    ),
                    wrap_width=0)
                md_file_obj.new_line("\n")

            md_file_obj.new_line("\n")

        return md_file_obj

    def get_tools_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Get the tools section of the catalogue
        :param md_file_obj:
        :return:
        """
        md_file_obj.new_header(level=2, title="Tools", add_table_of_contents='n')

        # Iterate through items
        tool: ItemTool
        for tool in self.tools:
            md_file_obj.new_header(level=3, title=tool.name, add_table_of_contents='n')

            # Add in categories for the tool
            if not len(tool.categories) == 0:
                md_file_obj.new_header(level=4, title="Categories", add_table_of_contents='n')
                for category in tool.categories:
                    md_file_obj.new_line(f"- {category}")
                md_file_obj.new_line("\n")

            md_file_obj.new_header(level=4, title="Versions", add_table_of_contents='n')

            version: ItemVersionTool
            for version in tool.versions:
                md_file_obj.new_line(f"- {version.name}")
                # Get help page link
                version_markdown_path = get_markdown_file_from_cwl_path(version.cwl_file_path).absolute()
                if not version_markdown_path.is_file():
                    markdown_path_text = "CWL Help Page :construction:"
                else:
                    markdown_path_text = "CWL Help Page"
                md_file_obj.new_line("  - {}".format(
                    md_file_obj.new_inline_link(link=relpath(version_markdown_path, self.output_path.parent),
                                                text=markdown_path_text)
                ),
                    wrap_width=0)
                md_file_obj.new_line("  - {}".format(
                        md_file_obj.new_inline_link(link=relpath(version.cwl_file_path, self.output_path.parent),
                                                    text=version.name)
                    ),
                    wrap_width=0)
                md_file_obj.new_line("\n")

            md_file_obj.new_line("\n")

        return md_file_obj
    
    def get_workflows_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Get the workflows section of the catalogue
        :param md_file_obj:
        :return:
        """
        md_file_obj.new_header(level=2, title="Workflows", add_table_of_contents='n')

        # Iterate through items
        workflow: ItemWorkflow
        for workflow in self.workflows:
            md_file_obj.new_header(level=3, title=workflow.name, add_table_of_contents='n')

            # Add in categories for the workflow
            if not len(workflow.categories) == 0:
                md_file_obj.new_header(level=4, title="Categories", add_table_of_contents='n')
                for category in workflow.categories:
                    md_file_obj.new_line(f"- {category}")
                md_file_obj.new_line("\n")

            md_file_obj.new_header(level=4, title="Versions", add_table_of_contents='n')

            version: ItemVersionWorkflow
            for version in workflow.versions:
                md_file_obj.new_line(f"- {version.name}")
                # Get help page link
                version_markdown_path = get_markdown_file_from_cwl_path(version.cwl_file_path).absolute()
                if not version_markdown_path.is_file():
                    markdown_path_text = "CWL Help Page :construction:"
                else:
                    markdown_path_text = "CWL Help Page"
                md_file_obj.new_line("  - {}".format(
                    md_file_obj.new_inline_link(link=relpath(version_markdown_path, self.output_path.parent),
                                                text=markdown_path_text)
                ),
                    wrap_width=0)
                md_file_obj.new_line("  - {}".format(
                        md_file_obj.new_inline_link(link=relpath(version.cwl_file_path, self.output_path.parent),
                                                    text=version.name)
                    ),
                    wrap_width=0)
                md_file_obj.new_line("\n")

            md_file_obj.new_line("\n")

        return md_file_obj


