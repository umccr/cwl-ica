#!/usr/bin/env python3

"""
ICAWorkflow has the following properties
* Name of the workflow
* Path to the workflow root -> this depends on the subclass, either ICATool or ICAWorkflow
* The ICA workflow ID (if set)
* The List of versions which are their own class ICAWorkflowVersion
* Categories associated with the workflow
* ICAWorkflowVersions have their own attributes
    * Name of the version
    * Path to the version
    * The ICA workflow version
    * The modification time of the ICA workflow version
    * Any run instances associated with this ICAWorkflowVersion
"""

from classes.ica_workflow_version import ICAWorkflowVersion
from pathlib import Path
from ruamel.yaml.comments import CommentedMap as OrderedDict
import libica.openapi.libwes
from libica.openapi.libwes.rest import ApiException
from utils.ica_utils import get_base_url, get_region_from_base_url

from utils.logging import get_logger
from utils.errors import ICAWorkflowError, ICAWorkflowCreationError


logger = get_logger()


class ICAWorkflow:
    """
    The ICA Workflow has the following properties
      * Name of the workflow
      * Path to the workflow root -> this depends on the subclass, either ICATool or ICAWorkflow
      * The ICA workflow ID (if set)
      * The List of versions which are their own class ICAWorkflowVersion
      * Categories associated with the workflow
    """

    def __init__(self, name, path, ica_workflow_name=None, ica_workflow_id=None, versions=None, categories=None):
        """
        :param workflow_name:
        :param workflow_path:
        :param ica_workflow_id:
        :param ica_workflow_name:
        :param workflow_versions_dict:
        :param categories:
        """

        self.name = name
        self.path = Path(path)
        self.ica_workflow_name = ica_workflow_name
        self.ica_workflow_id = ica_workflow_id
        self.categories = categories
        self.versions = []
        self.workflow_obj = None  # Defined when get request is called

        # Check workflow id is defined and versions is None
        if ica_workflow_id is None and versions is not None:
            logger.error("Cannot have versions be defined and ica_workflow_id not defined")
            raise ICAWorkflowError

        # Collect the versions from the workflow versions
        if versions is not None:
            for workflow_version in versions:
                self.versions.append(ICAWorkflowVersion(
                    name=workflow_version.get("name", None),
                    path=workflow_version.get("path", None),
                    ica_workflow_id=self.ica_workflow_id,
                    ica_workflow_version_name=workflow_version.get("ica_workflow_version_name", None),
                    modification_time=ICAWorkflowVersion.modification_time_to_datetime(workflow_version.get("modification_time", None)),
                    run_instances=workflow_version.get("run_instances", [])
                ))

    # Workflow version
    @staticmethod
    def get_ica_wes_configuration(access_token):
        """
        Initialise with a configuration
        :return:
        """
        configuration = libica.openapi.libwes.Configuration(
            host=get_base_url(),
            api_key={
                "Authorization": access_token
            },
            api_key_prefix={
                "Authorization": "Bearer"
            }
        )
        return configuration

    # Write out
    def to_dict(self):
        """
        Return an ordered dictionary
        :return:
        """
        return OrderedDict({
            "name": self.name,
            "path": str(self.path),
            "ica_workflow_name": self.ica_workflow_name,
            "ica_workflow_id": self.ica_workflow_id,
            "versions": [version.to_dict() if isinstance(version, ICAWorkflowVersion) else version
                         for version in self.versions],
        })

    # Initialise workflow id
    def create_workflow_id(self, access_token, project_id, linked_projects=None):
        """
        Use the libica package to create a workflow and assign to the workflow id attribute
        :return:
        """

        # Set config
        configuration = self.get_ica_wes_configuration(access_token)

        # Set acl
        acl = [f"cid:{project_id}"]
        if linked_projects is not None and not len(linked_projects) == 0:
            acl.extend([f"cid:{linked_project_id}" for linked_project_id in linked_projects])

        # Create a project token
        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libwes.WorkflowsApi(api_client)
            body = libica.openapi.libwes.CreateWorkflowRequest(name=self.ica_workflow_name,
                                                               categories=self.categories if self.categories is not None else [],
                                                               acl=acl)
            try:
                # Get the details of a workflow version
                api_response = api_instance.create_workflow(body=body)
            except ApiException:
                logger.error(f"Api exeception error when trying to create a workflow for {self.name}")
                raise ApiException

        self.ica_workflow_id = api_response.id

    def get_workflow_object(self, access_token):
        """
        Use libica to run a get on the workflow object. Used for updating acls
        :param access_token:
        :return:
        """

        # Set config
        configuration = self.get_ica_wes_configuration(access_token)

        # Create a project token
        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libwes.WorkflowsApi(api_client)

            try:
                # Get the details of a workflow version
                api_response = api_instance.get_workflow(self.ica_workflow_id)
            except ApiException:
                logger.error(f"Api exeception error when trying to "
                             f"get workflow \"{self.ica_workflow_id}\"")

        self.workflow_obj = api_response

        return api_response

    def update_ica_workflow_item(self, access_token, name=None, acl=None, categories=None):
        """
        Update a ica workflow, allowing only for changes for a name or acl
        :param name:
        :param acl:
        :return:
        """

        # Set config
        configuration = self.get_ica_wes_configuration(access_token)

        # Create a project token
        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libwes.WorkflowsApi(api_client)

            body = libica.openapi.libwes.UpdateWorkflowRequest(name=name,
                                                               acl=acl,
                                                               categories=categories)

            try:
                # Get the details of a workflow version
                api_response = api_instance.update_workflow(self.ica_workflow_id,
                                                            body=body)
            except ApiException:
                logger.error(f"Api exeception error when trying to "
                             f"update workflow \"{self.ica_workflow_id}\"")

        self.workflow_obj = api_response

    @classmethod
    def from_dict(cls, workflow_dict):
        """
        Create a ICAWorkflowVersion object from a dictionary
        :param name:
        :param path:
        :param ica_workflow_name:
        :param ica_workflow_id:
        :param versions:
        :param categories:
        :return:
        """

        # Check name and path are legit

        # Check the item_dict has the appropriate keys
        if workflow_dict.get("name", None) is None:
            logger.error("\"name\" attribute not found, cannot create ICAWorkflow")
            raise ICAWorkflowCreationError

        if workflow_dict.get("path", None) is None:
            logger.error("\"path\" attribute not found, cannot create ICAWorkflow")
            raise ICAWorkflowCreationError

        return cls(name=workflow_dict.get("name", None),
                   path=workflow_dict.get("path", None),
                   ica_workflow_name=workflow_dict.get("ica_workflow_name", None),
                   ica_workflow_id=workflow_dict.get("ica_workflow_id", None),
                   versions=workflow_dict.get("versions", None),
                   categories=workflow_dict.get("categories", None))

