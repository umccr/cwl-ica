#!/usr/bin/env python

"""
Register a run instance id, add the run object to run.yaml, update the run_instances in the project version
"""

from classes.command import Command
from classes.ica_workflow_run import ICAWorkflowRun
from utils.logging import get_logger
from utils.repo import read_yaml, get_project_yaml_path, get_run_yaml_path
from utils.yaml import dump_yaml
from os import environ
from utils.errors import CheckArgumentError, ProjectNotFoundError, ICAWorkflowRunExistsError, ItemNotFoundError, ICAWorkflowRunNotFoundError
from classes.project import Project

logger = get_logger()

class RegisterRunInstance(Command):
    """
    The class object of the Command object
    """

    def __init__(self, command_argv, item_type, item_type_key):
        # Call super class
        super(RegisterRunInstance, self).__init__(command_argv)

        # Set initialisers - set in check_args
        self.project_name = None
        self.ica_workflow_run_instance_id = None
        # Set in init downstream
        self.project_obj = None
        self.run_obj = None

        # Set items
        self.item_type = item_type  # tool / workflow
        self.item_type_key = item_type_key  # tools / workflow

        # Check help
        self.check_length(command_argv)

        # Check if help has been called
        if self.args["help"]:
            self._help()

        # Confirm 'required' arguments are present and valid
        try:
            self.check_args()
        except CheckArgumentError:
            self._help(fail=True)

        # Get the project object
        self.set_objs()

        # Check the runs yaml
        self.check_runs_yaml()


    def __call__(self):
        """
        Write out the run to run.yaml
        Write out the run instance into the project object / workflow version
        :return:
        """

        # Write out the run yaml
        logger.info(f"Appending run '{self.ica_workflow_run_instance_id}' to run.yaml")
        self.write_run_yaml()

        # Write out the project yaml
        logger.info(f"Adding run instance '{self.ica_workflow_run_instance_id} to project '{self.project_name}' in project.yaml")
        self.write_projects_yaml()

    def set_objs(self):
        """
        Set the project object and check that the workflow id and workflow version are legit
        :return:
        """
        for project in read_yaml(get_project_yaml_path())["projects"]:
            if project.get("project_name") == self.project_name:
                self.project_obj = Project.from_dict(project)
            break
        else:
            raise ProjectNotFoundError

        # Create the run object
        self.set_run_obj()

        # Check the project object contains the workflow ID and workflow version
        self.add_run_to_project()

    def set_run_obj(self):
        """
        Get the run from the workflow run instance id and the access token
        :return:
        """
        self.run_obj = ICAWorkflowRun(self.ica_workflow_run_instance_id, project_token=self.get_access_token())

    def get_access_token(self):
        """
        Get the access token from cli, env, project in that order
        :return:
        """
        # From CLI
        if self.args.get("--access-token", None) is not None:
            logger.debug("Using token from cli")
            return self.args.get("--access-token")
        # From Env
        if environ.get("ICA_ACCESS_TOKEN", None) is not None:
            logger.debug("Using token from environment")
            return environ.get("ICA_ACCESS_TOKEN")
        # From project
        return self.project_obj.get_project_token()

    def check_runs_yaml(self):
        """
        Check that the run doesn't already exist in the runs yaml
        :return:
        """
        runs_yaml_path = get_run_yaml_path(non_existent_ok=True)

        if not runs_yaml_path.is_file():
            # Nothing to worry about
            return

        all_runs_list = read_yaml(runs_yaml_path)["runs"]

        for run_dict in all_runs_list:
            if run_dict.get("ica_workflow_run_instance_id") == self.ica_workflow_run_instance_id:
                logger.error(f"ica workflow run '{self.ica_workflow_run_instance_id}' already exists in run.yaml")
                raise ICAWorkflowRunExistsError

    def write_run_yaml(self):
        """
        Write out the run yaml file
        :return:
        """

        runs_yaml_path = get_run_yaml_path(non_existent_ok=True)

        if not runs_yaml_path.is_file():
            all_runs_list = []
        else:
            all_runs_list = read_yaml(runs_yaml_path)["runs"]

        # Append the run to the all runs list
        all_runs_list.append(self.run_obj.to_dict())

        with open(get_run_yaml_path(non_existent_ok=True), "w") as runs_h:
            dump_yaml({"runs": all_runs_list}, runs_h)

    def write_projects_yaml(self):
        """
        Re-write projects dictionary
        :return:
        """

        all_projects_list = read_yaml(get_project_yaml_path())['projects']
        new_all_projects_list = all_projects_list.copy()

        for i, project_dict in enumerate(all_projects_list):
            if not project_dict.get("project_name") == self.project_name:
                continue
            new_all_projects_list[i] = self.project_obj.to_dict()

        with open(get_project_yaml_path(), "w") as project_h:
            dump_yaml({"projects": new_all_projects_list}, project_h)

    def add_run_to_project(self):
        """
        Add the run object to the project object
        :return:
        """
        if self.item_type == "tool":
            ica_item_list = self.project_obj.ica_tools_list
        elif self.item_type == "workflow":
            ica_item_list = self.project_obj.ica_workflows_list
        else:
            raise ItemNotFoundError

        for ica_item in ica_item_list:
            # Skip if not match
            if not ica_item.ica_workflow_id == self.run_obj.ica_workflow_id:
                continue
            is_break = False
            for ica_item_version in ica_item.versions:
                # Skip if not match
                if not ica_item_version.ica_workflow_version_name == self.run_obj.ica_workflow_version_name:
                    continue
                # We've found a match!
                is_break = True
                # Check run instance is not already here
                if self.run_obj.ica_workflow_run_instance_id in ica_item_version.run_instances:
                    logger.error(f"Run instance already exists in project '{self.project_name}'")
                    raise ICAWorkflowRunExistsError
                ica_item_version.run_instances.append(self.run_obj.ica_workflow_run_instance_id)
                break

            # We've found a match!
            if is_break:
                break

        else:
            logger.error(f"Error I could not place the run in the project yaml since "
                         f"I cannot find '{self.run_obj.ica_workflow_id}' "
                         f"version '{self.run_obj.ica_workflow_version_name}' in "
                         f"project '{self.project_name}/{self.item_type_key}' in project.yaml")
            raise ICAWorkflowRunNotFoundError

    def check_args(self):
        """
        Usually implemented in subclass but in this case all parameters are the same for each tool / workflow

        Check --project-name is defined
        Check --ica-workflow-run-instance-id is defined
        :return:
        """
        # Project name
        if self.args.get("--project-name", None) is None:
            logger.error("Could not get project name arg")
            raise CheckArgumentError
        self.project_name = self.args.get("--project-name")

        # Run instance id
        if self.args.get("--ica-workflow-run-instance-id", None) is None:
            logger.error("Could not get the workflow run instance arg")
            raise CheckArgumentError
        self.ica_workflow_run_instance_id = self.args.get("--ica-workflow-run-instance-id")





