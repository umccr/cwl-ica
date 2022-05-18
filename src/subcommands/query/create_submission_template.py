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
import os

from classes.command import Command
from utils.logging import get_logger
from utils.errors import ItemVersionNotFoundError, ItemNotFoundError
from utils.ica_utils import get_base_url, get_region_from_base_url
from utils.input_template_utils import create_input_dict
from ruamel.yaml.comments import \
    CommentedMap as OrderedDict, \
    CommentedSeq as OrderedList
from ruamel.yaml import YAML
from ruamel.yaml.main import round_trip_dump
from pathlib import Path
from typing import Optional, List
from classes.project import Project
from utils.errors import CheckArgumentError, InvalidTokenError
from classes.cwl import CWL
from classes.cwl_schema import CWLSchema
from utils.project import get_project_object_from_project_name
from typing import Dict
import re
from utils.miscell import get_name_version_tuple_from_cwl_file_path
from classes.ica_workflow import ICAWorkflow
from classes.item import Item
from classes.item_version import ItemVersion
from utils.repo import read_yaml
from utils.globals import BLOCK_YAML_INDENTATION_LEVEL, YAML_INDENTATION_LEVEL
import in_place
from copy import deepcopy

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

    def __init__(self, command_argv, item_dir=None, item_type=None, item_type_key=None, item_yaml_path=None):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise values
        self.item_dir = item_dir  # type: Optional[Path]
        self.item_type = item_type  # type: Optional[str]
        self.item_type_key = item_type_key  # type: Optional[str]
        self.item_yaml_path = item_yaml_path  # type: Optional[Path]
        self.item_name = None  # type: Optional[str]
        self.item_version = None  # type: Optional[str]
        self.cwl_file_path = None  # type: Optional[Path]
        # self.output_json_path = None  # type: Optional[Path]
        self.output_yaml_path = None  # type: Optional[Path]
        self.output_shell_path = None  # type: Optional[Path]
        self.launch_name = None  # type: Optional[str]
        self.project_obj = None  # type: Optional[Project]
        self.cwl_obj = None  # type: Optional[CWL]
        self.input_template_object = None  # type: Optional[OrderedDict]
        self.launch_project_name = None  # type: Optional[str]
        self.is_curl = None  # type: Optional[bool]
        self.cwl_inputs = None  # type: Optional[Dict]
        self.ica_workflow_id = None  # type: Optional[str]
        self.ica_workflow_version_name = None  # type: Optional[str]
        self.ica_workflow_run_id = None  # type: Optional[str]
        self.ignore_workflow_id_mismatch = False  # type: bool

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

        if self.ica_workflow_run_id is not None:
            logger.info(f"Decorating input yaml file with inputs from {self.ica_workflow_run_id}")
            self.decorate_yaml_file()

        logger.info(f"Writing wrapper script to {self.output_shell_path}")
        self.write_shell_script()

    def get_item_arg(self) -> Path:
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
        item_path_arg: Path = self.get_item_arg()

        if not item_path_arg.is_file():
            logger.error(f"Could not find {item_path_arg}")
            raise FileNotFoundError

        # Check dir
        output_prefix_arg = Path(self.args.get("--prefix"))

        if not output_prefix_arg.absolute().resolve().parent.is_dir():
            logger.error(f"Please create the parent directory of {output_prefix_arg}")

        # Get name and version from item path
        self.cwl_file_path = item_path_arg
        self.item_name, self.item_version = get_name_version_tuple_from_cwl_file_path(cwl_file_path=self.cwl_file_path,
                                                                                      items_dir=self.item_dir)

        # Get the project object
        project_name = self.args.get("--project")
        if project_name is None:
            logger.error("--project must be defined")
            raise CheckArgumentError
        self.project_obj = get_project_object_from_project_name(project_name)

        # Get ica workflow id and ica workflow version name
        ica_workflow_list: List[ICAWorkflow] = self.project_obj.get_items_by_item_type(self.item_type)

        for ica_workflow in ica_workflow_list:
            # Get right workflow object
            if not ica_workflow.name == self.item_name:
                continue
            # Assign workflow id
            self.ica_workflow_id = ica_workflow.ica_workflow_id
            # Get version name
            for ica_workflow_version in reversed(ica_workflow.versions):  # Reversed for production projects
                if not ica_workflow_version.name == self.item_version:
                    continue
                # Assign workflow version name
                self.ica_workflow_version_name = ica_workflow_version.ica_workflow_version_name
                break
            else:
                logger.error(f"Could not get workflow version to match {self.item_name}/{self.item_version}")
                raise ItemVersionNotFoundError
            break
        else:
            logger.error(f"Could not get workflow id to match {self.item_name}/{self.item_version}")
            raise ItemNotFoundError

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

        # Check if instance exists
        if self.args.get("--ica-workflow-run-instance-id", None) is not None:
            self.ica_workflow_run_id = self.args.get("--ica-workflow-run-instance-id")

        # Check ignore workflow id mismatch
        if self.args.get("--ignore-workflow-id-mismatch", False):
            self.ignore_workflow_id_mismatch = True

        # Load cwl
        items: List[Dict] = self.get_item_list()

        # Iterate through item list
        for item_ in items:
            if not item_.get('name') == self.item_name:
                continue
            version: Dict
            for version in item_.get('versions'):
                if not version.get("name") == self.item_version:
                    continue
                version_object = self.version_loader(version, self.cwl_file_path)
                version_object.set_cwl_object()
                self.cwl_obj = version_object.cwl_obj
                break
            else:
                logger.error(f"Could not find {self.item_version} in {self.item_name}")
                raise ItemVersionNotFoundError
            break
        else:
            logger.error(f"Could not find {self.item_name}/{self.item_version} in {self.item_type}.yaml")
            raise ItemNotFoundError

        # Get inputs from object
        self.cwl_inputs = self.get_cwl_inputs_from_object()

        # Initialise yaml template
        self.input_template_object = YAML().map()

    def get_project_access_token(self):
        """
        Get the project access token
        if --launch-project is specified, get project token from env var or --access-token parameter
        otherwise just get from the project object
        :return:
        """
        if self.args.get("--launch-project", None) is not None:
            if self.args.get("--access-token", None) is not None:
                return self.args.get("--access-token")
            elif os.environ.get("ICA_ACCESS_TOKEN", None) is not None:
                return os.environ.get("ICA_ACCESS_TOKEN")
            else:
                logger.error("--launch-project specified and --ica-workflow-run-instance-id specified, "
                             " please enter launch project context with ica-context-switcher or supply access-token for context with --access-token")
                raise InvalidTokenError
        else:
            return self.project_obj.get_project_token()

    def version_loader(self, version: Dict, cwl_file_path: Path) -> ItemVersion:
        raise NotImplementedError

    def get_item_list(self):
        """
        Load the yaml file
        :return:
        """
        return read_yaml(self.item_yaml_path)[self.item_type_key]

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
            input_item_type = input_item.type

            # Check if we need to go through a second time
            was_in_optional_list = False
            # Check if we get an array (this likely means first option is null)
            if isinstance(input_item_type, list):
                was_in_optional_list = True
                # Check elements are in array
                if len(input_item_type) < 1:
                    logger.warning("Input item has no length, skipping")
                    continue
                # Check if first option is null (means an optional item)
                elif input_item_type[0] == 'null':
                    # Pop null item
                    _ = input_item_type.pop(0)
                    input_obj["optional"] = True

                if len(input_item_type) == 0:
                    logger.warning("Input item has no length, skipping")
                    continue
                elif len(input_item_type) == 1:
                    input_item_type = input_item_type[0]
                    input_obj["cwl_type"] = input_item_type
                elif all([isinstance(_item, str) for _item in input_item_type]):
                    input_obj["cwl_type"] = [_item for _item in input_item_type]
                else:
                    logger.warning("Can't handle multiple types that aren't simple")
                    continue

            # Handle InputArraySchema objects (and double arrays)
            while isinstance(input_item_type, self.cwl_obj.parser.InputArraySchema):
                if not "is_array" in input_obj.keys():
                    input_obj["is_array"] = 1
                else:
                    input_obj["is_array"] += 1
                input_item_type = input_item_type.items

            # Schemas
            if isinstance(input_item_type, str) and "#" in input_item_type:
                # You may say I'm a schema... but I'm not the only one
                input_obj["cwl_type"] = "schema"
                # Read schema
                relative_schema_file_path, schema_name = input_item_type.split("#", 1)
                relative_schema_file_path = Path(relative_schema_file_path)
                schema_version = re.sub(r"\.yaml$", "", relative_schema_file_path.name.rsplit("__", 1)[-1])
                # Save schema
                input_obj["schema_obj"] = CWLSchema(self.cwl_file_path.parent.joinpath(relative_schema_file_path).resolve(),
                                                    schema_name,
                                                    schema_version).cwl_obj
            # Handle InputEnumSchema objects
            elif isinstance(input_item_type, self.cwl_obj.parser.InputEnumSchema):
                # Assign value to the first symbol
                input_obj["cwl_type"] = "enum"
                input_obj["symbols"] = [symbol.split("#", 1)[-1] for symbol in input_item_type.symbols]
            elif isinstance(input_item_type, str):
                # The low hanging fruit
                input_obj["cwl_type"] = input_item_type
                # Check for secondary files
                if hasattr(input_item, "secondaryFiles") and input_item.secondaryFiles is not None:
                    input_obj["secondary_files"] = input_item.secondaryFiles
            elif isinstance(input_item_type, list):
                # Handled in check for multiple types
                continue
            else:
                logger.warning(f"Don't know what to do with {input_item} of type {input_item_type}, skipping")
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

    def set_name_as_commented_map(self):
        """
        Use the launch name attribute, with the following comments
        # Workflow Run Name
        name:
        :return:
        """

        # Get the name object as a commented map
        self.input_template_object["name"] = self.launch_name

        # Add the comment above the name input - indent is zero since we're at the top key
        self.input_template_object.yaml_set_comment_before_after_key(key="name",
                                                                     before="Name of the workflow run",
                                                                     indent=0)
    def set_default_engine_parameters_as_commented_map(self):
        """
        Return engine parameters as a commented map
        So we can add in comments
        """
        self.input_template_object["engineParameters"]: OrderedDict = OrderedDict({
            "workDirectory": None,
            "outputDirectory": None
        })

        # Add keys to each
        self.input_template_object.get("engineParameters").yaml_set_comment_before_after_key(key="workDirectory",
                                                                                             before="Set the gds path to the logs and intermediate files",
                                                                                             indent=YAML_INDENTATION_LEVEL)
        self.input_template_object.get("engineParameters").yaml_set_comment_before_after_key(key="outputDirectory",
                                                                                             before="Set the gds path to the workflow outputs",
                                                                                             indent=YAML_INDENTATION_LEVEL)

        # Add eol comment
        self.input_template_object.get("engineParameters").yaml_add_eol_comment(key="workDirectory",
                                                                                comment="gds://path/to/work/dir/")
        self.input_template_object.get("engineParameters").yaml_add_eol_comment(key="outputDirectory",
                                                                                comment="gds://path/to/output/dir/")

        self.input_template_object.yaml_set_comment_before_after_key(key="engineParameters",
                                                                     before=f"\nICA Engine Parameters",
                                                                     indent=0)

    def set_cwl_inputs_as_commented_map(self):
        """
        Get cwl inputs as a commented map
        Uses the input template utils functions
        :return:
        """
        self.input_template_object["input"] = create_input_dict(self.cwl_inputs)
        self.input_template_object.yaml_set_comment_before_after_key(key="input",
                                                                     before=f"\nInputs to {self.item_type} {self.item_name}/{self.item_version}",
                                                                     indent=0)

    def write_yaml_file(self):
        """
        Generate the yaml dict and write it out to file
        Add in the name, engine-parameters, and
        """

        # Step 1: Populate the yaml file with name, input and engine parameters
        self.set_name_as_commented_map()
        self.set_cwl_inputs_as_commented_map()
        self.set_default_engine_parameters_as_commented_map()

        # Step 2: Write out yaml file
        with open(self.output_yaml_path, 'w') as yaml_h:
            round_trip_dump(self.input_template_object, yaml_h,
                            indent=YAML_INDENTATION_LEVEL,
                            block_seq_indent=BLOCK_YAML_INDENTATION_LEVEL)

    def decorate_yaml_file(self):
        """
        If --ica-workflow-run-instance-id has been set, then update inputs to match
        :return:
        """
        from classes.ica_workflow_run import ICAWorkflowRun
        import collections.abc

        def recursive_update(d, u):
            for k, v in u.items():
                if isinstance(v, collections.abc.Mapping):
                    d[k] = recursive_update(d.get(k, {}), v)
                else:
                    d[k] = v
            return d

        # Step 1: Read in the yaml file we just wrote out with read_yaml
        yaml_obj = read_yaml(self.output_yaml_path)

        # Get inputs from workflow run instance id
        ica_workflow_run_obj = ICAWorkflowRun(self.ica_workflow_run_id,
                                              project_token=self.get_project_access_token(),
                                              allow_unsuccessful_run=True,
                                              get_task_run_objects=False)

        # Cross reference
        if not self.ica_workflow_id == ica_workflow_run_obj.ica_workflow_id and not self.ignore_workflow_id_mismatch:
            logger.error(f"Cannot use {self.ica_workflow_run_id} as a reference. ICA workflow ids do not match")
            logger.error(f"Apples: {self.ica_workflow_id} vs Oranges: {ica_workflow_run_obj.ica_workflow_id}")
            raise ValueError
        if not self.ica_workflow_version_name == ica_workflow_run_obj.ica_workflow_version_name and not self.ignore_workflow_id_mismatch:
            logger.warning(f"Got version name {self.ica_workflow_version_name}, "
                           f"but workflow run id is from version {ica_workflow_run_obj.ica_workflow_version_name}")

        # Get distinction between inputs set and inputs not set in workflow run id
        inputs_present_in_workflow_run = []

        # Check that the ica run instance id is
        missing_keys = list(set(list(ica_workflow_run_obj.ica_input.keys())) - set(list(yaml_obj["input"].keys())))
        if not len(missing_keys) == 0:
            logger.error("Items in instance are not in yaml object")
            logger.error(f"Missing inputs: {', '.join(missing_keys)}")
            raise ValueError

        # Updating items
        for input_name, input_value in deepcopy(ica_workflow_run_obj.ica_input).items():
            # Append to list we 'don't comment out'
            inputs_present_in_workflow_run.append(input_name)

            # Save commentary on item
            if isinstance(yaml_obj["input"][input_name], OrderedDict) and hasattr(yaml_obj["input"][input_name], "ca"):
                # Save input commentary
                input_commentary = deepcopy(yaml_obj["input"][input_name].ca)

                # Update input item by type
                if isinstance(input_value, list):
                    # Update input item
                    yaml_obj["input"][input_name] = OrderedList(input_value)
                else:
                    # Update input item
                    yaml_obj["input"][input_name] = OrderedDict(input_value)

                # Add commentary back in
                setattr(yaml_obj["input"][input_name], "_ca", input_commentary)
            else:
                # Just update item
                # Update input item
                yaml_obj["input"][input_name] = input_value

        # (Re)-Writing out the yaml
        with open(self.output_yaml_path, 'w') as yaml_h:
            round_trip_dump(yaml_obj, yaml_h,
                            indent=YAML_INDENTATION_LEVEL,
                            block_seq_indent=BLOCK_YAML_INDENTATION_LEVEL)

        # Now for the tricky bit - using 'FileInput' to remove everything else
        # We know that the indentation on 'input' is YAML_INDENTATION_LEVEL,
        # And that we can find the next input with 'spaces*YAML_INDENTATION_LEVEL + "# //...
        # Therefore we can regex match on 'spaces*YAML_INDENTATION_LEVEL + \w+ + ":"'
        # Ignore all those in inputs_present_in_workflow_run, and then continue to comment out lines until we
        # read the next input
        logger.info(f"Now decorating workflow with inputs from {self.ica_workflow_run_id}")
        with in_place.InPlace(self.output_yaml_path) as file_h:
            in_inputs = False
            comment_out_line = False
            for line in file_h:
                # Check if we're in the inputs section or not
                if line.rstrip() == "input:":
                    in_inputs = True
                    file_h.write(line)
                    continue
                elif re.match(r"\w+:", line.rstrip()) is not None:
                    # Out of inputs
                    in_inputs = False

                # Only pass this point if we're in the inputs
                if not in_inputs:
                    file_h.write(line)
                    continue

                # In inputs
                input_key_regex_obj = re.match(r"\s{%s}(\w+):(\S+)?" % YAML_INDENTATION_LEVEL, line.rstrip())
                if input_key_regex_obj is not None:
                    # We're at a key
                    input_key = input_key_regex_obj.group(1)
                    # Check if key is in list
                    if input_key in inputs_present_in_workflow_run:
                        comment_out_line = False
                    else:
                        #logger.info(f"Commenting out input {input_key}, not present in {self.ica_workflow_run_id}")
                        comment_out_line = True

                # Now comment out line if false or true
                if comment_out_line:
                    file_h.write(re.sub(r"^\s{%s}" % YAML_INDENTATION_LEVEL, " " * YAML_INDENTATION_LEVEL + "# ", line))
                else:
                    file_h.write(re.sub(r"# FIXME$", "", line.rstrip()) + "\n")


    def write_json_file(self):
        raise NotImplementedError
        # """
        # Write the json file containing the run json object as specified in the run yaml
        # :return:
        # """
        #
        # # Get engine parameters pop any unnecessary ones
        # engine_parameters = self.run_obj.ica_engine_parameters.copy()
        # unnecessary_engine_parameters = [
        #     'tesUseInputManifest',
        #     'cwltool',
        #     'engine',
        # ]
        #
        # for parameter in unnecessary_engine_parameters:
        #     if parameter in list(engine_parameters.keys()):
        #         _ = engine_parameters.pop(parameter)
        #
        # run_dict = {
        #     "name": self.launch_name,
        #     "input": self.run_obj.ica_input,
        #     "engineParameters": engine_parameters
        # }
        # with open(self.output_json_path, 'w') as json_h:
        #     json.dump(run_dict, json_h, indent=4)

    def write_shell_script(self):
        """
        Write the script that builds the launch object
        :return:
        """
        launch_binary = 'curl' if self.is_curl else 'ica'

        with open(self.output_shell_path, 'w') as shell_h:
            # Start with the shebang
            shell_h.write("#!/usr/bin/env bash\n\n")

            # Fail on non-zero exit
            shell_h.write(f"# Fail on non-zero exit\n")
            shell_h.write(f"set -euo pipefail\n\n")

            # Add docs
            #shell_h.write(f"# Use this script to launch the input json '{self.output_json_path.name}'\n\n")

            # Check yq is present
            shell_h.write(f"# Check yq and {launch_binary} is in path\n")
            shell_h.write(f"echo 'Checking yq and {launch_binary} are installed' 1>&2\n")
            shell_h.write(f"if ! type yq {launch_binary} >/dev/null 1>&2; then\n")
            shell_h.write(f"    echo \"Error: Please ensure install 'yq' and '{launch_binary}' before continuing\"\n")
            shell_h.write("fi\n\n")


            # Source ica-ica-lazy functions (bash functions might be exported but doesn't help if user
            # is running zsh
            shell_h.write("# Source ica-ica-lazy functions if they exist\n")
            shell_h.write("echo 'Sourcing ica-ica-lazy package if present' 1>&2\n")
            shell_h.write("if [[ -n \"${ICA_ICA_LAZY_HOME}\" ]]; then\n")
            shell_h.write("    for f in \"${ICA_ICA_LAZY_HOME}/functions/\"*\".sh\"; do\n")
            shell_h.write("        .  \"$f\"\n")
            shell_h.write("    done\n")
            shell_h.write("fi\n\n")

            # Check binaries

            # Run checks with each case statement
            # Then start with the context switch command
            # Work with case statement
            shell_h.write(f"# Enter the right context to launch the workflow\n")
            shell_h.write(f"echo 'Entering launch project context' 1>&2\n")
            shell_h.write(f"if type ica-context-switcher >/dev/null 2>&1; then\n")
            shell_h.write(f"    ica-context-switcher --project-name '{self.launch_project_name}' --scope 'admin'\n")
            # TODO - check if ica-access-token is present and check it is the right project context
            shell_h.write(f"else\n")
            shell_h.write(f"    ica projects enter '{self.launch_project_name}'\n")
            if self.is_curl:
                shell_h.write(f"    export ICA_ACCESS_TOKEN=\"$(yq eval '.access-token' ~/.ica/.session.{get_region_from_base_url(get_base_url())}.yaml)\"\n")
            shell_h.write("fi\n\n")

            # Create temp file ready for launch
            shell_h.write("# Convert yaml into json with yq\n")
            shell_h.write(f"echo 'Converting {self.output_yaml_path.absolute().resolve().relative_to(self.output_shell_path.absolute().resolve().parent)} to json' 1>&2\n")
            shell_h.write(f"json_path=$(mktemp {self.output_yaml_path.stem}.XXX.json)\n")
            shell_h.write(f"yq eval --output-format=json '.' {self.output_yaml_path.absolute().resolve().relative_to(self.output_shell_path.absolute().resolve().parent)} > \"$json_path\"\n\n")

            # Check if 'ica-check-cwl-inputs' is in the path and then run it!
            shell_h.write("# Validate workflow inputs against ICA workflow version\n")
            shell_h.write("echo 'Validating workflow inputs against ICA workflow version definition (if ica-ica-lazy is installed)' 1>&2\n")
            shell_h.write("if type \"ica-check-cwl-inputs\" >/dev/null 2>&1; then\n")
            shell_h.write(f"    ica-check-cwl-inputs \\\n")
            shell_h.write(f"      --input-json \"$json_path\" \\\n")
            shell_h.write(f"      --ica-workflow-id \"{self.ica_workflow_id}\" \\\n")
            shell_h.write(f"      --ica-workflow-version-name \"{self.ica_workflow_version_name}\"\n")
            shell_h.write("fi\n\n")

            # Then set the launch command
            if self.is_curl:
                shell_h.write("# Submit command through curl\n")
                shell_h.write("echo 'Launching ica workflow through curl' 1>&2")
                shell_h.write(f"curl \\\n"
                              f"    --request POST \\\n"
                              f"    --url \"{get_base_url()}/v1/workflows/{self.ica_workflow_id}/versions/{self.ica_workflow_version_name}:launch\" \\\n"
                              f"    --header \"Accept: application/json\" \\\n"
                              f"    --header \"Context-Type: application/json\" \\\n"
                              f"    --header \"Authorization: Bearer ${{ICA_ACCESS_TOKEN}}\" \\\n"
                              f"    --data \"@$json_path\"\n")
            else:
                shell_h.write("# Submit command through ica binary\n")
                shell_h.write(f"ica workflows versions launch \"{self.ica_workflow_id}\" \"{self.ica_workflow_version_name}\" \"$json_path\"\n")