#!/usr/bin/env python3

import libica.openapi.libwes
from libica.openapi.libwes.rest import ApiException
from utils.ica_utils import get_base_url
from utils.logging import get_logger
from utils.errors import ICAWorkflowVersionCreationError, UnknownDateTypeError
from hashlib import md5
from ruamel.yaml.comments import CommentedMap as OrderedDict
from dateutil.parser import parse as date_parser
from pathlib import Path
from tempfile import NamedTemporaryFile
import json
from datetime import datetime

logger = get_logger()


class ICAWorkflowVersion:
    """
    The ICA Workflow Version object has the following properties
        * Name of the version
        * Path to the version
        * The ICA workflow version
        * The modification time of the ICA workflow version
        * Any run instances associated with this ICAWorkflowVersion
        * The ICAWorkflowID so that commands such as the following can be executed through libica:
            * create_workflow_version
            * sync_workflow_version
            * get_workflow_version_md5sum
    """

    def __init__(self, name, path, ica_workflow_id, ica_workflow_version_name,
                 modification_time=None, run_instances=None):
        """
        Initialises values for the object
        :param name:
        :param path:
        :param ica_workflow_version_name:
        :param modification_time:
        :param run_instances:
        """

        self.name = name
        self.path = Path(path)
        self.ica_workflow_id = ica_workflow_id
        self.ica_workflow_version_name = ica_workflow_version_name
        self.modification_time = modification_time
        self.run_instances = run_instances if run_instances is not None else []
        # Defined when get_workflow_version_object is called or update / create is done
        self.workflow_version_obj = None

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

    def create_workflow_version(self, workflow_definition, access_token):
        """
        Use libica to create a workflow version though POST
        :return:
        """

        # Set config
        configuration = self.get_ica_wes_configuration(access_token)

        # Create workflow version
        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            api_instance = libica.openapi.libwes.WorkflowVersionsApi(api_client)
            language = libica.openapi.libwes.WorkflowLanguage(name="CWL", version=workflow_definition.get("cwlVersion"))
            body = libica.openapi.libwes.CreateWorkflowVersionRequest(version=self.ica_workflow_version_name,
                                                                      definition=workflow_definition,
                                                                      language=language)

            try:
                # Create a new workflow version
                api_response = api_instance.create_workflow_version(self.ica_workflow_id, body=body)
                # Create
            except ApiException:
                logger.error(f"Api exeception error when trying to "
                             f"create workflow version \"{self.ica_workflow_id}/{self.ica_workflow_version_name}\"")
                raise ApiException

        self.workflow_version_obj = api_response

        # Update modification time attribute
        self.modification_time = self.get_workflow_version_modification_time()

    def sync_workflow_version(self, workflow_definition, access_token):
        """
        Use libica to update a workflow version through PATCH
        :return:
        """

        # Set config
        configuration = self.get_ica_wes_configuration(access_token)

        # Update workflow version
        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            api_instance = libica.openapi.libwes.WorkflowVersionsApi(api_client)
            body = libica.openapi.libwes.UpdateWorkflowVersionRequest(definition=workflow_definition)

            try:
                # Create a new workflow version
                api_response = api_instance.update_workflow_version(self.ica_workflow_id,
                                                                    version_name=self.ica_workflow_version_name,
                                                                    body=body)
                # Create
            except ApiException:
                logger.error(f"Api exeception error when trying to "
                             f"create workflow version \"{self.ica_workflow_id}/{self.ica_workflow_version_name}\"")

        self.workflow_version_obj = api_response

        # Update modification time attribute
        self.modification_time = self.get_workflow_version_modification_time()

    def get_workflow_version_object(self, access_token):
        """
        Use libica to run a get on the workflow object. Used for downstream tools like
        get_workflow_version_md5sum and get_workflow_version_modification_time
        :param access_token:
        :return:
        """

        # Set config
        configuration = self.get_ica_wes_configuration(access_token)

        # Create a project token
        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libwes.WorkflowVersionsApi(api_client)

            try:
                # Get the details of a workflow version
                api_response = api_instance.get_workflow_version(self.ica_workflow_id, self.ica_workflow_version_name)
            except ApiException:
                logger.error(f"Api exeception error when trying to "
                             f"get workflow version \"{self.ica_workflow_id}/{self.ica_workflow_version_name}\"")

        self.workflow_version_obj = api_response

        # Update modification time attribute
        self.modification_time = self.get_workflow_version_modification_time()

        return api_response

    def get_workflow_version_md5sum(self):
        """
        Use libica to get the definition attribute from through GET
        :return:
        """

        if self.workflow_version_obj is None:
            logger.warning("Tried to get workflow version md5sum but workflow object was none")
            return None

        # Get definition
        workflow_definition = self.workflow_version_obj.definition

        # Calculate md5sum - first dump json to file
        tmp_packed_definition = NamedTemporaryFile()

        with open(tmp_packed_definition.name, "w") as tmp_h:
            json.dump(json.loads(workflow_definition), tmp_h, indent=4)

        with open(tmp_packed_definition.name, "rb") as tmp_h:
            md5sum = md5(tmp_h.read()).hexdigest()

        return md5sum

    def get_workflow_version_modification_time(self):
        """
        Check the latest modification time against ICA for this workflow.
        :return:
        """
        if self.workflow_version_obj is None:
            logger.warning("Tried to get workflow modification time but workflow object was none")
            return None

        # Get definition
        workflow_modification_time = self.workflow_version_obj.time_modified

        # Calculate md5sum
        return workflow_modification_time

    def check_update_okay(self):
        """
        An update would not be allowed on a workflow if the modification time on ICA does NOT match the
        modification time on the yaml file. This means it has been updated else where and
        will need to be updated manually
        :return:
        """
        # Add workflow version
        if self.get_workflow_version_modification_time() < self.modification_time:
            return True
        else:
            logger.warning(f"Cannot update workflow \"{self.ica_workflow_id}\" "
                           f"version \"{self.ica_workflow_version_name}\""
                           f"It has been modified elsewhere but the "
                           f"modification was not recorded in project.yaml file.")
            return False

    def to_dict(self):
        """
        Write this workflow version to dictionary
        Output is an ordered dictionary with the following attributes:
        * name
        * path
        * ica_workflow_version_name
        * modification_time
        * run_instances: []
        :return:
        """

        return OrderedDict({
            "name": self.name,
            "path": str(self.path),
            "ica_workflow_version_name": self.ica_workflow_version_name,
            "modification_time": self.modification_time_to_string(self.modification_time),
            "run_instances": self.run_instances
        })

    @staticmethod
    def modification_time_to_string(modification_time):
        """
        Get the modification time and convert to string logic
        :param self:
        :param modification_time:
        :return:
        """
        if modification_time is None:
            return None
        elif isinstance(modification_time, datetime):
            return modification_time.strftime("%Y-%m-%dT%H:%M:%S%Z")
        elif isinstance(modification_time, str):
            return date_parser(modification_time).strftime("%Y-%m-%dT%H:%M:%S%Z")
        else:
            logger.error(f"Did not know what to do when modification_time attribute was \"{type(modification_time)}\"")
            raise UnknownDateTypeError

    @staticmethod
    def modification_time_to_datetime(modification_time):
        """
        Get the modification time and convert to datetime object
        :param modification_time:
        :return:
        """
        if modification_time is None:
            return None
        elif isinstance(modification_time, datetime):
            return modification_time
        elif isinstance(modification_time, str):
            return date_parser(modification_time)
        else:
            logger.error(f"Did not know what to do when modification_time attribute was \"{type(modification_time)}\"")
            raise UnknownDateTypeError

    @classmethod
    def from_dict(cls, workflow_version_dict):
        """
        Create a ICAWorkflowVersion object from a dictionary
        :return:
        """

        # Check name and path are legit

        # Check the item_dict has the appropriate keys
        if workflow_version_dict.get("name", None) is None:
            logger.error("\"name\" attribute not found, cannot create ICAWorkflowVersion")
            raise ICAWorkflowVersionCreationError

        if workflow_version_dict.get("path", None) is None:
            logger.error("\"path\" attribute not found, cannot create ICAWorkflowVersion")
            raise ICAWorkflowVersionCreationError

        return cls(name=workflow_version_dict.get("name"),
                   path=workflow_version_dict.get("path"),
                   ica_workflow_id=workflow_version_dict.get("ica_workflow_id", None),
                   ica_workflow_version_name=workflow_version_dict.get("ica_workflow_version_name", None),
                   modification_time=cls.modification_time_to_datetime(workflow_version_dict.get("modification_time", None)),
                   run_instances=workflow_version_dict.get("run_instances", None))
