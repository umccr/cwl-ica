#!/usr/bin/env python

"""
We introduce the subclass ProductionProject that only updates workflows on a merge with the main branch
ProductionProject ica workflow versions hold a 7 digit git commit id suffix at the end of them.
This is updated by the github actions script.
"""

from classes.ica_workflow import ICAWorkflow
from classes.ica_workflow_version import ICAWorkflowVersion
from pathlib import Path
from classes.cwl import CWL
from classes.project import Project
from utils.logging import get_logger
from utils.errors import WorkflowVersionExistsError, ProductionProjectError
import os

logger = get_logger()


class ProductionProject(Project):
    """
    A project has the following attributes
    * project_id           # The ICA project id
    * project_name         # The project name as described here
    * project_abbr         # The project abbreviation
    * project_description  # The description of the project
    * tenant_id           # The ICA domain of the project

    In order to interact with the CLI we require a token to be present
    Whilst the token is not stored in the project object, we have a few methods to retrieve a token
    1. From the environment, CWL_ICA_ACCESS_TOKEN_<PROJECT_NAME.upper()>
    2. From ${CONDA_PREFIX}/ica/tokens/<project-name>.txt
    """

    is_production = True  # Overwrites default in Project class

    def __init__(self, project_name, project_id, project_abbr, project_api_key_name, project_description, linked_projects, tenant_id, tools, workflows):
        """
        Collect the project from the project list if defined,
        otherwise read in the project from the project yaml path
        """

        # Call super class
        super(ProductionProject, self).__init__(project_name, project_id, project_abbr, project_api_key_name, project_description, linked_projects, tenant_id, tools, workflows)

    def get_tools(self):
        """
        Collect tools for this project from tool.yaml
        :return:
        """
        # TODO need to implement inits in hierarchical format first.
        # Calls get_items on tool.yaml and cross reference name attribute with tool name
        # And then for each tool checks versions with tool_versions
        raise NotImplementedError  # Don't see a reason to implement this

    def get_workflows(self):
        """
        Collects workflows for this project tool in workflow.yaml
        :return:
        """
        # TODO need to implement inits in hierarchical format first
        raise NotImplementedError  # Don't see a reason to implement this

    def sync_item_version_with_project(self, ica_workflow_version, md5sum, cwl_packed_obj):
        """
        Takes an ica workflow version object (which, yes will be an item in this in either tools or workflows)
        Gets the new item versions md5sum and the cwl_packed_dict for uploading to ica
        In general projects, this uses tool-sync or workflow-sync subcommands
        In the ProductionVersion, this is set in mind for GitHub actions
        :return:
        """
        # Check GIT_COMMIT_ID env var exists
        if os.environ.get("GIT_COMMIT_ID", None) is None:
            logger.error("Could not get the env var \"GIT_COMMIT_ID\"")
            raise EnvironmentError

        # Check existing ica workflow version name follows convention
        if not ica_workflow_version.ica_workflow_version_name == ica_workflow_version.name + "--__GIT_COMMIT_ID__":
            logger.error(f"ICA workflow version name \"{ica_workflow_version.ica_workflow_version_name}\" does not "
                         f"follow convention for production project")
            raise ProductionProjectError

        # Update the workflow version name
        ica_workflow_version.ica_workflow_version_name = '--'.join([ica_workflow_version.name,
                                                                    os.environ.get("GIT_COMMIT_ID")][:7])

        # Create the workflow version - modification time is auto added to ica workflow version object
        ica_workflow_version.create_workflow_version(cwl_packed_obj, self.get_project_token())
        workflow_version_obj = ica_workflow_version.get_workflow_version_object(self.get_project_token())

    def add_item_to_project(self, item_key, item_obj: CWL, access_token, categories=None):
        """
        This is where the project and Production project are most different.
        Where ProductionProject adds on 7-digit component, the

        :param item_key: Either 'tools' or 'workflows'
        :param item_obj: The item of type CWL that has a CWL Packed object.
                         From here we can collect the md5sum and the definition json ready for upload
        :return:
        """
        # Get current ica list
        if item_key == "tools":
            item_type = "tool"  # Useful for errors
            project_ica_items_list = self.ica_tools_list
        elif item_key == "workflows":
            item_type = "workflow"  # Useful for errors
            project_ica_items_list = self.ica_workflows_list
        else:
            logger.error("Don't know what to do with anything other than tools / workflows")
            raise NotImplementedError

        # Check if we have a matching name -> This means we just need to add a version
        for project_ica_item in project_ica_items_list:
            if project_ica_item.name == item_obj.name:
                this_project_ica_item = project_ica_item
                break
        else:
            # We need to initialise a project ica item
            this_project_ica_item = ICAWorkflow(
                name=item_obj.name,
                path=Path(item_obj.name),
                ica_workflow_name=item_obj.name + "_" + self.project_abbr,
                ica_workflow_id=None,
                versions=None,
                categories=categories if categories is not None else []
            )
            # Create a workflow id -> this also must happen for a production project
            this_project_ica_item.create_workflow_id(access_token)

            # We should also now append our project item to our list
            project_ica_items_list.append(this_project_ica_item)

        # Now lets check if a version of the same name exists
        # If we're on a production project we expect this and instead create a new version
        for ica_version in this_project_ica_item.versions:
            if ica_version.name == item_obj.version:
                logger.error(f"We already have a version of this ica workflow. "
                             f"A new commit id of this workflow will automatically be created if there's a change to "
                             f"the workflow. This is checked on every push to the (remote) main branch.")
                raise WorkflowVersionExistsError
        else:
            # Create a new workflow version obj
            project_ica_item_version = ICAWorkflowVersion(name=item_obj.version,
                                                          path=Path(item_obj.cwl_file_path.parent.name) /
                                                               Path(item_obj.cwl_file_path.name),
                                                          ica_workflow_id=this_project_ica_item.ica_workflow_id,
                                                          ica_workflow_version_name=item_obj.version + "--__GIT_COMMIT_ID__",
                                                          modification_time=None,
                                                          run_instances=None)
            # Append workflow
            this_project_ica_item.versions.append(project_ica_item_version)
