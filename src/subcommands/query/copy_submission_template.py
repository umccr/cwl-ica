#!/usr/bin/env python3

"""
Pre script for taking in a workflow run object,
Populating the inputs, name and engine parameter attributes
Creates a shell script to launch the command through the ica console.

--curl option to create a curl command request instead or --ica instead for using the ica binary
--prefix option to specify output path for shell script and json otherwise use the basename of the run name
Checks if the 'context-switcher' command is available and uses that
"""

from classes.command import Command
from utils.logging import get_logger
from utils.repo import read_yaml
from utils.ica_utils import get_projects_list_with_token, get_base_url, get_region_from_base_url

from pathlib import Path
from typing import Optional, List
from classes.project import Project
from classes.project_production import ProductionProject
from utils.repo import get_run_yaml_path, get_project_yaml_path
from utils.errors import CheckArgumentError, ProjectNotFoundError
from classes.ica_workflow import ICAWorkflow
from classes.ica_workflow_version import ICAWorkflowVersion
from classes.ica_workflow_run import ICAWorkflowRun
import json

logger = get_logger()


class CopySubmissionTemplate(Command):
    """
    SuperClass to CopyWorkflowSubmissionTemplate command
    """

    def __init__(self, command_argv, item_type=None, item_type_key=None):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise values
        self.item_type = item_type  # type: Optional[str]
        self.item_type_key = item_type_key  # type: Optional[str]
        self.output_json_path = None  # type: Optional[Path]
        self.output_shell_path = None  # type: Optional[Path]
        self.launch_name = None  # type: Optional[str]
        self.run_obj = None  # type: Optional[ICAWorkflowRun]
        self.run_instance_id = None  # type: Optional[str]
        self.project_obj = None  # type: Optional[Project]
        self.launch_project_name = None  # type: Optional[str]
        self.is_curl = None  # type: Optional[bool]

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

        # Then get run object
        self.run_obj = self.get_run_obj()

        # Then get project name
        self.launch_project_name = self.get_project_name_from_project_id()


    def __call__(self):
        """
        Just run through this
        :return:
        """

        logger.info(f"Writing json file to {self.output_json_path}")
        self.write_json_file()

        logger.info(f"Writing wrapper script to {self.output_shell_path}")
        self.write_shell_script()


    def check_args(self):
        """
        Check if output path arg is set
        Check
        :return:
        """

        # Get run instance id
        run_instance_id_arg = self.args.get("--ica-workflow-run-instance-id", None)
        if run_instance_id_arg is None:
            logger.error("--ica-workflow-run-instance-id was not specified")
            raise CheckArgumentError
        self.run_instance_id = run_instance_id_arg

        # Get the run object
        self.run_obj = self.get_run_obj()

        # Get the project object
        self.project_obj = self.get_project_object()

        # Get the launch project name
        self.launch_project_name = self.get_project_name_from_project_id()

        # Get the output json path
        if self.args.get("--prefix", None) is None:
            logger.info(f"--prefix not specified, using {self.run_obj.ica_workflow_run_instance_id} as a default")
            prefix = self.run_obj.ica_workflow_run_instance_id
        else:
            prefix = self.args.get("--prefix")

        self.launch_name = prefix
        self.output_json_path = Path(prefix + ".template.json")
        self.output_shell_path = Path(prefix + ".launch.sh")

        # Set is_curl
        self.is_curl = True if self.args.get("--curl", False) else False

    def get_run_obj(self) -> ICAWorkflowRun:
        """
        Iterate through run object and get the run instance id
        :return:
        """
        run_objs: List[ICAWorkflowRun] = [
                                          ICAWorkflowRun.from_dict(workflow_run_dict)
                                          for workflow_run_dict in read_yaml(get_run_yaml_path())["runs"]
                                          if workflow_run_dict.get("ica_workflow_run_instance_id") == self.run_instance_id
                                          ]

        if len(run_objs) == 0:
            logger.error(f"Could not find --ica-workflow-run-instance-id arg '{self.run_instance_id}' in run yaml")
            raise CheckArgumentError

        return run_objs[0]

    def get_project_object(self) -> Project:
        """
        Get the project object -> this is the project that the workflow belongs to,
        not necessarily the run itself
        """

        projects_list: List[Project] = [Project.from_dict(project_dict)
                                        if not project_dict.get("production", False)
                                        else ProductionProject.from_dict(project_dict)
                                        for project_dict in read_yaml(get_project_yaml_path())["projects"]]

        for project in projects_list:
            ica_item_list: List[ICAWorkflow] = project.get_items_by_item_type(self.item_type)
            for ica_workflow in ica_item_list:
                version: ICAWorkflowVersion
                for version in ica_workflow.versions:
                    run_instance_id: str
                    for run_instance in version.run_instances:
                        if run_instance == self.run_instance_id:
                            return project
        else:
            raise ProjectNotFoundError

    def get_project_name_from_project_id(self) -> str:
        """
        Get project name from project id
        :return:
        """
        # Use wes ica to list projects and then find items that match said project
        project_list = get_projects_list_with_token(get_base_url(), self.project_obj.get_project_token())
        for project in project_list:
            if project.id == self.run_obj.ica_project_launch_context_id:
                return project.name
        else:
            raise ProjectNotFoundError

    def write_json_file(self):
        """
        Write the json file containing the run json object as specified in the run yaml
        :return:
        """

        # Get engine parameters pop any unnecessary ones
        engine_parameters = self.run_obj.ica_engine_parameters.copy()
        unnecessary_engine_parameters = [
            'tesUseInputManifest',
            'cwltool',
            'engine',
        ]

        for parameter in unnecessary_engine_parameters:
            if parameter in list(engine_parameters.keys()):
                _ = engine_parameters.pop(parameter)

        run_dict = {
            "name": self.launch_name,
            "input": self.run_obj.ica_input,
            "engineParameters": engine_parameters
        }
        with open(self.output_json_path, 'w') as json_h:
            json.dump(run_dict, json_h, indent=4)

    def write_shell_script(self):
        """
        Write the script that builds the launch object
        :return:
        """

        with open(self.output_shell_path, 'w') as shell_h:
            # Start with the shebang
            shell_h.write("#!/usr/bin/env bash\n\n")

            # Add docs
            shell_h.write(f"# Use this script to launch the input json '{self.output_json_path.name}'\n\n")

            # Source ica-ica-lazy functions (bash functions might be exported but doesn't help if user
            # is running zsh
            shell_h.write("# Source ica-ica-lazy functions if they exist\n")
            shell_h.write("if [[ -d \"$HOME/.ica-ica-lazy/functions\" ]]; then\n")
            shell_h.write("    for f in \"$HOME/.ica-ica-lazy/functions/\"*\".sh\"; do\n")
            shell_h.write("        .  \"$f\"\n")
            shell_h.write("    done\n")
            shell_h.write("fi\n\n")
            # Then start with the context switch command
            shell_h.write(f"# Enter the right context to launch the workflow\n")
            shell_h.write(f"if type ica-context-switcher >/dev/null; then\n")
            shell_h.write(f"    ica-context-switcher --project-name '{self.launch_project_name}' --scope 'admin'\n")
            shell_h.write(f"else\n")
            shell_h.write(f"    ica projects enter '{self.launch_project_name}'\n")
            if self.is_curl:
                shell_h.write(f"    export ICA_ACCESS_TOKEN=\"$(yq eval '.access-token' ~/.ica/.session.{get_region_from_base_url(get_base_url())}.yaml)\"\n")
            shell_h.write("fi\n\n")

            # Check if 'ica-check-cwl-inputs' is in the path and then run it!
            shell_h.write("if type \"ica-check-cwl-inputs\"; then\n")
            shell_h.write(f"    ica-check-cwl-inputs \\\n")
            shell_h.write(f"        --input-json {self.output_json_path} \\\n")
            shell_h.write(f"        --ica-workflow-id {self.run_obj.ica_workflow_id} \\\n")
            shell_h.write(f"        --ica-workflow-version-name {self.run_obj.ica_workflow_version_name}\n")
            shell_h.write("fi\n\n")

            # Then set the launch command
            if self.is_curl:
                shell_h.write("# Submit command through curl\n")
                shell_h.write(f"curl \\\n"
                              f"    --request POST \\\n"
                              f"    --url \"{get_base_url()}/v1/workflows/{self.run_obj.ica_workflow_id}/versions/{self.run_obj.ica_workflow_version_name}:launch\" \\\n"
                              f"    --header \"Accept: application/json\" \\\n"
                              f"    --header \"Context-Type: application/json\" \\\n"
                              f"    --header \"Authorization: Bearer ${{ICA_ACCESS_TOKEN}}\" \\\n"
                              f"    --data \"@{self.output_json_path}\"\n")
            else:
                shell_h.write("# Submit command through ica binary\n")
                shell_h.write(f"ica workflows versions launch {self.run_obj.ica_workflow_id} {self.run_obj.ica_workflow_version_name} {self.output_json_path}\n")