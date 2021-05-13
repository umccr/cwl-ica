#!/usr/bin/env python3

"""
Sync a workflow to workflow.yaml and to any projects set under --projects
"""

from subcommands.sync.sync import Sync
from utils.logging import get_logger
from utils.repo import get_workflow_yaml_path, get_workflows_dir
from pathlib import Path
from classes.item_workflow import ItemWorkflow
from utils.errors import CheckArgumentError


logger = get_logger()


class WorkflowSync(Sync):
    """Usage:
    cwl-ica [options] workflow-sync help
    cwl-ica [options] workflow-sync (--workflow-path /path/to/workflow.cwl)
                                [--projects="project[,additional-projects]"]
                                [--tenants="tenant-name[,additional-tenants]"]


Description:
    Sync a workflow to 'workflow.yaml' in the configuration folder
    The workflow should have been created with cwl-ica create-workflow-from-template and then validated with workflow-validate.
    The workflow must exist in workflow.yaml.  Please use cwl-ica workflow-init to add this workflow to workflow.yaml.
    We will also run a validation on the workflow before syncing.
    For each project listed, the workflow version is patched with this version.
    When --projects=all, --tenants is checked. If --tenants=all or --tenants is not defined and CWL_ICA_DEFAULT_TENANT
    is not defined then all projects across all tenants are def


Options:
    --workflow-path=<the workflow path>                         Required, the path to the cwl workflow
    --projects=<the list of projects>                   Optional, the list of projects
    --tenants=<the list of tenants>                     Optional, the list of tenants

Environment Variables:
    CWL_ICA_DEFAULT_PROJECT    Can be used as an alternative for --projects.
    CWL_ICA_DEFAULT_TENANT     Used when --projects=all.

Example:
    cwl-ica workflow-sync --workflow-path "workflows/dragen-germline/3.7.5/dragen-germline__3.7.5.cwl"
    cwl-ica workflow-sync --workflow-path "workflows/dragen-germline/3.7.5/dragen-germline__3.7.5.cwl" --projects "development"
    cwl-ica workflow-sync --workflow-path "workflows/dragen-germline/3.7.5/dragen-germline__3.7.5.cwl" --projects "development,production"
    cwl-ica workflow-sync --workflow-path "workflows/dragen-germline/3.7.5/dragen-germline__3.7.5.cwl" --projects "all" --tenants "umccr-dev"
    """

    # Overwrite global, get workflows directory
    item_yaml_path = get_workflow_yaml_path()

    item_type_key = "workflows"   # Set in subclass
    item_type = "workflow"       # Set in subclass

    def __init__(self, command_argv):
        # Call super class
        super(WorkflowSync, self).__init__(command_argv,
                                           update_projects=True,
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
            logger.error(f"--workflow-path argument \"{cwl_path} could not be found")
            raise CheckArgumentError

        # Get the name and version attributes
        self.set_name_and_version_from_file_path()

        # Get projects
        self.set_projects_list()

    @staticmethod
    def get_project_ica_item_list(project):
        """
        Get the project ica item list through projects' ica_workflows_list
        :param project:
        :return:
        """
        return project.ica_workflows_list

    @staticmethod
    def get_item_obj_from_dict(item_dict):
        """
        Get the item object from dictionary
        :param item_dict:
        :return:
        """
        return ItemWorkflow.from_dict(item_dict)
