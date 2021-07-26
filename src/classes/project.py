#!/usr/bin/env python

"""
The project class is extremely useful for performing ica actions on a project
These include adding an item to a project - whether that actually be syncing with the project
or just registering and putting in later, for a user or github actions to sync projects
We also introduce the subclass ProductionProject that only updates workflows on a merge with the main branch
ProductionProject ica workflow versions hold a 7 digit git commit id suffix at the end of them.
"""

from utils.conda import get_conda_tokens_dir, create_tokens_dir
from ruamel.yaml.comments import CommentedMap as OrderedDict
from classes.ica_workflow import ICAWorkflow
from classes.ica_workflow_version import ICAWorkflowVersion
import os
from pathlib import Path
from classes.cwl import CWL
from utils.logging import get_logger
from utils.errors import InvalidTokenError, CWLApiKeyNotFoundError, \
    WorkflowVersionExistsError, ProjectCreationError, CWLAccessTokenNotFoundError, ItemNotFoundError
from utils.ica_utils import get_base_url, get_jwt_token_obj, get_token_memberships, \
    get_token_expiry, check_token_expiry, get_api_key, create_token_from_api_key_with_role, get_region_from_base_url,\
    store_token
from utils.globals import SCOPES_BY_ROLE
from utils.yaml import to_multiline_string

logger = get_logger()


