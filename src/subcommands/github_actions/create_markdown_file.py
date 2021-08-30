#!/usr/bin/env python3

"""
A superclass of create_tool_markdown and create_workflow_markdown GH scripts
-> Some generic useful functions

get_used_by() -> Get the workflows that use this tool or workflow

get_header_section() -> Get the markdown header section for this tool or workflow

get_inputs_section() -> Returns the inputs section to a tool or workflow

get_outputs_section() -> Returns the outputs section for a tool or workflow

get_ica_workflow_versions() -> Get the ica workflow version objects that use this tool or workflow


## Workflow specific
get_steps_section() -> Returns the steps section of a workflow
get_uses_section() -> Returns the tools / workflows / expressions used by a workflow
get_visual_section() -> Returns the workflow section
build_workflow_graph() -> Builds the workflow cwl dot graph

## File structure
All items are under .github/catalogue

* Markdown documents go under .github/catalogue/docs/workflows/<workflow_name>/<wfv>/<workflow_name>__<wfv>.md

* CWL Graphs go under .github/catalogue/images/workflows/<workflow_name>/<wfv>/<workflow_name>__<wfv>.svg

* Run plots go under .github/catalogue/images/runs/<workflow_name>/<wfv>/<run_id>.png

## GitHub actions env vars
GITHUB_WORKSPACE
GITHUB_SERVER_URL
GITHUB_REPOSITORY

### Links to other files will be like
str(GITHUB_SERVER_URL) + "/" + str(Path(GITHUB_REPOSITORY) / "blob" / "main" / "relative_path"...
where relative_path == abs_path.relative_to(GITHUB_WORKSPACE)

### Relative paths don't work if we're in 'raw' mode and in a private repository
"""
from typing import List, Tuple

from classes.command import Command
from utils.logging import get_logger
from utils.repo import read_yaml, get_project_yaml_path, get_workflow_yaml_path
from mdutils.mdutils import MdUtils
from classes.project_production import ProductionProject
from classes.ica_workflow_version import ICAWorkflowVersion
from classes.ica_workflow import ICAWorkflow
from classes.ica_workflow_run import ICAWorkflowRun
from utils.miscell import get_name_version_tuple_from_cwl_file_path, cwl_id_to_path, get_markdown_file_from_cwl_path
from utils.pydot_utils import get_step_path_from_step_obj
from utils.ica_markdown_utils import get_run_instance_obj_from_id
from utils.create_markdown_utils import add_toc_line
from os.path import relpath
import re
from utils.errors import ItemVersionNotFoundError

# For typing conventions
from typing import Optional
from classes.cwl import CWL
from classes.item import Item
from classes.item_version import ItemVersion
from pathlib import Path
from classes.project import Project

logger = get_logger()


