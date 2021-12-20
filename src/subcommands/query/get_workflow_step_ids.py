#!/usr/bin/env python

"""
Need to tinker a workflow? No idea where to start?
If you need to tinker the engine parameters of a workflow, you will need to first know the step id of that
you wish to change the parameters to
"""

from classes.command import Command
from utils.logging import get_logger
from utils.repo import read_yaml, get_workflow_yaml_path, get_workflows_dir

from pathlib import Path
from typing import Optional
from classes.item_workflow import ItemWorkflow
from classes.item_version_workflow import ItemVersionWorkflow
from utils.miscell import cwl_id_to_path, get_name_version_tuple_from_cwl_file_path, get_items_dir_from_cwl_file_path
from utils.errors import CWLItemNotFound, CheckArgumentError
from classes.cwl_workflow import CWLWorkflow

from pprint import pprint

logger = get_logger()

class GetWorkflowStepIDs(Command):
    """Usage:
    cwl-ica [options] get-workflow-step-ids help
    cwl-ica [options] get-workflow-step-ids (--workflow-path="<path_to_cwl_workflow>")

Description:
    Collect the step ids for a given cwl workflow, including the subworkflows

Options:
    --workflow-path=<path_to_cwl_workflow>      Required, CWL Workflow to collect step ids for

Example:
    cwl-ica get-workflow-step-ids --workflow-path workflows/bclconversion/3.7.5/bclconversion__3.7.5.cwl
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise values
        self.cwl_file_path = None  # type: Optional[Path]
        self.name = None  # type: Optional[str]
        self.version = None  # type: Optional[str]
        self.cwl_item = None  # type: Optional[ItemVersionWorkflow]
        self.cwl_obj = None  # type: Optional
        self.step_ids = []

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

    def __call__(self):
        """
        Just run through this
        :return:
        """

        logger.info("Getting workflow steps")
        self.step_ids = self.get_steps_of_cwl_workflow(self.cwl_file_path, self.cwl_obj)

        logger.info("Printing the step ids")
        pprint([str(step_id) for step_id in self.step_ids], indent=4)

    def check_args(self):
        """
        Check if output path arg is set
        :return:
        """
        # Set output_path
        cwl_file_path_arg = self.args.get("--workflow-path", None)

        # Check if output arg is set
        if cwl_file_path_arg is None:
            logger.error("Please set the --workflow-path")
            raise CheckArgumentError
        else:
            self.cwl_file_path = Path(cwl_file_path_arg)
            
        if not self.cwl_file_path.is_file():
            logger.error(f"Could not find --workflow-path arg {self.cwl_file_path}")
            raise FileNotFoundError

        # Get the cwl item from version
        self.name, self.version = get_name_version_tuple_from_cwl_file_path(self.cwl_file_path,
                                                                            items_dir=get_workflows_dir())

        # Get the cwl item
        cwl_version_items = [version
                             for workflow_dict in read_yaml(get_workflow_yaml_path())["workflows"]
                             if ItemWorkflow.from_dict(workflow_dict).name == self.name
                             for version in ItemWorkflow.from_dict(workflow_dict).versions
                             if version.name == self.version
                             ]

        if len(cwl_version_items) == 0:
            logger.error(f"Could not find workflow in {get_workflow_yaml_path()}")
            raise CWLItemNotFound

        # Get the cwl obj
        self.cwl_item: ItemVersionWorkflow = cwl_version_items[0]

        # Call the item object to set the cwl object
        self.cwl_item()

        # Pull out the cwl object
        parser = self.cwl_item.cwl_obj.parser
        self.cwl_obj: parser.Workflow = self.cwl_item.cwl_obj.cwl_obj

    def get_steps_of_cwl_workflow(self, cwl_file_path, cwl_obj, path_prefix=Path()):
        """
        Get the workflow object
        :return:
        """
        step_ids = []

        for step in cwl_obj.steps:
            step_run_path = cwl_file_path.parent.absolute().joinpath(step.run).resolve()
            step_items_dir = get_items_dir_from_cwl_file_path(step_run_path)
            if step_items_dir.name == 'workflows':
                logger.info(f"Step {cwl_id_to_path(step.id).name} is a subworkflow, importing")
                # Step is a subworkflow
                # Get name / version of subworkflow
                step_name, step_version = get_name_version_tuple_from_cwl_file_path(step_run_path, step_items_dir)
                step_cwl_wf_obj = CWLWorkflow(step_name, step_version, step_run_path)
                # Call the step object
                step_cwl_wf_obj()
                step_cwl_obj = step_cwl_wf_obj.cwl_obj

                step_ids.extend(self.get_steps_of_cwl_workflow(step_run_path, step_cwl_obj,
                                                               path_prefix=Path(path_prefix) / Path(step.run).name))
            else:
                step_ids.append(path_prefix / cwl_id_to_path(step.id).name)

        return step_ids
