#!/usr/bin/env python3

"""
This is the heart of a run object, runs once registered don't need updating,
"""

from ruamel.yaml.comments import CommentedMap as OrderedDict
import libica.openapi.libwes
from libica.openapi.libwes.rest import ApiException
from utils.ica_utils import get_base_url
from utils.errors import ICAWorkflowRunCreationError, InvalidTokenError
from urllib.parse import urlparse
from utils.logging import get_logger
import json
import re
from utils.ica_utils import get_jwt_token_obj, get_region_from_base_url
from base64 import b64encode, b64decode

logger = get_logger()

class ICAWorkflowRun:
    """
    A Run class has the following attributes
    - An ica instance id
    - ica workflow id
    - ica workflow version
    - A dict of inputs
    - A dict of outputs
    - A set of engine-parameters
    """

    def __init__(self, ica_workflow_run_instance_id, ica_workflow_id=None, ica_workflow_version_name=None,
                 ica_input=None, ica_output=None, ica_engine_parameters=None, project_token=None):
        """
        :param ica_workflow_run_instance_id:
        :param ica_workflow_id:
        :param ica_workflow_version_name:
        :param ica_input:
        :param ica_output:
        :param ica_engine_parameters:
        """

        # Set attrs
        self.ica_workflow_run_instance_id = ica_workflow_run_instance_id

        # Check values and then use project token
        if ica_workflow_id is None and project_token is None:
            logger.error("Both ica_workflow_id and project_token cannot be none")

        # If we have the workflow id, assume we have everything else
        if ica_workflow_id is not None:
            self.ica_workflow_id = ica_workflow_id
            self.ica_workflow_version_name = ica_workflow_version_name
            self.ica_input = ica_input
            self.ica_output = ica_output
            self.ica_engine_parameters = ica_engine_parameters
        else:
            api_response =  self.get_run_instance(project_token)
            self.ica_workflow_id, self.ica_workflow_version_name = self.split_href_by_id_and_version(api_response.workflow_version.href)
            self.ica_input = api_response.input if api_response.input is not None else {}
            self.ica_output = api_response.output if api_response.output is not None else {}
            self.ica_engine_parameters = json.loads(api_response.engine_parameters) if api_response.engine_parameters is not None else {}

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

    def get_run_instance(self, project_token):
        """
        Use libica to collect the workflow run instance from the workflow run instance id and the project token
        :param project_token:
        :return:
        """

        configuration = self.get_ica_wes_configuration(project_token)

        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libwes.WorkflowRunsApi(api_client)
            run_id = self.ica_workflow_run_instance_id  # str | ID of the workflow run

        # Useful for error, collect token as an object and
        project_token_obj = get_jwt_token_obj(project_token, f'iap-{get_region_from_base_url(get_base_url())}')
        project_id_list = [acl.split(':', 1)[-1] for acl in project_token_obj.get("acl") if acl.startswith("cid:")]
        if len(project_id_list) == 0:
            logger.error("Access token is not part of a project context")
            raise InvalidTokenError
        project_id = project_id_list[0]

        # Get api_response
        try:
            # Get the details of a workflow run
            api_response = api_instance.get_workflow_run(run_id, include=['engineParameters'])
        except ApiException as e:
            logger.error("Exception when calling WorkflowRunsApi->get_workflow_run: %s\n" % e)
            logger.error(f"Used project token with project context '{project_id}'. "
                         f"Please confirm that this workflow run belongs to this project context")
            raise ApiException

        return api_response

    @staticmethod
    def split_href_by_id_and_version(href):
        """
        :return:
        """

        url_path = urlparse(href).path

        # https://regex101.com/r/pqMw9h/1/
        regex_obj = re.match(r"^/v1/workflows/(\S+)/versions/(\S+)$", url_path)

        return regex_obj.group(1), regex_obj.group(2)

    # to_dict - write out input, output and engine_parameters in base64
    def to_dict(self):
        """
        Return an ordered dictionary
        :return:
        """
        return OrderedDict({
            "ica_workflow_run_instance_id": self.ica_workflow_run_instance_id,
            "ica_workflow_id": self.ica_workflow_id,
            "ica_workflow_version_name": str(self.ica_workflow_version_name),
            "ica_input": b64encode(json.dumps(self.ica_input).encode("ascii")).decode("ascii"),
            "ica_output": b64encode(json.dumps(self.ica_output).encode("ascii")).decode("ascii"),
            "ica_engine_parameters": b64encode(json.dumps(self.ica_engine_parameters).encode("ascii")).decode("ascii")
        })

    # from_dict - read in input, output and engine_parameters in base64
    @classmethod
    def from_dict(cls, workflow_run_dict):
        """
        Create a ICAWorkflowVersion object from a dictionary
        :return:
        """

        # Check the item_dict has the appropriate keys
        if workflow_run_dict.get("ica_workflow_run_instance_id", None) is None:
            logger.error("\"ica_workflow_run_instance_id\" attribute not found, cannot create ICAWorkflow")
            raise ICAWorkflowRunCreationError

        return cls(ica_workflow_run_instance_id=workflow_run_dict.get("ica_workflow_run_instance_id", None),
                   ica_workflow_id=workflow_run_dict.get("ica_workflow_id", None),
                   ica_workflow_version_name=workflow_run_dict.get("ica_workflow_version_name", None),
                   ica_input=json.loads(b64decode(workflow_run_dict.get("ica_input", None)).decode("ascii")),
                   ica_output=json.loads(b64decode(workflow_run_dict.get("ica_output", None)).decode("ascii")),
                   ica_engine_parameters=json.loads(b64decode(workflow_run_dict.get("ica_engine_parameters", None)).decode("ascii")))
