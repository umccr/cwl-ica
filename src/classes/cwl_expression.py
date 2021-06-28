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
from cwl_utils.parser_v1_1 import ExpressionTool, LoadingOptions  # For creation of tool
from ruamel.yaml.comments import CommentedMap as OrderedDict
from ruamel import yaml
from utils.yaml import dump_cwl_yaml as dump_yaml, to_multiline_string

logger = get_logger()


class CWLExpression(CWL):
    """
    Implement the validate_object and create_object and write_object implementations for a cwltool
    """

    def __init__(self, cwl_file_path, name, version, create=False, user_obj=None):
        # Call super class
        super().__init__(cwl_file_path, name, version, cwl_type="tool", create=create, user_obj=user_obj)

    def validate_object(self):
        """
        Validate a cwltool

        A cwl expression expects the following

        1. Each input has a 'label' attribute and a 'doc' attribute
        2. Each output has a 'label' attribute and a 'doc' attribute
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

        # Check input ids and output ids are merely a combination of [a-z and _]
        for input_id in input_ids:
            self.check_id_conformance("inputs", input_id)

        # Do same for outputs
        for output_id in output_ids:
            self.check_id_conformance("outputs", output_id)

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

        # Run cwltool --validate
        self.run_cwltool_validate(self.cwl_file_path)

        # Pack tool
        tmp_packed_file = NamedTemporaryFile(prefix=f"{self.cwl_file_path.name}",
                                             suffix="packed.json",
                                             delete=False)

        try:
            # Pack into tmp file
            self.run_cwltool_pack(tmp_packed_file)

            # Validate packed file
            self.run_cwltool_validate(Path(tmp_packed_file.name))

            # Get packed file object
            self.cwl_packed_obj = self.read_packed_file(tmp_packed_file)

            # Generate packed md5sum
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

        self.cwl_obj = ExpressionTool(
            id=f"{self.name}--{self.version}",
            label=f"{self.name} v({self.version})",
            doc=f"Documentation for {self.name} v{self.version}\n",
            inputs=[],
            outputs=[],
            cwlVersion="v1.1",
            expression="$\n{\n/*\nInsert Expression here\n*/\n}\n",
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

        # Create ordered dictionary ready to be written
        write_obj = OrderedDict({
            "cwlVersion": self.cwl_obj.cwlVersion,
            "class": self.cwl_obj.class_,
            "$namespaces": self.cwl_obj.loadingOptions.namespaces,
            "$schemas": ["https://schema.org/version/latest/schemaorg-current-http.rdf"],
            "s:author": self.get_author_extension_field(user_obj),
            "id": self.cwl_obj.id,
            "label": self.cwl_obj.label,
            "doc": to_multiline_string(self.cwl_obj.doc),
            "inputs": self.cwl_obj.inputs,
            "outputs": self.cwl_obj.outputs,
            "expression": self.cwl_obj.expression
        })

        with open(self.cwl_file_path, 'w') as cwl_h:
            dump_yaml(write_obj, cwl_h)




