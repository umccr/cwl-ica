#!/usr/bin/env python3

"""
Create a markdown help page for this workflow

"""


from utils.logging import get_logger
from subcommands.github_actions.create_markdown_file import CreateMarkdownFile
from argparse import ArgumentError
from utils.repo import get_workflows_dir, get_workflow_yaml_path
from utils.errors import CheckArgumentError, ItemNotFoundError
from pathlib import Path
from classes.item_workflow import ItemWorkflow
from utils.miscell import get_name_version_tuple_from_cwl_file_path, \
    get_items_dir_from_cwl_file_path, get_markdown_file_from_cwl_path, get_graph_path_from_cwl_path, get_raw_url_from_path, \
    cwl_id_to_path
from utils.repo import read_yaml
import re
from utils.pydot_utils import get_step_path_from_step_obj
from utils.pydot_utils import build_cwl_dot, build_cwl_svg, edit_cwl_dot
import math
from tempfile import NamedTemporaryFile
from os.path import relpath
from mdutils import MdUtils

logger = get_logger()


class CreateWorkflowMarkdownFile(CreateMarkdownFile):
    """Usage:
    cwl-ica github-actions-create-workflow-markdown help
    cwl-ica github-actions-create-workflow-markdown (--workflow-path="<path-to-cwl-workflow>")


Description:
    Create a markdown file for a cwl workflow - this script is designed to be called by github actions


Options:
    --workflow-path=<workflow path>            Creation of the workflow path

EnvironmentVariables:
    GITHUB_SERVER_URL                          The server we're running on (probably https://github.com)
    GITHUB_REPOSITORY                          This GitHub repository, probably 'umccr/cwl-ica'

Example
    cwl-ica github-actions-create-workflow-markdown --workflow-path workflows/dragen-germline/3.7.5/dragen-germline__3.7.5.cwl"
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv,
                         item_type="workflow",
                         item_type_key="workflows",
                         items_dir=get_workflows_dir())

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
        Check --workflow-path exists
        Set cwl_file_path, name and version
        Import the item object
        Import the cwl item
        Import the cwl object
        Check env vars
        :return:
        """

        # Check defined and assign properties
        workflow_path_arg = self.args.get("--workflow-path", None)
        if workflow_path_arg is None:
            logger.error("--workflow-path not defined")
            raise CheckArgumentError

        # Check workflow path is file
        workflow_path_arg = Path(workflow_path_arg)
        if not workflow_path_arg.is_file():
            logger.error(f"--workflow-path argument '{workflow_path_arg}' does not exist")
            raise CheckArgumentError

        # Get cwl file path
        self.cwl_file_path = workflow_path_arg

        # Get markdown path from cwl file path
        self.markdown_path = get_markdown_file_from_cwl_path(self.cwl_file_path)

        # Create markdown directory if it doesn't exist
        if not self.markdown_path.parent.is_dir():
            self.markdown_path.parent.mkdir(parents=True, exist_ok=True)

        # Get item name and item version
        self.item_name, self.item_version = get_name_version_tuple_from_cwl_file_path(self.cwl_file_path,
                                                                                      items_dir=get_workflows_dir())

        # Import the item object
        self.import_item_obj()

        # Import the item version object
        self.import_item_version_obj()

        # Get ICA workflow versions
        self.projects, self.workflows, self.workflow_versions = self.get_ica_workflow_versions()

        if self.is_markdown_md5sum_match() and self.is_markdown_project_match() and self.is_run_match():
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
        items_list = [ItemWorkflow.from_dict(workflow_dict)
                      for workflow_dict in read_yaml(get_workflow_yaml_path())["workflows"]
                      if workflow_dict.get("name") == self.item_name]

        if len(items_list) == 0:
            raise ItemNotFoundError

        self.item_obj: ItemWorkflow = items_list[0]

    def get_uses_section(self, md_file_obj: MdUtils):
        """
        From the cwl object, return the links to all of the steps that run
        :param md_file_obj:
        :return:
        """

        # Initialise link lists
        step_names = []
        step_versions = []
        step_markdown_paths = []

        # Iterate through the steps of the workflow
        for step_obj in self.cwl_obj.steps:
            # Get the step path
            step_path = get_step_path_from_step_obj(step_obj, self.cwl_file_path)
            step_name, step_version = get_name_version_tuple_from_cwl_file_path(step_path,
                                                                                get_items_dir_from_cwl_file_path(step_path))
            step_markdown_path = get_markdown_file_from_cwl_path(step_path).absolute()
            # Append to lists
            step_names.append(step_name)
            step_versions.append(step_version)
            step_markdown_paths.append(step_markdown_path)

        # Create the uses section
        if len(step_names) == 0:
            return md_file_obj

        md_file_obj.new_header(level=3, title=f"Uses", add_table_of_contents='n')
        for step_name, step_version, step_markdown_path in zip(step_names, step_versions, step_markdown_paths):
            # Do we add in a construction emoji (lets the user know that the link is broken)
            if not step_markdown_path.is_file():
                step_markdown_text = f"{step_name} {step_version} :construction:"
            else:
                step_markdown_text = f"{step_name} {step_version}"
            # Add the item to the list
            md_file_obj.new_line("- " + md_file_obj.new_inline_link(link=relpath(step_markdown_path, self.markdown_path.parent),
                                                                    text=step_markdown_text),
                                 wrap_width=0)

        md_file_obj.new_line("\n")

        return md_file_obj

    def get_steps_section(self, md_file_obj: MdUtils):
        """
        Get each step and the name / label of the step that runs
        :param md_file_obj:
        :return:
        """

        md_file_obj.new_header(level=2, title=f"{self.cwl_obj.label} Steps", add_table_of_contents='n')

        for step_obj in self.cwl_obj.steps:
            # Get the step path
            step_path = get_step_path_from_step_obj(step_obj, self.cwl_file_path)
            items_dir = get_items_dir_from_cwl_file_path(step_path)
            step_markdown_path = get_markdown_file_from_cwl_path(step_path)
            if not step_markdown_path.is_file():
                # Create a 'construction' emoji over the help page so user knows they'll be clicking a broken link
                step_markdown_text = "CWL File Help Page :construction:"
            else:
                step_markdown_text = "CWL File Help Page"

            step_type = re.sub(r"s$", "", str(items_dir.name))

            # Add in step header
            md_file_obj.new_header(level=3, title=step_obj.label, add_table_of_contents='n')

            # Add in id and doc and the step type
            md_file_obj.new_paragraph()
            md_file_obj.new_line(f"> ID: {cwl_id_to_path(step_obj.id)}\n")
            md_file_obj.new_line(f"**Step Type:** {step_type}")
            md_file_obj.new_line(f"**Docs:**\n")
            md_file_obj.new_line(f"{step_obj.doc}", wrap_width=0)

            # Add in links to step
            md_file_obj.new_header(level=4, title="Links", add_table_of_contents='n')
            md_file_obj.new_line(md_file_obj.new_inline_link(link=relpath(step_path.absolute(), self.markdown_path.parent),
                                                             text="CWL File Path"),
                                 wrap_width=0)
            md_file_obj.new_line(md_file_obj.new_inline_link(link=relpath(step_markdown_path.absolute(), self.markdown_path.parent),
                                                             text=step_markdown_text),
                                 wrap_width=0)

            # Check if a workflow
            if step_type == "workflow":
                # SVG graph path
                graph_path = get_graph_path_from_cwl_path(step_path)
                # Add in svg graph link!
                md_file_obj.new_header(level=4, title="Subworkflow overview", add_table_of_contents='n')
                md_file_obj.new_line(md_file_obj.new_inline_link(link=get_raw_url_from_path(graph_path),
                                            text=md_file_obj.new_inline_image(path=relpath(graph_path.absolute(),
                                                                                           self.markdown_path.absolute().parent),
                                                                              text=graph_path.name),
                                            ),
                                     wrap_width=0)

            # Add a break between steps
            md_file_obj.new_line("\n")

        return md_file_obj


    def get_visual_section(self, md_file_obj: MdUtils):
        """
        Create a visual section -> Also builds the svg file
        :param md_file_obj:
        :return:
        """

        # Get the path to the svg
        svg_path = get_graph_path_from_cwl_path(self.cwl_file_path)

        # Create the md file visual header
        md_file_obj.new_header(level=2, title="Visual Workflow Overview", add_table_of_contents='n')
        md_file_obj.new_line(md_file_obj.new_inline_link(link=get_raw_url_from_path(svg_path),
                                                         text=md_file_obj.new_inline_image(path=relpath(svg_path.absolute(), self.markdown_path.absolute().parent),
                                                                                           text=svg_path.name)),
                             wrap_width=0)

        if svg_path.is_file() and self.is_markdown_md5sum_match():
            # The workflow hasn't changed, we don't need to create the dot file
            logger.info("The workflow md5sum hasn't changed, no need to update the svg file")
            return md_file_obj

        # We need to build / rebuild the svg
        # Build the dot file and svg file
        temp_dot_file = NamedTemporaryFile(delete=False)

        # Build the cwl dot file
        build_cwl_dot(self.cwl_item, dot_out_path=Path(temp_dot_file.name))

        # Edit the dot file
        edit_cwl_dot(self.cwl_item, self.cwl_obj, Path(temp_dot_file.name))

        # Create the svg path directory
        if not svg_path.is_dir():
            svg_path.parent.mkdir(parents=True, exist_ok=True)

        # Get the ratio value by the length of the cwl object inputs
        inputs_len = len(self.cwl_obj.inputs)
        ratio_value = round(min(1 / math.log(inputs_len), 1.0), 3) if inputs_len > 1 else 1

        # Build the cwl svg graph
        build_cwl_svg(temp_dot_file.name, svg_path, ratio_value)

        return md_file_obj