class Project:
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

    is_production = False  # True in ProductionProject class

    def __init__(self, project_name, project_id, project_abbr, project_api_key_name, project_description, linked_projects, tenant_id, tools, workflows):
        """
        Collect the project from the project list if defined,
        otherwise read in the project from the project yaml path
        """

        # Easy initialise of project name
        self.project_name = project_name

        # Now assign components from the object
        self.project_id = project_id
        self.project_abbr = project_abbr
        self.project_api_key_name = project_api_key_name
        self.project_description = project_description
        self.linked_projects = linked_projects
        self.tenant_id = tenant_id

        # Get lists of ica workflow objects
        self.ica_tools_list = self.get_ica_workflow_objs_from_list(tools)
        self.ica_workflows_list = self.get_ica_workflow_objs_from_list(workflows)

    # Static methods
    @staticmethod
    def get_project_obj_from_project_list(project_name, project_list):
        """
        Returns the project object based on the project name
        :param project_list:
        :return:
        """

        for project in project_list:
            if project.get("project_name", None) == project_name:
                return project.deepcopy()

    @staticmethod
    def get_ica_workflow_objs_from_list(workflow_list):
        """
        Get the workflow objects from a project list
        Each workflow comprises the following attributes
        * Name (The name of the workflow)
        * Path (The path to the workflow)
        * ID   (The ID of the workflow)
        :param workflow_list:
        :return:
        """

        ica_workflow_objs = []
        for workflow_dict in workflow_list:
            # For each workflow in the workflow dict we do the following
            ica_workflow_objs.append(ICAWorkflow.from_dict(workflow_dict))

        return ica_workflow_objs

    def get_project_token(self):
        """
        Get the access token for a project
        Either we have the CWL_ICA_ACCESS_TOKEN_<PROJECT_NAME.upper()> env var
        or we read ${CONDA_PREFIX}/ica/tokens/<project-name>.txt
        :return:
        """
        valid_access_token = False
        from_env = False
        logger.debug("Looking for project token in environment variables")
        cwl_ica_access_token = os.environ.get("CWL_ICA_ACCESS_TOKEN_{}".format(self.project_name.upper().replace("-", "_")), None)
        token_path = Path(get_conda_tokens_dir()) / Path(f"{self.project_name}.txt")

        if cwl_ica_access_token is None and token_path.is_file():
            logger.debug("Collecting token from token file")
            with open(token_path, 'r') as token_h:
                cwl_ica_access_token = token_h.read().strip()
        else:
            from_env = True

        # Check token validity
        if cwl_ica_access_token is not None:
            try:
                self.check_project_token(cwl_ica_access_token, warn_on_near_expiry=False)
            except InvalidTokenError:
                if from_env:
                    logger.error("Project access token from environment has expired, "
                                 "please either unset this environment variable "
                                 "or reassign to a valid token")
                    raise InvalidTokenError
                logger.warning("Project access token has expired - attempting to create a new one")
            else:
                valid_access_token = True

        if not valid_access_token:
            # Get the api key
            logger.debug("Getting new token from api-key")
            api_key = get_api_key(self.project_api_key_name)

            if api_key is None:
                logger.error("Could not create a fresh token from the api-key, "
                             "make sure you have set the env var \"CWL_ICA_API_KEY_SH\"")
                raise CWLApiKeyNotFoundError

            # We have a valid api key, lets create a new project token and save it from this api key
            cwl_ica_access_token = create_token_from_api_key_with_role(get_base_url(),
                                                                       api_key,
                                                                       self.project_id, role="admin")

            store_token(cwl_ica_access_token, self.project_name)

        # Final check - we should have a token present now.
        if cwl_ica_access_token is None:
            logger.error("CWL-ICA access token not found")
            raise CWLAccessTokenNotFoundError

        return cwl_ica_access_token

    def check_project_token(self, access_token, warn_on_near_expiry=True):
        """
        Used when initialising a project object to make sure we can use it.
        :return:
        """
        # Read the token attributes
        token_obj = get_jwt_token_obj(access_token, f'iap-{get_region_from_base_url(get_base_url())}')

        # Check memberships
        token_projects = get_token_memberships(token_obj)
        if self.project_id not in token_projects:
            logger.error(f"The access token provided does not contain this project \"{self.project_id}\"")
            raise InvalidTokenError

        # Get expiry
        token_expiry = get_token_expiry(token_obj)

        # Check the token expiry
        check_token_expiry(token_expiry, warn_on_near_expiry=warn_on_near_expiry)

        # Check scopes
        # TODO - not sure if this is necessary, we now run this through the api-key name

    def get_items_by_item_type(self, item_type):
        """
        Return the tool list or workflows list
        :return:
        """
        if item_type == "tool":
            return self.ica_tools_list
        elif item_type == "workflow":
            return self.ica_workflows_list
        else:
            raise ItemNotFoundError

    def add_item_to_project(self, item_key, cwl_obj: CWL, access_token, categories=None):
        """
        Takes in a tool / workflow item and itemVersion and then appends tools / workflows with said attribute.
        This is re-defined in a ProductionProject instance where the ica workflow version name is appended with
        "__GIT_COMMIT_ID__" and not uploaded to production. If there are no existing versions, a workflow is still
        created in a ProductionProject through ICA, but no version is created.

        :param item_key: Either 'tools' or 'workflows'
        :param cwl_obj: The item of type CWL that has a CWL Packed object.
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
            if project_ica_item.name == cwl_obj.name:
                this_project_ica_item = project_ica_item
                break
        else:
            # We need to initialise a project ica item
            this_project_ica_item = ICAWorkflow(
                name=cwl_obj.name,
                path=Path(cwl_obj.name),
                ica_workflow_name=cwl_obj.name + "_" + self.project_abbr,
                ica_workflow_id=None,
                versions=None,
                categories=categories if categories is not None else []
            )
            # Create a workflow id -> this also must happen for a production project
            this_project_ica_item.create_workflow_id(access_token, self.project_id, linked_projects=self.linked_projects)

            # We should also now append our project item to our list
            project_ica_items_list.append(this_project_ica_item)

        # Now lets check if a version of the same name exists
        # If we're on a production project we expect this and instead create a new version
        for ica_version in this_project_ica_item.versions:
            if ica_version.name == cwl_obj.version:
                logger.error(f"We already have a version of this ica workflow. Use cwl-ica {item_type}-sync instead "
                             f"if you wish to update the workflow")
                raise WorkflowVersionExistsError
        else:
            # Create a new workflow version obj
            project_ica_item_version = ICAWorkflowVersion(name=cwl_obj.version,
                                                          path=Path(cwl_obj.cwl_file_path.parent.name) /
                                                               Path(cwl_obj.cwl_file_path.name),
                                                          ica_workflow_id=this_project_ica_item.ica_workflow_id,
                                                          ica_workflow_version_name=cwl_obj.version,
                                                          modification_time=None,
                                                          run_instances=None)
            # Append workflow
            this_project_ica_item.versions.append(project_ica_item_version)
            # Create a new workflow version
            project_ica_item_version.create_workflow_version(cwl_obj.cwl_packed_obj, access_token,
                                                             project_id=self.project_id, linked_projects=self.linked_projects)

    def sync_item_version_with_project(self, ica_workflow_version, md5sum, cwl_packed_obj, force=False):
        """
        Takes an ica workflow version object (which, yes will be an item in this in either tools or workflows)
        Gets the new item versions md5sum and the cwl_packed_dict for uploading to ica
        In general projects, this uses tool-sync or workflow-sync subcommands
        In the ProductionVersion, this is set in mind for GitHub actions
        :return:
        """
        # Call the workflow version object / Assign ica_workflow_obj attribute to ica_workflow_version obj
        _ = ica_workflow_version.get_workflow_version_object(self.get_project_token())

        # Now compare the item version and ica workflow version
        if self.compare_item_version_and_ica_workflow_version(ica_workflow_version, md5sum):
            # Update ica workflow
            ica_workflow_version.sync_workflow_version(cwl_packed_obj, self.get_project_token(),
                                                       project_id=self.project_id,
                                                       linked_projects=self.linked_projects,
                                                       force=force)

    # Compare item version and ICA workflow version
    @staticmethod
    def compare_item_version_and_ica_workflow_version(ica_workflow_version, md5sum):
        """
        Get item version and ica workflow version
        :return:
        """
        # Set the workflow version object
        if ica_workflow_version.get_workflow_version_md5sum() == md5sum:
            logger.info("Workflow is up-to-date, skipping")
            return False

        # Modification time passed, md5sum is different, time to update the workflow
        return True

    # Read / Write functions for project
    def to_dict(self):
        """
        Write out project to dictionary
        :return:
        """

        return OrderedDict({
            "project_name": self.project_name,
            "project_id": self.project_id,
            "project_description": to_multiline_string(self.project_description),
            "project_abbr": self.project_abbr,
            "project_api_key_name": self.project_api_key_name,
            "production": self.is_production,
            "linked_projects": self.linked_projects,
            "tenant_id": self.tenant_id,
            "tools": [tool.to_dict() if isinstance(tool, ICAWorkflow) else tool
                      for tool in self.ica_tools_list],
            "workflows": [workflow.to_dict() if isinstance(workflow, ICAWorkflow)
                          else workflow for workflow in self.ica_workflows_list]
        })

    @classmethod
    def from_dict(cls, project_dict):
        """
        Create project object from dictionary
        :param project_dict:
        :return:
        """

        # Check the item_dict has the appropriate keys
        if project_dict.get("project_name", None) is None:
            logger.error("\"project_name\" attribute not found, cannot create project")
            raise ProjectCreationError

        if project_dict.get("project_id", None) is None:
            logger.error("\"project_id\" attribute not found, cannot create project")
            raise ProjectCreationError

        if project_dict.get("project_abbr", None) is None:
            logger.error("\"project_abbr\" attribute not found, cannot create project")
            raise ProjectCreationError

        if project_dict.get("project_api_key_name", None) is None:
            logger.error("\"project_api_key_name\" attribute not found, cannot create project")
            raise ProjectCreationError

        if project_dict.get("project_description", None) is None:
            logger.error("\"project_description\" attribute not found, cannot create project")
            raise ProjectCreationError

        if project_dict.get("linked_projects", None) is None:
            logger.error("\"linked_projects\" attribute not found, cannot create project")
            raise ProjectCreationError

        if project_dict.get("tenant_id", None) is None:
            logger.error("\"tenant_id\" attribute not found, cannot create project")
            raise ProjectCreationError

        return cls(project_name=project_dict.get("project_name", None),
                   project_id=project_dict.get("project_id", None),
                   project_abbr=project_dict.get("project_abbr", None),
                   project_api_key_name=project_dict.get("project_api_key_name", None),
                   project_description=project_dict.get("project_description", None),
                   linked_projects=project_dict.get("linked_projects", None),
                   tenant_id=project_dict.get("tenant_id", None),
                   tools=project_dict.get("tools", None),
                   workflows=project_dict.get("workflows", None))

