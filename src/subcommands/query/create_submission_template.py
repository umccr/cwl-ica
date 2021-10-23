#!/usr/bin/env python3

"""
Use this command if there is no existing workflow run for a given command.
Like copy-submission-template, with this tool you will receive a bash script and input json file to populate

Rather than relying on make-template, we use the cwl-utils to import the cwl-object and collect the input items.

For files, we set the "class" to "File" and "location" to "gds://path-to-gds-file"
For directories we set the "class" to "Directory" and "location" to "gds://path/to/gds-directory/"

Schema items are also populated as anticipated.

If an input can be of multiple types (i.e a file OR a string), we choose the first one in the CWL Object.
"""


from classes.command import Command
from utils.logging import get_logger
from utils.ica_utils import get_base_url, get_region_from_base_url

from pathlib import Path
from typing import Optional, List
from classes.project import Project
from utils.errors import CheckArgumentError
from classes.cwl import CWL
from classes.cwl_schema import CWLSchema
import json
from utils.project import get_project_object_from_project_name
from typing import Dict
import re
from utils.miscell import get_name_version_tuple_from_cwl_file_path

logger = get_logger()


class CreateSubmissionTemplate(Command):
    """
    SuperClass to CreateWorkflowSubmissionTemplate command
    Pre script for taking in a workflow run object,
    Populating the inputs, name and engine parameter attributes
    Creates a shell script to launch the command through the ica console.

    --curl option to create a curl command request instead or --ica instead for using the ica binary
    --prefix option to specify output path for shell script and json otherwise use the basename of the run name
    Checks if the 'context-switcher' command is available and uses that
    """

    def __init__(self, command_argv, item_dir=None, item_type=None, item_type_key=None):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise values
        self.item_dir = item_dir  # type: Optional[Path]
        self.item_type = item_type  # type: Optional[str]
        self.item_type_key = item_type_key  # type: Optional[str]
        self.item_name = None  # type: Optional[str]
        self.item_version = None  # type: Optional[str]
        self.cwl_file_path = None  # type: Optional[Path]
        # self.output_json_path = None  # type: Optional[Path]
        self.output_yaml_path = None  # type: Optional[Path]
        self.output_shell_path = None  # type: Optional[Path]
        self.launch_name = None  # type: Optional[str]
        self.project_obj = None  # type: Optional[Project]
        self.cwl_obj = None  # type: Optional[CWL]
        self.launch_project_name = None  # type: Optional[str]
        self.is_curl = None  # type: Optional[bool]
        self.cwl_inputs = None  # type: Optional[Dict]

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
        Just run
        :return:
        """

        logger.info(f"Writing out input yaml file to {self.output_yaml_path}")
        self.write_yaml_file()

        logger.info(f"Writing wrapper script to {self.output_shell_path}")
        self.write_shell_script()

    def get_item_arg(self) -> str:
        """
        Get --workflow-path or --tool-path from args
        :return:
        """
        raise NotImplementedError

    def check_args(self):
        """
        Check if output path arg is set
        Check
        :return:
        """

        # Get path
        item_path_arg = self.get_item_arg()

        # Check dir
        output_prefix_arg = self.args.get("--prefix")

        # Get name and version from item path
        self.item_name, self.item_version = get_name_version_tuple_from_cwl_file_path(cwl_file_path=self.cwl_file_path,
                                                                                      items_dir=self.item_dir)

        # Get the project object
        project_name = self.args.get("--project")
        if project_name is None:
            logger.error("--project must be defined")
            raise CheckArgumentError
        self.project_obj = get_project_object_from_project_name(project_name)

        # Get the launch project name (this is used in the ica-context-switcher OR ica projects enter command)
        launch_project_name = self.args.get("--launch-project")
        if launch_project_name is not None:
            self.launch_project_name = launch_project_name

        # Get the output json object
        if self.args.get("--prefix", None) is None:
            logger.info(f"--prefix not specified, using {self.item_name}__{self.item_version} as a default")
            prefix = f"{self.item_name}__{self.item_version}"
        else:
            prefix = self.args.get("--prefix")

        self.launch_name = prefix
        self.output_yaml_path = Path(prefix + ".template.yaml")
        self.output_shell_path = Path(prefix + ".launch.sh")

        # Set is_curl
        self.is_curl = True if self.args.get("--curl", False) else False

        # Get inputs from object
        self.cwl_inputs = self.get_cwl_inputs_from_object()

    def get_cwl_inputs_from_object(self) -> Dict:
        """
        Get cwl inputs from a cwl object

        Should return a dictionary with the input id as the key and with each item having the following attributes:
        * label
        * doc
        * cwl_type
        * is_array
        * optional
        * secondaryFiles
        * schema_obj*
        * symbols*

        If the item is an array, cwl_type will still be 'File' but is_array is set to '1'
        If the item is a schema, cwl_type can be set to 'schema' and the schema_obj attribute is set.
        If the item is an enum, cwl_type can be set to 'enum' and the symbols attribute is set

        :return:
        """

        inputs = {}

        input_item: CreateSubmissionTemplate.cwl_obj.parser.WorkflowInputParameter
        for input_item in self.cwl_obj.cwl_obj.inputs:
            # Get the input id
            input_id = self.get_input_name_from_id(input_item.id)
            input_obj = {
                "label": input_item.label,
                "doc": input_item.doc,
                "optional": False
            }

            # Check if we get an array (this likely means first option is null)
            if isinstance(input_item, list):
                # Check elements are in array
                if len(input_item) < 1:
                    logger.warning("Input item has no length, skipping")
                    continue
                # Check if first option is null (means an optional item)
                elif input_item[0] == 'null':
                    # Pop null item
                    _ = input_item.pop(0)
                    input_obj["optional"] = True

                if len(input_item) == 0:
                    logger.warning("Input item has no length, skipping")
                    continue
                elif len(input_item) == 1:
                    input_item = input_item[0]
                elif all([isinstance(_item.type, str) for _item in input_item]):
                    input_obj["cwl_type"] = [_item.type for _item in input_item]
                else:
                    logger.warning("Can't handle multiple types that aren't simple")
                    continue

            # Handle InputArraySchema objects
            if isinstance(input_item, list):
                # Handled above
                pass
            elif isinstance(input_item.type, self.cwl_obj.parser.InputArraySchema):
                # Is schema?
                input_obj["is_array"] = 1
                # Handle double arrays
                while isinstance(input_item.type, self.cwl_obj.parser.InputArraySchema):
                    input_item.type = input_item.type.items
                    input_obj["is_array"] += 1
                # Schemas
                if '#' in input_item.type.items:
                    # You may say I'm a schema... but I'm not the only one
                    input_obj["cwl_type"] = "schema"
                    # Read schema
                    relative_schema_file_path, schema_name = input_item.type.items.split("#", 1)
                    relative_schema_file_path = Path(relative_schema_file_path)
                    schema_version = re.sub(r"\.yaml$", "", relative_schema_file_path.name.rsplit("__", 1)[-1])
                    # Save schema
                    input_obj["schema_obj"] = CWLSchema(self.cwl_file_path.parent.joinpath(input_item.type.items.split("#")).resolve(),
                                                        schema_name,
                                                        schema_version)
                # Not schemas
                else:
                    # Just a regular array
                    input_obj["cwl_type"] = input_item.type.items
                    # Check for secondary files
                    if hasattr(input_item.type, "secondaryFiles") and input_item.type.secondaryFiles is not None:
                        input_obj["secondary_files"] = input_item.type.secondaryFiles
            # Handle InputEnumSchema objects
            elif isinstance(input_item.type, self.cwl_obj.parser.InputEnumSchema):
                # Assign value to the first symbol
                input_obj["cwl_type"] = "enum"
                input_obj["symbols"] = [symbol.split("#", 1) for symbol in input_item.type.symbols][0]
            elif isinstance(input_item.type, str):
                # The low hanging fruit
                input_obj["cwl_type"] = input_item.type
                # Check for secondary files
                if hasattr(input_item, "secondaryFiles") and input_item.secondaryFiles is not None:
                    input_obj["secondary_files"] = input_item.secondaryFiles
            else:
                logger.warning(f"Don't know what to do with {input_item}, skipping")
                continue

            inputs[input_id] = input_obj

        return inputs

    @staticmethod
    def get_input_name_from_id(input_id):
        """
        From id which should be something like file://path/to/cwl/#id/samplesheets
        return samplesheets
        :return:
        """
        return Path(input_id.split("#")[-1]).name



    @staticmethod
    def get_json_for_input_attribute(input_type: str) -> Dict:
        """
        :return:
        """
        raise NotImplementedError


    @staticmethod
    def get_json_for_schema_input_attribute(schema_dict, optional=False):
        """
        :param schema_dict:
        :param optional:
        :return:
        """
        raise NotImplementedError


    def get_name_as_commented_map(self):


    def get_default_engine_parameters_as_commented_map(self):
        """
        Return engine parameters as a commented map
        So we can add in comments
        """
        # TODO

    def get_cwl_inputs_as_commented_map(self):
        # TODO

    def write_yaml_file(self):
        """
        Generate the yaml dict and write it out to file
        Add in the name, engine-parameters, and
        """

        # Requires the name, input and engine parameters

        # Step 1: Initialise CommentedMap

        # Step 2: Set values for name, input and engineParameters

        # Step 3: Write out yaml file


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

            # Fail on non-zero exit
            shell_h.write(f"# Fail on non-zero exit")
            shell_h.write(f"set -euo pipefail\n\n")

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

            # Check binaries
            # Can we enter the right context?
            # Check yq is present,
            # Check ica-context-switcher or ica is present or ICA_ACCESS_TOKEN is set?
            # TODO Set with case statement


            # Run checks with each case statement
            # Then start with the context switch command
            # Work with case statement
            shell_h.write(f"# Enter the right context to launch the workflow\n")
            shell_h.write(f"if ! type ica-context-switcher >/dev/null; then\n")
            shell_h.write(f"    ica-context-switcher --project-name '{self.launch_project_name}' --scope 'admin'\n")
            # TODO - check if ica-access-token is present and check it is the right project context
            shell_h.write(f"else\n")
            shell_h.write(f"    ica projects enter '{self.launch_project_name}'\n")
            if self.is_curl:
                shell_h.write(f"    export ICA_ACCESS_TOKEN=\"$(yq eval '.access-token' ~/.ica/.session.{get_region_from_base_url(get_base_url())}.yaml)\"\n")
            shell_h.write("fi\n\n")

            # Check if 'ica-check-cwl-inputs' is in the path and then run it!
            shell_h.write("if [[ type \"ica-check-cwl-inputs\" ]]; then\n")
            shell_h.write(f"    ica-check-cwl-inputs \\\n")
            shell_h.write(f"      --input-json {self.output_json_path} \\\n")
            shell_h.write(f"      --ica-workflow-id {self.run_obj.ica_workflow_id} \\\n")
            shell_h.write(f"      --ica-workflow-version-name {self.run_obj.ica_workflow_version_name}\n")
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



