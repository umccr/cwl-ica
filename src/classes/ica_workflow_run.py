#!/usr/bin/env python3

"""
This is the heart of a run object, runs once registered don't need updating,
"""

from ruamel.yaml.comments import CommentedMap as OrderedDict
import libica.openapi.libwes
from libica.openapi.libwes import WorkflowRun
from libica.openapi.libwes.rest import ApiException
from utils.ica_utils import get_base_url
from utils.errors import ICAWorkflowRunCreationError, InvalidTokenError, GetStepNameError
from urllib.parse import urlparse
from utils.logging import get_logger
import json
import re
from utils.ica_utils import get_jwt_token_obj, get_region_from_base_url
from utils.miscell import encode_compressed_base64, decode_compressed_base64
from classes.ica_task_run import ICATaskRun

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

    def __init__(self, ica_workflow_run_instance_id, ica_workflow_id=None, ica_workflow_name=None, ica_workflow_version_name=None,
                 ica_workflow_run_name=None, ica_input=None, ica_output=None, ica_engine_parameters=None,
                 workflow_start_time=None, workflow_end_time=None, workflow_duration=None,
                 ica_task_objs=None, project_token=None):
        """
        :param ica_workflow_run_instance_id:
        :param ica_workflow_id:
        :param ica_workflow_name:
        :param ica_workflow_version_name:
        :param ica_workflow_run_name:
        :param ica_input:
        :param ica_output:
        :param ica_engine_parameters:
        :param workflow_start_time:
        :param workflow_end_time:
        :param workflow_duration:
        :param ica_task_objs:
        :param project_token:
        """

        # Set attrs
        self.ica_workflow_run_instance_id = ica_workflow_run_instance_id

        # Check values and then use project token
        if ica_workflow_id is None and project_token is None:
            logger.error("Both ica_workflow_id and project_token cannot be none")

        # If we have the workflow id, assume we have everything else
        if ica_workflow_id is not None:
            self.ica_workflow_id = ica_workflow_id
            self.ica_workflow_name = ica_workflow_name
            self.ica_workflow_version_name = ica_workflow_version_name
            self.ica_workflow_run_name = ica_workflow_run_name
            self.ica_input = ica_input
            self.ica_output = ica_output
            self.ica_engine_parameters = ica_engine_parameters
            self.workflow_start_time = workflow_start_time
            self.workflow_end_time = workflow_end_time
            self.workflow_duration = workflow_duration
            self.ica_task_objs = ica_task_objs
        else:
            api_response: WorkflowRun =  self.get_run_instance(project_token)
            self.ica_workflow_id, self.ica_workflow_version_name = self.split_href_by_id_and_version(api_response.workflow_version.href)
            self.ica_workflow_name = self.get_workflow(self.ica_workflow_id, project_token).name
            self.ica_workflow_run_name = api_response.name
            self.ica_input = api_response.input if api_response.input is not None else {}
            self.ica_output = api_response.output if api_response.output is not None else {}
            self.ica_engine_parameters = json.loads(api_response.engine_parameters) if api_response.engine_parameters is not None else {}
            self.workflow_start_time = int(api_response.time_started.timestamp())
            self.workflow_end_time = int(api_response.time_stopped.timestamp())
            self.workflow_duration = self.get_workflow_duration(api_response)
            self.ica_task_objs = self.get_task_run_objs(project_token)

    def get_workflow(self, ica_workflow_id: str, project_token: str) -> libica.openapi.libwes.Workflow:
        """
        Get the workflow
        :param ica_workflow_id: str
        :param project_token: str
        :return:
        """
        # Step 1 - get the run history
        configuration = self.get_ica_wes_configuration(project_token)

        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libwes.WorkflowsApi(api_client)

        # Get api_response
        try:
            # Get a list of workflow run history events
            api_response = api_instance.get_workflow(ica_workflow_id)
        except ApiException as e:
            logger.error("Exception when calling WorkflowRunsApi->list_workflow_run_history: %s\n" % e)
            raise ApiException

        return api_response

    def get_workflow_run_history(self, project_token):
        """
        Get the workflow run history
        :param project_token:
        :return:
        """

        # Step 1 - get the run history
        configuration = self.get_ica_wes_configuration(project_token)
        run_id = self.ica_workflow_run_instance_id  # str | ID of the workflow run


        with libica.openapi.libwes.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libwes.WorkflowRunsApi(api_client)

        # Get api_response
        try:
            # Get a list of workflow run history events
            api_response = api_instance.list_workflow_run_history(run_id,
                                                                  page_size=1000)
        except ApiException as e:
            logger.error("Exception when calling WorkflowRunsApi->list_workflow_run_history: %s\n" % e)
            raise ApiException

        return api_response

    def get_task_ids_and_step_names_from_workflow_run_history(self, project_token):
        """
        Get tasks from the workflow run history -
        :return:
        """

        # Initialise task ids
        task_ids = []
        task_step_names = []

        # Get run history object
        workflow_run_history_obj = self.get_workflow_run_history(project_token)

        # Iterate through event details
        for item in workflow_run_history_obj.items:
            # Find only those with additional details / TaskRunId
            if not hasattr(item, 'event_details'):
                continue
            if item.event_details.get("additionalDetails", None) is None:
                continue
            if item.event_details.get("additionalDetails")[0].get('TaskRunId', None) is None:
                continue
            task_ids.append(item.event_details.get("additionalDetails")[0].get('TaskRunId'))
            task_step_names.append(self.get_task_step_name_from_absolute_path_and_state_name(
                absolute_path=item.event_details.get("additionalDetails")[0].get("AbsolutePath"),
                state_name=item.event_details.get("stateName")
            ))

        return task_ids, task_step_names

    @staticmethod
    def get_task_step_name_from_absolute_path_and_state_name(absolute_path, state_name):
        """

        # FIXME - how does a secondary subworkflow or secondary scattered task work?

        # Subworkflow task
        # "AbsolutePath": "/run_dragen_step-job-0/run_dragen_alignment_step_launch"
        # "Statename": "run_dragen_alignment_step_launch"

        # -> run_dragen_step/run_dragen_alignment_step

        # Scattered Task
        # "AbsolutePath": "/bcl_convert_step-job-1/bclConvert__3.7.5.cwl_launch"
        # "stateName": "bclConvert__3.7.5.cwl_launch"

        -> bcl_convert_step

        # -> bcl_convert_step
        # "AbsolutePath": /get_batch_dirs_launch
        # "stateName": "get_batch_dirs_launch"

        # -> get_batch_dirs
        :return:
        """

        if "/" + state_name == absolute_path:
            return re.sub("_launch$", "", state_name)

        # Create the regex obj
        re_abs_path_obj = re.match(r"^/(\w+)-job-\d+/(\S+)_launch$", absolute_path)

        # Check for a match
        if re_abs_path_obj == None:
            logger.error(f"Don't know how to handle step name \"{absolute_path}\"")
            raise GetStepNameError

        # Check the second component for if it matches '.cwl' at the end
        # Means we're in a scattered task, just return the first bit
        if re.match(f"\S+.cwl", re_abs_path_obj.group(2)):
            return re_abs_path_obj.group(1)

        # Otherwise we're in a subworkflow, return both
        return re_abs_path_obj.group(1) + "/" + re_abs_path_obj.group(2)

    def get_task_run_objs(self, project_token):
        """
        Get the task run objects as cwl objects
        :return:
        """
        # Initialise task objects
        task_objs = []

        # Get list of task ids
        task_ids, task_step_names = self.get_task_ids_and_step_names_from_workflow_run_history(project_token)

        # Get the task object
        for task_id, task_step_name in zip(task_ids, task_step_names):
            task_objs.append(ICATaskRun(ica_task_run_instance_id=task_id,
                                        task_step_name=task_step_name,
                                        project_token=project_token))

        return task_objs

    @staticmethod
    def get_workflow_duration(api_response):
        """
        Get the workflow duration in total seconds
        :param api_response:
        :return:
        """
        return int((api_response.time_stopped - api_response.time_started).total_seconds())

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

    def get_run_instance(self, project_token) -> WorkflowRun:
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
            "ica_workflow_name": self.ica_workflow_name,
            "ica_workflow_version_name": str(self.ica_workflow_version_name),
            "ica_workflow_run_name": self.ica_workflow_run_name,
            "ica_input": encode_compressed_base64(json.dumps(self.ica_input)),
            "ica_output": encode_compressed_base64(json.dumps(self.ica_output)),
            "ica_engine_parameters": encode_compressed_base64(json.dumps(self.ica_engine_parameters)),
            "workflow_start_time": self.workflow_start_time,
            "workflow_end_time": self.workflow_end_time,
            "workflow_duration": self.workflow_duration,
            "ica_tasks": [ica_task_obj.to_dict()
                          for ica_task_obj in self.ica_task_objs]
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

        return cls(
                   ica_workflow_run_instance_id=workflow_run_dict.get("ica_workflow_run_instance_id", None),
                   ica_workflow_id=workflow_run_dict.get("ica_workflow_id", None),
                   ica_workflow_name=workflow_run_dict.get("ica_workflow_name", None),
                   ica_workflow_version_name=workflow_run_dict.get("ica_workflow_version_name", None),
                   ica_workflow_run_name=workflow_run_dict.get("ica_workflow_run_name"),
                   ica_input=json.loads(decode_compressed_base64(workflow_run_dict.get("ica_input", None))),
                   ica_output=json.loads(decode_compressed_base64(workflow_run_dict.get("ica_output", None))),
                   ica_engine_parameters=json.loads(decode_compressed_base64(workflow_run_dict.get("ica_engine_parameters", None))),
                   workflow_start_time=workflow_run_dict.get("workflow_start_time"),
                   workflow_end_time=workflow_run_dict.get("workflow_end_time"),
                   workflow_duration=workflow_run_dict.get("workflow_duration"),
                   ica_task_objs=[ICATaskRun.from_dict(ica_task_obj_dict)
                                  for ica_task_obj_dict in workflow_run_dict.get('ica_tasks')]
                   )
