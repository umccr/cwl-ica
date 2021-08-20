#!/usr/bin/env python

from utils.globals import ICA_TES_INSTANCE_SIZES_BY_TYPE
from ruamel.yaml.comments import CommentedMap as OrderedDict
from utils.errors import ICATaskRunCreationError
import libica.openapi.libtes
from libica.openapi.libtes.rest import ApiException as ApiTESException
import libica.openapi.libgds
from libica.openapi.libgds import ApiException as APIGDSException
import json

from utils.logging import get_logger
from urllib.parse import urlparse
from utils.ica_utils import get_base_url
from pathlib import Path
import requests
import re
import pandas as pd
import numpy as np
from utils.miscell import encode_compressed_base64, decode_compressed_base64

logger = get_logger()

class ICATaskRun:
    """
    The ICA Task Run object
    """

    def __init__(self, ica_task_run_instance_id, task_step_name, task_name=None, task_cpus=None, task_memory=None,
                 task_start_time=None, task_stop_time=None, task_duration=None, task_metrics=None, project_token=None):
        """
        A task run instance ID that also contains the pod metrics of the task
        :param ica_task_run_instance_id:
        :param task_duration:
        :param task_metrics:
        """

        self.ica_task_run_instance_id = ica_task_run_instance_id
        self.task_step_name = task_step_name
        if task_name is not None:
          self.task_name = task_name
          self.task_cpus = task_cpus
          self.task_memory = task_memory
          self.task_start_time = task_start_time
          self.task_stop_time = task_stop_time
          self.task_duration = task_duration
          self.task_metrics = task_metrics
        else:
            api_response = self.get_task_object(project_token)
            self.task_name = self.get_task_name(api_response)
            self.task_cpus = self.get_task_cpus(api_response)
            self.task_memory = self.get_task_memory(api_response)
            self.task_start_time = int(api_response.time_created.timestamp())
            self.task_stop_time = int(api_response.time_modified.timestamp())
            self.task_duration = self.get_task_duration(api_response)
            self.task_metrics = self.get_metrics(api_response, project_token)

    @staticmethod
    def get_tes_configuration(access_token):
        """
        # FIXME - probably reusable code somewhere
        :return:
        """
        configuration = libica.openapi.libtes.Configuration(
            host=get_base_url(),
            api_key={
                "Authorization": access_token
            },
            api_key_prefix={
                "Authorization": "Bearer"
            }
        )
        return configuration

    @staticmethod
    def get_gds_configuration(access_token):
        """
        # FIXME - probably reusable code somewhere
        :return:
        """
        configuration = libica.openapi.libgds.Configuration(
            host=get_base_url(),
            api_key={
                "Authorization": access_token
            },
            api_key_prefix={
                "Authorization": "Bearer"
            }
        )
        return configuration

    def get_task_object(self, project_token):
        """
        Get the task object from ica
        :return:
        """
        configuration = self.get_tes_configuration(project_token)

        with libica.openapi.libtes.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libtes.TaskRunsApi(api_client)

        try:
            # Get the status of a task run
            api_response = api_instance.get_task_run(run_id=self.ica_task_run_instance_id)
        except ApiTESException as e:
            logger.error("Exception when calling TaskRunsApi->get_task_run: %s\n" % e)
            raise ApiTESException

        return api_response

    @staticmethod
    def get_task_name(api_response):
        return api_response.name

    @staticmethod
    def get_task_duration(api_response):
        return int((api_response.time_modified - api_response.time_created).total_seconds())

    @staticmethod
    def get_task_cpus(api_response):
        """
        Get the instance cpus
        :return:
        """
        resources_obj = api_response.execution.environment.resources

        if not resources_obj.cpu_cores == 0:
            return round(resources_obj.cpu_cores, 1)
        else:
            return ICA_TES_INSTANCE_SIZES_BY_TYPE.get(resources_obj.type).get(resources_obj.size).get("cpu")

    @staticmethod
    def get_task_memory(api_response):
        """
        Get the instance memory
        :return:
        """
        resources_obj = api_response.execution.environment.resources

        if not resources_obj.memory_gb == 0:
            return round(resources_obj.memory_gb, 1)
        else:
            return ICA_TES_INSTANCE_SIZES_BY_TYPE.get(resources_obj.type).get(resources_obj.size).get("memory")

    def get_metrics(self, api_response, project_token):
        """
        Collect the metrics as a json
        :param api_response:
        :param project_token:
        :return:
        """

        # Get / read pod metrics
        pod_metrics_file_path = self.get_pod_metrics_file(api_response)

        pod_metrics_url = self.get_pod_metrics_file_url(pod_metrics_file_path, project_token)

        pod_metrics_dict_list = self.read_pod_metrics_file(pod_metrics_url)

        pod_metrics_df = self.pod_metrics_to_df(pod_metrics_dict_list)

        return pod_metrics_df


    @staticmethod
    def get_pod_metrics_file(api_response):
        """
        Get the pod metrics
        :return:
        """
        # Get the dir by taking the dir of the stdout file, then add 'pod-metrics-0.log' as the basename
        stdout_url_obj = urlparse(api_response.logs[0].stdout)
        return stdout_url_obj.scheme + "://" + stdout_url_obj.netloc + str(Path(stdout_url_obj.path).parent / Path("pod-metrics-0.log"))

    def get_pod_metrics_file_url(self, pod_metrics_file, project_token):
        """
        Get the file from gds
        :param pod_metrics_file:
        :param project_token:
        :return:
        """

        configuration = self.get_gds_configuration(project_token)

        # Enter a context with an instance of the API client
        with libica.openapi.libgds.ApiClient(configuration) as api_client:
            # Create an instance of the API class
            api_instance = libica.openapi.libgds.FilesApi(api_client)

        # Get inputs for presigned url request
        volume_name = urlparse(str(pod_metrics_file)).netloc
        path = urlparse(str(pod_metrics_file)).path

        try:
            # Get a list of files
            api_response = api_instance.list_files(volume_name=[volume_name], path=[path], include="presignedUrl")
        except APIGDSException as e:
            logger.error("Exception when calling FilesApi->list_files: %s\n" % e)
            raise APIGDSException

        return api_response.items[0].presigned_url

    @staticmethod
    def read_pod_metrics_file(pod_metrics_url):
        """
        Read pod metrics file and return each line as a dict
        :return:
        """

        pod_lines = []

        fh = requests.get(pod_metrics_url)

        for line in fh.text.splitlines():
            pod_lines.append(json.loads(line.strip()))

        return pod_lines

    def pod_metrics_to_df(self, pod_metrics_dict_list):
        """
        Convert the pod metrics file to a pandas dataframe with each time attribute
        :return:
        """

        # Get pod metrics df
        pod_metrics_df = pd.DataFrame([self.get_usage_dict(pod_metrics_dict)
                                       for pod_metrics_dict in pod_metrics_dict_list
                                       if self.get_usage_dict(pod_metrics_dict) is not None])

        # Compress duplicate values
        pod_metrics_df.drop_duplicates(inplace=True)

        # Drop na values
        pod_metrics_df.dropna(axis='index', how='any', inplace=True)

        return pod_metrics_df

    @staticmethod
    def get_usage_dict(pod_metrics_dict):
        """
        From a pod metric return the task dict
        :param pod_metrics_dict:
        :return:
        """
        # Get time stamp
        cpu = None
        memory = None

        if pod_metrics_dict.get("containers", None) is None:
            return None

        for container in pod_metrics_dict.get('containers'):
            # Make sure this is a task dict
            if not container.get('name') == "task":
                continue

            # Get the usage attributes
            if not "usage" in container.keys():
                continue

            usage = container.get('usage')

            # CPU usage is in 'metric'
            if "cpu" in usage.keys():
                cpu = usage['cpu']

                if cpu.endswith("n"):
                    cpu = int(re.sub("n$", "", cpu)) / pow(10, 9)
                elif cpu.endswith("u"):
                    cpu = int(re.sub("u$", "", cpu)) / pow(10, 6)
                elif cpu.endswith("m"):
                    cpu = int(re.sub("m$", "", cpu)) / pow(10, 3)
                elif cpu.isdigit():
                    cpu = int(cpu)
            else:
                cpu = np.nan

            # Memory is in 'binary' - we want it in GBs
            if "memory" in usage.keys():
                memory = usage["memory"]

                if memory.endswith("Ti"):
                    memory = float(re.sub("Ti$", "", memory) * pow(2, 10))

                elif memory.endswith("Gi"):
                    memory = float(re.sub("Gi$", "", memory))

                elif memory.endswith("Mi"):
                    memory = float(re.sub("Mi$", "", memory)) / pow(2, 10)

                elif memory.endswith("Ki"):
                    memory = float(re.sub("Ki$", "", memory)) / pow(2, 20)

                else:
                    memory = memory / pow(2, 30)

        if memory is None or cpu is None:
            return None

        # Round values
        memory = round(memory, 1)
        cpu = round(cpu, 1)

        # Get epoch value
        timestamp = int(pd.to_datetime(pod_metrics_dict.get('timestamp')).timestamp())

        return {"timestamp": timestamp, "cpu": cpu, "memory": memory}

    @staticmethod
    def compress_metrics(metrics_df):
        """
        Compress the metrics df by gzip -> base64 method
        :return:
        """

        return encode_compressed_base64(json.dumps(metrics_df.to_dict(orient="records")))

    @staticmethod
    def decompress_metrics(compressed_string):
        """
        Decompress the metrics df and return pandas dataframe
        :param compressed_string:
        :return:
        """
        return pd.DataFrame(json.loads(decode_compressed_base64(compressed_string)),
                            # Add in columns, just in case it's an empty dataframe
                            columns=["timestamp", "cpu", "memory"])

    # to_dict - write out input, output and engine_parameters in base64
    def to_dict(self):
        """
        Return an ordered dictionary
        :return:
        """
        return OrderedDict({
            "ica_task_run_instance_id": self.ica_task_run_instance_id,
            "task_step_name": self.task_step_name,
            "task_name": self.task_name,
            "task_cpus": self.task_cpus,
            "task_memory": self.task_memory,
            "task_start_time": self.task_start_time,
            "task_stop_time": self.task_stop_time,
            "task_duration": self.task_duration,
            "task_metrics": self.compress_metrics(self.task_metrics)
        })

    # from_dict - read in input, output and engine_parameters in base64
    @classmethod
    def from_dict(cls, task_run_dict):
        """
        Create a ICAWorkflowVersion object from a dictionary
        :return:
        """

        # Check the item_dict has the appropriate keys
        if task_run_dict.get("ica_task_run_instance_id", None) is None:
            logger.error("\"ica_task_run_instance_id\" attribute not found, cannot create ICATaskRun")
            raise ICATaskRunCreationError

        return cls(
                   ica_task_run_instance_id=task_run_dict.get("ica_task_run_instance_id", None),
                   task_step_name=task_run_dict.get("task_step_name"),
                   task_name=task_run_dict.get("task_name"),
                   task_cpus=int(task_run_dict.get("task_cpus")),
                   task_memory=int(task_run_dict.get("task_memory")),
                   task_start_time=int(task_run_dict.get("task_start_time")),
                   task_stop_time=int(task_run_dict.get("task_stop_time")),
                   task_duration=int(task_run_dict.get("task_duration")),
                   task_metrics=cls.decompress_metrics(task_run_dict.get("task_metrics"))
                   )


