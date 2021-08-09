#!/usr/bin/env python3

"""
List either tool or workflow runs filtering by either a tool path or a workflow path and also a project name

Returns a md style dataframe with the following contents

1. Run ID
2. Project
3. Workflow Name
4. Workflow Version
"""

from classes.command import Command
from utils.logging import get_logger
from utils.errors import ProjectNotFoundError
import pandas as pd
from utils.repo import read_yaml, get_project_yaml_path, get_run_yaml_path
import sys
from typing import Optional, List
from pathlib import Path
from utils.miscell import get_name_version_tuple_from_cwl_file_path
from classes.project import Project
from classes.ica_workflow import ICAWorkflow
from classes.ica_workflow_run import ICAWorkflowRun
from datetime import datetime, timedelta
from utils.ica_utils import get_base_url, get_projects_list_with_token
logger = get_logger()


class ListRuns(Command):
    """
    Super class to ListRunsTools and ListRunsWorkflows
    """

    def __init__(self, command_argv, item_type=None, item_type_key=None, items_dir=None):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise values
        self.item_type = item_type
        self.item_type_key = item_type_key
        self.items_dir = items_dir
        self.cwl_file_path = None  # type: Optional[Path]
        self.name = None  # type: Optional[str]
        self.version = None  # type: Optional[str]
        self.projects_list = None  # type: Optional[List[Project]]
        self.ica_item_list = None  # type: Optional[List[ICAWorkflow]]
        self.ica_runs_list = None  # type: Optional[List[ICAWorkflowRun]]
        self.df = None  # type: Optional[pd.DataFrame]

        # Check args
        self.check_args()

        # Filter runs
        self.filter_runs()

        # Get the dataframe
        self.build_df()

    def __call__(self):
        """
        Print out the dataframe to markdown
        :return:
        """

        # Print the dataframe
        self.print_df()

    def check_args(self):
        """
        Check and set the following:
        --tool-path / --workflow-path is set correctly
        if --project is set it matches a project in project.yaml
        :return:
        """
        self.cwl_file_path = self.get_cwl_file_path_arg()

        if self.cwl_file_path is not None:
            self.name, self.version = get_name_version_tuple_from_cwl_file_path(self.cwl_file_path,
                                                                                items_dir=self.items_dir)

        # Get project attr
        projects: List[Project] = [Project.from_dict(project_dict)
                                   for project_dict in read_yaml(get_project_yaml_path())["projects"]]

        # Get project arg
        if self.args.get("--project", None) is not None:
            for project in projects:
                if project.project_name == self.args.get("--project"):
                    self.projects_list = [project]
                    break
            else:
                logger.error(f"--project '{self.args.get('--project')}' could not be found in project.yaml")
                raise ProjectNotFoundError
        else:
            self.projects_list = projects

        # Get runs attr
        self.ica_runs_list: List[ICAWorkflowRun] = [ICAWorkflowRun.from_dict(workflow_run_dict)
                                                    for workflow_run_dict in read_yaml(get_run_yaml_path())["runs"]]

        # Get item list
        for project in self.projects_list:
            if self.ica_item_list is None:
                self.ica_item_list = project.get_items_by_item_type(self.item_type)
            else:
                self.ica_item_list.extend(project.get_items_by_item_type(self.item_type))

    def filter_runs(self):
        """
        Filter the runs based on workflow and project
        :return:
        """

        new_runs_list: List[ICAWorkflowRun] = []

        # Filter by cwl file path and project
        for run in self.ica_runs_list:
            for item in self.ica_item_list:
                # Get the item list
                if not run.ica_workflow_id == item.ica_workflow_id:
                    continue
                for version in item.versions:
                    # Filter by file path
                    if (self.name is not None and not self.name == item.name) or (self.version is not None and not self.version == version.name):
                        continue
                    # Filter by project
                    if run.ica_workflow_id == item.ica_workflow_id and run.ica_workflow_version_name:
                        new_runs_list.append(run)

        # Reassign new runs list
        self.ica_runs_list = new_runs_list

    def build_df(self):
        """
        Build the dataframe from the projects and runs objects
        :return:
        """
        # Initialise dataframe
        self.df = pd.DataFrame(columns=["run_id", "launch_project_name", "project_name", "workflow_id", "workflow_version_name", "start_time", "end_time", "duration"])

        for run in self.ica_runs_list:
            self.df = self.df.append({
                "run_id": run.ica_workflow_run_instance_id,
                "launch_project_name": [project.name
                                        for project in get_projects_list_with_token(get_base_url(), self.projects_list[0].get_project_token())
                                        if project.id == run.ica_project_launch_context_id
                                        ][0],
                "project_name": [project.project_name
                                 for project in self.projects_list
                                 for ica_item in project.get_items_by_item_type(self.item_type)
                                 if ica_item.ica_workflow_name == run.ica_workflow_name][0],
                "workflow_id": run.ica_workflow_id,
                "workflow_version_name": run.ica_workflow_name,
                "start_time": datetime.fromtimestamp(run.workflow_start_time),
                "end_time": datetime.fromtimestamp(run.workflow_end_time),
                "duration": timedelta(seconds=run.workflow_duration)
            }, ignore_index=True)

    def print_df(self):
        """
        Print the dataframe to markdown
        :return:
        """
        self.df.rename(columns={"run_id": "Run ID",
                                "launch_project_name": "Launch Project Name",
                                "project_name": "Project Name",
                                "workflow_id": "ICA Workflow ID",
                                "workflow_version_name": "ICA Workflow Version Name",
                                "start_time": "Start Time",
                                "end_time": "End Time",
                                "duration": "Duration"}).to_markdown(sys.stdout, index=False)
        # Add empty line to bottom
        print()

    def get_cwl_file_path_arg(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError
