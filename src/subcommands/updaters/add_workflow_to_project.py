#!/usr/bin/env python3

"""
Add a workflow to a project
"""

from subcommands.updaters.add_to_project import AddToProject
from utils.repo import get_workflow_yaml_path, get_workflows_dir
from pathlib import Path
from classes.item_workflow import ItemWorkflow
from utils.errors import CheckArgumentError
from utils.logging import get_logger

logger = get_logger()


class AddWorkflowToProject(AddToProject):
    """Usage:
    cwl-ica [options] add-workflow-to-project help
    cwl-ica [options] add-workflow-to-project (--workflow-path /path/to/workflow.cwl)
                                              [--project="project_name"]

Description:
    Add an existing workflow from 'workflow.yaml' to a project
    The workflow must exist in workflow.yaml.  Please use cwl-ica workflow-init to add this workflow to workflow.yaml.
    We will also run a validation on the workflow before syncing.
    For each project listed, the workflow version is patched with this version.


Options:
    --workflow-path=<the workflow path>                 Required, the path to the cwl workflow
    --project=<the project to add the workflow to>      Required, the project name

Example:
    cwl-ica add-workflow-to-project --workflow-path "workflows/dragen-germline/3.7.5/dragen-germline__3.7.5.cwl" --project "development"
    """

    def __init__(self, command_argv):
        # Call super class
        super(AddWorkflowToProject, self).__init__(command_argv,
                                                   item_dir=get_workflows_dir(),
                                                   item_yaml_path=get_workflow_yaml_path(),
                                                   item_type_key="workflows",
                                                   item_type="workflow",
                                                   item_suffix="cwl")

    def check_args(self):
        """
        Checks --workflow-path exists
        For --projects, if set to --all, then checks if --tenants set of CWL_ICA_DEFAULT_TENANT set
        If --projects not set, checks CWL_ICA_DEFAULT_PROJECT
        :return:
        """
        # Check --workflow-path argument
        cwl_path = self.args.get("--workflow-path", None)

        if cwl_path is None:
            logger.error("--workflow-path not specified")
            raise CheckArgumentError

        # Convert to path type
        cwl_path = Path(cwl_path)

        self.cwl_file_path = cwl_path

        if not cwl_path.is_file():
            logger.error(f"--workflow-path argument \"{cwl_path}\" could not be found")
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
        Get the project ica item list through projects' ica_workflows_list
        :return:
        """
        return self.project.ica_workflows_list

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemWorkflow.from_dict(item_dict)
