#!/usr/bin/env python

"""
A subclass of cwl, this function implements the validate and create for a cwl object
Based mostly on the cwl-utils package
"""

from classes.cwl import CWL
from utils.logging import get_logger
from utils.errors import CWLValidationError, CWLPackagingError
from tempfile import NamedTemporaryFile
import os
from pathlib import Path
from cwl_utils.parser_v1_1 import CommandLineTool, LoadingOptions  # For creation of tool
from ruamel.yaml.comments import CommentedMap as OrderedDict
from utils.yaml import dump_cwl_yaml as dump_yaml, to_multiline_string

logger = get_logger()


class CWLTool(CWL):
    """
    Implement the validate_object and create_object and write_object implementations for a cwltool
    """

    EXPECTED_HINTS = ["ResourceRequirement", "DockerRequirement"]

    def __init__(self, cwl_file_path, name, version, create=False, user_obj=None):
        # Call super class
        super().__init__(cwl_file_path, name, version, cwl_type="tool", create=create, user_obj=user_obj)

    def validate_object(self):
        """
        Validate a cwltool

        A cwl tool expects the following

        1. Each input has a 'label' attribute and a 'doc' attribute
        2. Each output has a 'label' attribute and a 'doc' attribute
        3. DockerRequirement and ResourceRequirement are present in the 'hints' and not 'requirements' section
        4. A namespace tag exists with the person attribute
        5. Compare ids of inputs and outputs and make sure none match
        :return:
        """

        # Initialise check
        validation_passing = True
        issue_count = 0

        # Check inputs
        inputs = self.cwl_obj.inputs
        # Check inputs exist
        if inputs is None:
            issue_count += 1
            logger.error(f"Issue {issue_count}: Could not read inputs section for cwl workflow \"{self.cwl_file_path}\"")
            validation_passing = False
        # Check docs for inputs
        input_validation_passing, issue_count = self.check_docs(inputs, issue_count)

        # Check outputs
        outputs = self.cwl_obj.outputs
        # Check outputs exist
        if outputs is None:
            issue_count += 1
            logger.error(f"Issue {issue_count}: Could not read outputs section for cwl workflow \"{self.cwl_file_path}\"")
            validation_passing = False
        # Check docs for outputs
        output_validation_passing, issue_count = self.check_docs(outputs, issue_count)

        # Check that no 'ids' of inputs and outputs match
        input_ids = [_input.id for _input in inputs]
        output_ids = [_output.id for _output in outputs]

        # Intersection of ids
        intersection_input_output = list(set(input_ids).intersection(set(output_ids)))

        # This will cause a fail when we pack the file
        if not len(intersection_input_output) == 0:
            issue_count += 1
            logger.error("Issue {issue_num}: The following cwl attributes are found in "
                         "both the 'inputs' and 'outputs' section.\n"
                         "This will cause an issue for a packed cwl file:\n"
                         "{intersecting_ids}".format(
                             issue_num=issue_count,
                             intersecting_ids=", ".join(["'%s'" % _id for _id in intersection_input_output])
                         ))

        # Check requirements section
        requirements = self.cwl_obj.requirements

        # No stress if there are no requirements for this tool
        if requirements is not None:
            # We make sure that 'ResoureceRequirement' and 'DockerRequirement' are not in the 'requirements' section
            for requirement in requirements:
                if requirement.class_ in self.EXPECTED_HINTS:
                    logger.error(f"Requirement {requirement.class_} should be in 'hints' section instead")
                    issue_count += 1
                    validation_passing = False

        # Get hints
        hints = self.cwl_obj.hints

        # Check hints have been defined
        if hints is None:
            issue_count += 1
            logger.error(f"Issue: {issue_count}. Hints are not defined. "
                         "One must have 'ResourceRequirement' and 'DockerRequirement' in hints section")
            validation_passing = False

        # We make sure that 'ResourceRequirement' and 'DockerRequirement' are in the 'hints' section
        hint_classes = [_hint.get("class", None) for _hint in hints]
        if not len(list(set(hint_classes).intersection(set(self.EXPECTED_HINTS)))) == 2:
            issue_count += 1
            logger.error(f"Issue: {issue_count}. "
                         f"Could not find both 'ResourceRequirement' and 'DockerRequirement' in hints")
            validation_passing = False

        # Run cwltool --validate
        logger.info(f"Running cwltool --validate \"{self.cwl_file_path}\"")
        self.run_cwltool_validate(self.cwl_file_path)

        # Pack tool
        tmp_packed_file = NamedTemporaryFile(prefix=f"{self.cwl_file_path.name}",
                                             suffix="packed.json",
                                             delete=False)

        try:
            # Pack into tmp file
            logger.info("Generating packed file")
            self.run_cwltool_pack(tmp_packed_file)

            # Validate packed file
            logger.info("Running cwltool --validate on packed file")
            self.run_cwltool_validate(Path(tmp_packed_file.name))

            # Get packed file object
            self.cwl_packed_obj = self.read_packed_file(tmp_packed_file)

            # Generate packed md5sum
            logger.info("Collecting md5sum from packed file")
            self.md5sum = self.get_packed_md5sum(tmp_packed_file)
        except (CWLValidationError, CWLPackagingError):
            validation_passing = False
        finally:
            os.remove(tmp_packed_file.name)

        # Expect 'author' in last of keys
        if 'https://schema.org/author' not in self.cwl_packed_obj.keys():
            logger.error("Could not find attribute \"https://schema.org/author\" in the packed version of the cwl file. "
                         "Please ensure you have set the authorship in the tool.")
        else:
            self.validate_authorship_attr(self.cwl_packed_obj['https://schema.org/author'])

        if not validation_passing:
            logger.error(f"There were a total of {issue_count} issues.")
            raise CWLValidationError

    def create_object(self, user_obj):
        """
        Create a new cwl tool
        :return:
        """

        author_class = self.get_author_extension_field(user_obj)

        self.cwl_obj = CommandLineTool(
            id=f"{self.name}--{self.version}",
            label=f"{self.name} v({self.version})",
            doc=to_multiline_string(f"Documentation for {self.name} v{self.version}\n"),
            inputs=[],
            outputs=[],
            cwlVersion="v1.1",
            baseCommand=[],
            arguments=[],
            hints={
                "ResourceRequirement": {
                    "ilmn-tes:resources": {
                        "tier": "standard/economy",
                        "type": "standard/standardHiCpu/standardHiMem/standardHiIo/fpga",
                        "size": "small/medium/large/xlarge/xxlarge"
                    },
                    "coresMin": 2,
                    "ramMin": 4000
                },
                "DockerRequirement": {
                    "dockerPull": "ubuntu:latest"
                }
            },
            extension_fields={
                "https://schema.org/author": [
                    author_class
                ]
            },
            loadingOptions=LoadingOptions(
                schemas=["https://schema.org/version/latest/schemaorg-current-http.rdf"],
                namespaces={
                    "s": "https://schema.org/",
                    "ilmn-tes": "http://platform.illumina.com/rdf/ica/"
                }
            )
        )

    # Write the tool to the cwltool file path
    def write_object(self, user_obj):
        """
        Write the tool to the cwltool file path
        :return:
        """

        # Rather than use .save() (which doesn't order everything quite the way we want it to)
        # We create our own dict from the object first, then use the round_trip_dumper

        # Before we commence we have to reorganise a couple of settings

        # Reorganise hints
        # hints = {
        #             hint.get("class"): hint.copy()
        #             for hint in self.cwl_obj.hints
        #          }
        #
        # for hint_key, hint_obj in hints.items():
        #     # Remove class attribute
        #     del hint_obj["class"]

        # Create ordered dictionary ready to be written
        write_obj = OrderedDict({
            "cwlVersion": self.cwl_obj.cwlVersion,
            "class": self.cwl_obj.class_,
            "$namespaces": self.cwl_obj.loadingOptions.namespaces,
            "$schemas": ["https://schema.org/version/latest/schemaorg-current-http.rdf"],
            "s:author": self.get_author_extension_field(user_obj),
            "id": self.cwl_obj.id,
            "label": self.cwl_obj.label,
            "doc": self.cwl_obj.doc,
            "hints": self.cwl_obj.hints,
            "baseCommand": self.cwl_obj.baseCommand,
            "inputs": self.cwl_obj.inputs,
            "outputs": self.cwl_obj.outputs
        })

        with open(self.cwl_file_path, 'w') as cwl_h:
            dump_yaml(write_obj, cwl_h)