class CreateMarkdownFile(Command):
    """
    Superclass of CreateToolMarkdownFile and CreateWorkflowMarkdownFile
    """

    def __init__(self, command_argv, item_type=None, item_type_key=None, items_dir=None):
        """
        Create the markdown file
        """
        # Collect args from doc strings
        super().__init__(command_argv)

        self.item_type = item_type  # type: Optional[str] # Tool or workflow
        self.item_type_key = item_type_key  # type: Optional[str] # tools or workflow
        self.items_dir = items_dir  # type: Optional[Path]
        self.cwl_file_path = None # type: Optional[Path]
        self.markdown_path = None # type: Optional[Path]
        self.item_name = None  # type: Optional[str]
        self.item_version = None  # type: Optional[str]
        self.item_obj = None  # type: Optional[Item]
        self.item_version_obj = None  # type: Optional[ItemVersion]
        self.create_markdown = True
        self.cwl_item = None  # type: Optional[CWL]
        self.cwl_obj = None  # Is of the cwl_item.parser type -> set in subcommands
        self.projects = None  # type: Optional[List[Project]]
        self.workflows = None  # type: Optional[List[ICAWorkflow]]
        self.workflow_versions = None  # type: Optional[List[ICAWorkflowVersion]]
        self.cwl_name = None  # type: Optional[str]

        # Checks args / assigns / creates the cwl object
        self.check_args()

    def __call__(self):
        """
        Build the mdobject
        :return:
        """

        if not self.create_markdown:
            logger.info("Markdown file exists with matching md5sum, projects and workflows... skipping!")
            return

        # Initialise mdutils object
        logger.info("Initialising the markdown file object")
        md_file: MdUtils = MdUtils(file_name=str(self.markdown_path),
                                   title=f"{self.item_name} {self.item_version} {self.item_type}")
        # Get the header section
        logger.info("Getting the header section")
        md_file = self.get_header_section(md_file)

        # Get visual section
        if self.item_type in ["workflow"]:
            # Only relevant to workflows
            logger.info("Getting the visual section")
            md_file = self.get_visual_section(md_file)

        # Get links section
        logger.info("Getting links section")
        md_file = self.get_links_section(md_file)

        # Get inputs section
        logger.info("Getting inputs section")
        md_file = self.get_inputs_section(md_file)

        # Get steps section
        if self.item_type in ["workflow"]:
            # Steps only relevant to workflows
            logger.info("Getting steps section")
            md_file = self.get_steps_section(md_file)

        # Get outputs section
        logger.info("Getting the outputs section")
        md_file = self.get_outputs_section(md_file)

        # Get ica section
        if self.item_type in ["tool", "workflow"] and not len(self.projects) == 0:
            # Not for expressions
            logger.info("Getting the ica section")
            from utils.ica_markdown_utils import get_ica_section
            md_file = get_ica_section(self.cwl_file_path, self.item_type, self.projects, self.workflows,
                                      self.workflow_versions, md_file, self.markdown_path)

        # Write out md file object
        logger.info("Writing out markdown file")
        md_file.create_md_file()

    def set_name_version_from_cwl_file_path(self):
        """
        Given the item path, set the item name and item version
        :return:
        """
        self.item_name, self.item_version = get_name_version_tuple_from_cwl_file_path(self.cwl_file_path, self.items_dir)

    def check_args(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError

    def import_item_obj(self):
        """
        Import the item object
        :return:
        """
        raise NotImplementedError

    def import_item_version_obj(self):
        """
        Import the item version object from the item object
        :return:
        """
        if self.item_obj is None:
            return
        version: ItemVersion
        for version in self.item_obj.versions:
            if version.name == self.item_version:
                self.item_version_obj = version

    def is_markdown_md5sum_match(self):
        """
        Check if the md5sum on the markdown matches
        :return:
        """
        item_md5sum = self.item_version_obj.md5sum
        if not self.markdown_path.is_file():
            return False

        # Get the md5sum from the markdown file
        with open(self.markdown_path, "r") as markdown_h:
            for line in markdown_h.readlines():
                if line.strip().startswith("> md5sum: "):
                    if item_md5sum == line.strip().rsplit(" ")[-1]:
                        logger.info("Item md5sum matches that in markdown file")
                        return True
                    logger.info("Item md5sum does NOT match that in markdown file")
                    return False
            return False

    def is_markdown_project_match(self):
        """
        Iterate over the projects, workflow and workflow versions,

        If a line matches
        ### Project: <project_name> i.e "### Project: development_workflows"

        Find the workflow id for this project
        > wfl id: <workflow_id> i.e "> wfl id: wfl.7747fed243b4422eb1c40cb1fa9fea75"

        Find the workflow version name
        > **wfl version name:** <workflow version name>  i.e "**wfl version name:** 1.3.5"

        ...without first finding another "### Project:"
        :return:
        """
        if not self.markdown_path.is_file():
            return False

        logger.info("Checking if the projects in project.yaml match that in the existing markdown file")
        for project, workflow, workflow_version in zip(self.projects, self.workflows, self.workflow_versions):
            # Reset booleans
            has_project = False
            has_workflow = False
            has_workflow_version = False
            # Open up the file (we do this for each iterable)
            with open(self.markdown_path, "r") as markdown_h:
                for line in markdown_h.readlines():
                    if has_project and has_workflow and has_workflow_version:
                        # We have them all! move on to next iterable
                        break
                    if line.strip() == f"### Project: {project.project_name}":
                        # We have the project
                        has_project = True
                        continue
                    # Check we haven't reached another project already
                    if has_project and line.strip().startswith("### Project"):
                        # We've reached another project without finding the workflow or workflow version
                        logger.info("Found the project but not the workflow or workflow version")
                        return False
                    if line.strip() == f"> wfl id: {workflow.ica_workflow_id}":
                        has_workflow = True
                    if line.strip() == f"**wfl version name:** {workflow_version.ica_workflow_version_name}":
                        has_workflow_version = True

            # We've gone through the whole file, make sure we've got the project, workflow and workflow version
            if has_project and has_workflow and has_workflow_version:
                # We're good! Move on to next iterable combo
                continue
            # We did not find them all!
            logger.info(f"Did not find project/workflow/workflow-version combo "
                        f"{project.project_name}/{workflow.ica_workflow_id}/{workflow_version.ica_workflow_version_name} "
                        f"markdown file {self.markdown_path} will be re-created.")
            return False

        # We've found all of the projects, workflows and workflow versions in the markdown.
        logger.info("All projects, workflows and workflow versions match!")
        return True


    def is_run_match(self):
        """
        Iterate through all of the runs of this workflow and make sure that they exist at:
        "#### Run run.id" i.e "#### Run wfr.e3c6b8ce7e4447cbbd321b5c96ef7670"
        :return:
        """

        logger.info("Making sure all of the run objects are in this markdown file")

        # Can't match if the markdown path doesn't exist
        if not self.markdown_path.is_file():
            return False

        # Iterate through run instances
        for workflow_version in self.workflow_versions:
            run_objs: List[ICAWorkflowRun] = [get_run_instance_obj_from_id(run_instance_id)
                                              for run_instance_id in workflow_version.run_instances]

            # We may not have any runs
            if len(run_objs) == 0:
                continue

            for run_obj in run_objs:
                # Open up the file (we do this for each iterable)
                with open(self.markdown_path, "r") as markdown_h:
                    for line in markdown_h.readlines():
                        if line.strip() == f"##### Run {run_obj.ica_workflow_run_instance_id}":
                            break
                    else:
                        # We didn't find the header for this run object
                        logger.info(f"Could not find run {run_obj.ica_workflow_run_instance_id} in {self.markdown_path}")
                        return False

        # We've found all of the run objects
        return True

    def import_cwl_obj(self):
        """
        :return:
        """
        item_versions: List[ItemVersion] = [version
                                            for version in self.item_obj.versions
                                            if version.name == self.item_version]

        if len(item_versions) == 0:
            raise ItemVersionNotFoundError

        # Call item version to get cwl object
        item_version = item_versions[0]
        item_version()

        # Set cwl item
        self.cwl_item = item_version.cwl_obj
        # Call the cwl item to get the md5sum
        self.cwl_item()
        parser = self.cwl_item.parser
        # Also get the cwl object
        self.cwl_obj: parser.Tool = self.cwl_item.cwl_obj


    def get_header_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Get the header section
        :return:
        """

        ## TOC ##
        md_file_obj = self.get_toc(md_file_obj)

        # Create overview section
        md_file_obj.new_header(level=2, title=f"{self.cwl_obj.label} Overview", add_table_of_contents='n')

        # Add new line
        md_file_obj.new_paragraph("\n")

        # Add ID and md5sum
        md_file_obj.new_line(f"> ID: {self.cwl_name}")
        md_file_obj.new_line(f"> md5sum: {self.cwl_item.md5sum}\n")


        # Add Documentation
        md_file_obj.new_header(level=3, title=f"{self.cwl_obj.label} documentation", add_table_of_contents='n')
        md_file_obj.new_line(f"{self.cwl_obj.doc}", wrap_width=0)

        # Add categories
        if hasattr(self.item_obj, 'categories'):
            md_file_obj.new_header(level=3, title="Categories", add_table_of_contents='n')
            for category_name in self.item_obj.categories:
                md_file_obj.new_line(f"- {category_name}")

        md_file_obj.new_line("\n")

        return md_file_obj

    def get_toc(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Manually add in TOC
        :param md_file_obj:
        :return:
        """
        # Add in our own TOC
        md_file_obj.new_header(level=2, title=f"Table of Contents", add_table_of_contents='n')

        # Overview TOC
        md_file_obj = add_toc_line(md_file_obj, header_name=self.cwl_obj.label + " Overview", link_text="Overview")

        # Visual TOC
        if self.item_type in ["workflow"]:
            md_file_obj = add_toc_line(md_file_obj, header_name="Visual Workflow Overview", link_text="Visual")

        # Links TOC
        md_file_obj = add_toc_line(md_file_obj, header_name="Related Links", link_text="Links")

        # Inputs TOC
        md_file_obj = add_toc_line(md_file_obj, header_name=self.cwl_obj.label + " Inputs", link_text="Inputs")

        # Steps TOC
        if self.item_type in ["workflow"]:
            # Steps only relevant to workflows
            md_file_obj = add_toc_line(md_file_obj, header_name=self.cwl_obj.label + " Steps", link_text="Steps")

        # Outputs TOC
        md_file_obj = add_toc_line(md_file_obj, header_name=self.cwl_obj.label + " Outputs", link_text="Outputs")

        # ICA TOC
        if self.item_type in ["tool", "workflow"]:
            # Not for expressions
            md_file_obj = add_toc_line(md_file_obj, header_name="ICA", link_text="ICA")

        md_file_obj.new_line("\n")

        return md_file_obj

    def get_inputs_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Get the inputs section of the cwl obj
        :param md_file_obj:
        :return:
        """

        # Create input section
        md_file_obj.new_header(level=2, title=f"{self.cwl_obj.label} Inputs", add_table_of_contents='n')

        # Iterate through inputs
        for input_obj in self.cwl_obj.inputs:
            input_type, is_optional = self.get_type_from_cwl_io_object(input_obj)
            md_file_obj.new_header(level=3, title=input_obj.label, add_table_of_contents='n')

            # Add new paragraph
            md_file_obj.new_paragraph("\n")

            md_file_obj.new_line(f"> ID: {cwl_id_to_path(input_obj.id).name}\n")
            md_file_obj.new_line(f"**Optional:** `{is_optional}`")
            md_file_obj.new_line(f"**Type:** `{input_type}`")
            md_file_obj.new_line(f"**Docs:**")
            md_file_obj.new_line(f"{input_obj.doc}\n", wrap_width=0)

        md_file_obj.new_line("\n")

        return md_file_obj

    def get_type_from_cwl_io_object(self, sub_cwl_object):
        """
        Get the type from the input object
        :param sub_cwl_object:
        :return:
        """
        i_o_type = sub_cwl_object.type
        i_o_optional = False

        # If the instance type is a list, could be because its optional
        if isinstance(i_o_type, list):
            i_o_type_list = []

            for i_o_type_i in i_o_type:
                if i_o_type_i == 'null':
                    continue
                i_o_type_list.append(i_o_type_i)
                i_o_optional = True

            if len(i_o_type_list) == 1:
                i_o_type = i_o_type_list[0]
            else:
                i_o_type = i_o_type_list

        # Check if an array
        if isinstance(i_o_type, self.cwl_item.parser.ArraySchema):
            recursion_level = 1
            max_iters = 10
            count = 0
            while True:
                count += 1
                if count > max_iters:
                    logger.warning(f"Got stuck in infinite while loop whilst trying to determine the type for input/output"
                                   f"of step with type {type(i_o_type)}")
                    break
                if isinstance(i_o_type.items, str):
                    i_o_type = i_o_type.items.rsplit("#", 1)[-1] + "[]"*recursion_level
                    break
                elif isinstance(i_o_type.items, self.cwl_item.parser.ArraySchema):
                    # Recursive array
                    i_o_type = i_o_type.items
                    recursion_level += 1
                else:
                    logger.warning(f"Could not handle input/output of type {type(i_o_type)} with items of type {type(i_o_type.items)}")
                    break


        return i_o_type, i_o_optional


    # Implemented in subclass
    def get_visual_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Only revelant to workflows - implemented in subclass
        :return:
        """
        raise NotImplementedError

    def get_links_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Get the links section of the md5 file object, includes the used and used by
        :param md_file_obj:
        :return:
        """

        md_file_obj.new_header(level=2, title=f"Related Links", add_table_of_contents='n')

        md_file_obj.new_line("- {}".format(md_file_obj.new_inline_link(link=relpath(self.cwl_file_path.absolute(),
                                                                                    self.markdown_path.absolute().parent),
                                                                       text='CWL File Path')),
                             wrap_width=0)
        md_file_obj.new_line("\n")

        # Get the uses section
        if self.item_type == "workflow":
            logger.info("Getting links/uses section")
            md_file_obj = self.get_uses_section(md_file_obj)

        # Get the used by section
        logger.info("Getting links/used by section")
        md_file_obj = self.get_used_by_section(md_file_obj)

        md_file_obj.new_line("\n")

        return md_file_obj

    def get_steps_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Only relevant to workflows - implemented in subclass
        :return:
        """
        raise NotImplementedError

    def get_outputs_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Get the outputs section of the cwl object
        :param md_file_obj:
        :return:
        """

        # Create output section
        md_file_obj.new_header(level=2, title=f"{self.cwl_obj.label} Outputs", add_table_of_contents='n')

        # Iterate through outputs
        for output_obj in self.cwl_obj.outputs:
            output_type, is_optional = self.get_type_from_cwl_io_object(output_obj)
            md_file_obj.new_header(level=3, title=output_obj.label, add_table_of_contents='n')
            md_file_obj.new_paragraph("\n")
            md_file_obj.new_line(f"> ID: {cwl_id_to_path(output_obj.id)}")
            md_file_obj.new_line("\n")
            md_file_obj.new_line(f"**Optional:** `{is_optional}`")
            md_file_obj.new_line(f"**Output Type:** `{output_type}`")
            md_file_obj.new_line(f"**Docs:**")
            md_file_obj.new_line(f"{output_obj.doc}", wrap_width=0)
            md_file_obj.new_line("\n")

        md_file_obj.new_line("\n")

        return md_file_obj

    def get_uses_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        Only relevant to workflow objects, implemented in subclass
        :param md_file_obj:
        :return:
        """
        raise NotImplementedError

    def get_used_by_section(self, md_file_obj: MdUtils) -> MdUtils:
        """
        This is quite a labourious process -> Go through each workflow object and collect the steps
        For each step if the step file path matches our cwl obj file path then we add that workflow to our list
        :param md_file_obj:
        :return:
        """

        workflows_used_by = []

        # Then get the workflow path from the cwl file path.
        from classes.item_workflow import ItemWorkflow, ItemVersionWorkflow
        for workflow in [ItemWorkflow.from_dict(workflow_dict)
                         for workflow_dict in read_yaml(get_workflow_yaml_path())["workflows"]]:
            version: ItemVersionWorkflow
            for version in workflow.versions:
                # Let user know what we're reading
                logger.info(f"Checking workflow {workflow.name}/{version.name}")

                # First check if we have a partial match
                with open(version.cwl_file_path, 'r') as cwl_workflow_h:
                    for line in cwl_workflow_h:
                        if re.search(self.cwl_file_path.name, line):
                            break
                    else:
                        logger.info(f"Couldn't find {self.cwl_file_path.name} in a quick text search of {version.cwl_file_path}")
                        # Didn't find a match for this filename, skipping
                        continue

                # Set the cwl object
                version()

                # Assign var to object for type hints
                cwl_obj: version.cwl_obj.parser.Workflow = version.cwl_obj.cwl_obj

                # Type hints for step
                step: version.cwl_obj.parser.WorkflowStep
                for step in cwl_obj.steps:
                    if self.cwl_file_path.absolute() == get_step_path_from_step_obj(step, version.cwl_file_path):
                        workflows_used_by.append((workflow, version))

        # And add it as a link
        # points to a given object
        if len(workflows_used_by) == 0:
            return md_file_obj

        md_file_obj.new_header(level=3, title="Used By", add_table_of_contents='n')
        for (workflow, version) in workflows_used_by:
            md_file_obj.new_line("- {}".format(
                md_file_obj.new_inline_link(
                    link=relpath(get_markdown_file_from_cwl_path(version.cwl_file_path), self.markdown_path.parent),
                    text=f"{workflow.name} {version.name}")
                ),
                wrap_width=0)

        md_file_obj.new_line("\n")

        return md_file_obj

    def get_ica_workflow_versions(self) -> Tuple[List[Project], List[ICAWorkflow], List[ICAWorkflowVersion]]:
        """
        Get the workflow versions from the cwl file path -> Reads projects, gets ica workflow versions than exist for this path
        :return:
        """
        # Get list of projects
        projects: List[Project] = [
                                   Project.from_dict(project_dict)
                                   if project_dict.get("production", False)
                                   else ProductionProject.from_dict(project_dict)
                                   for project_dict in read_yaml(get_project_yaml_path())["projects"]
                                  ]
        included_projects: List[Project] = []
        included_workflows: List[ICAWorkflow] = []
        included_workflow_versions: List[ICAWorkflowVersion] = []

        # Iterate through projects and collect those
        for project in projects:
            ica_items_list = project.get_items_by_item_type(self.item_type)
            for ica_item in ica_items_list:
                if not ica_item.name == self.item_name:
                    continue
                # For production projects we search backwards
                rev_versions_list = ica_item.versions[::-1]
                for ica_item_version in rev_versions_list:
                    if ica_item_version.name == self.item_version:
                        included_projects.append(project)
                        included_workflows.append(ica_item)
                        included_workflow_versions.append(ica_item_version)
                        # Include only the latest project version (for prod projects)
                        break

        return included_projects, included_workflows, included_workflow_versions




