#!/usr/bin/env python

"""
A subclass of cwl, this function implements the validate and create for a cwl workflow
Based mostly on the cwl-utils package
"""

from classes.cwl import CWL
from utils.logging import get_logger
from utils.errors import CWLValidationError, CWLPackagingError
from cwl_utils.parser_v1_1 import Workflow, LoadingOptions  # For creation of workflow
from ruamel.yaml.comments import CommentedMap as OrderedDict
import os
from tempfile import NamedTemporaryFile
from pathlib import Path
from utils.yaml import dump_cwl_yaml as dump_yaml, to_multiline_string


logger = get_logger()


class CWLWorkflow(CWL):
    """
    Implement the validate_object and create_object implementations for a workflow
    """

    DEFAULT_REQUIREMENTS = [
        "InlineJavascriptRequirement",
        "ScatterFeatureRequirement",
        "MultipleInputFeatureRequirement",
        "StepInputExpressionRequirement"
    ]

    def __init__(self, name, version, cwl_file_path, create=False, user_obj=None):
        # Call super class
        super().__init__(cwl_file_path, name, version, cwl_type="workflow", create=create, user_obj=user_obj)

    def validate_object(self):
        """
        Validate a cwl workflow

        A cwl workflow expects the following

        1. Each input has a 'label' attribute and a 'doc' attribute
        2. Each output has a 'label' attribute and a 'doc' attribute
        3. Each step has a 'label' attribute and a 'doc' attribute
        3. A namespace tag exists with the person attribute
        4. Compare ids of inputs, outputs and steps and make sure none match
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
        self.check_docs(inputs, issue_count)

        # Check steps
        steps = self.cwl_obj.steps
        # Check steps exist
        if steps is None:
            issue_count += 1
            logger.error(
                f"Issue {issue_count}: Could not read outputs section for cwl workflow \"{self.cwl_file_path}\"")
            validation_passing = False
        # Check docs for steps
        self.check_docs(steps, issue_count)

        # Check outputs
        outputs = self.cwl_obj.outputs
        # Check outputs exist
        if outputs is None:
            issue_count += 1
            logger.error(f"Issue {issue_count}: Could not read outputs section for cwl workflow \"{self.cwl_file_path}\"")
            validation_passing = False
        # Check docs for outputs
        self.check_docs(outputs, issue_count)

        # Check that no 'ids' of inputs and outputs match
        input_ids = [_input.id
                     for _input in inputs
                     ]
        output_ids = [_output.id
                      for _output in outputs
                      ]
        step_ids = [_step.id
                    for _step in steps]

        # Intersection of ids
        intersection_input_output_steps = list(set(input_ids).intersection(set(output_ids)).intersection(set(step_ids)))

        # This will cause a fail when we pack the file
        if not len(intersection_input_output_steps) == 0:
            logger.error("The following cwl attributes are found in both the 'inputs' and 'outputs' section.\n"
                         "This will cause an issue for a packed cwl file:\n"
                         "{intersecting_ids}".format(
                             intersecting_ids=", ".join(["'%s'" % _id for _id in intersection_input_output_steps])
                         ))
            issue_count += 1

        # Run cwltool --validate
        self.run_cwltool_validate(self.cwl_file_path)

        # Pack workflow
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
        if '$graph' not in self.cwl_packed_obj.keys():
            logger.error(f"Could not find the top-level key \"$graphr\" in the packed version of the "
                         f"cwl file \"{self.cwl_file_path}\". "
                         f"Please ensure you have no 'inline' steps and all steps point to a file")
            raise CWLValidationError

        # Check authorship in workflow - we assume that workflow is the last item in the graph
        if 'https://schema.org/author' not in self.cwl_packed_obj['$graph'][-1].keys():
            logger.error(f"Could not find attribute \"https://schema.org/author\" in the packed version of the "
                         f"cwl file \"{self.cwl_file_path}\". "
                         f"Please ensure you have set the authorship in the workflow.")
        else:
            self.validate_authorship_attr(self.cwl_packed_obj['$graph'][-1]['https://schema.org/author'])

        if not validation_passing:
            logger.error(f"There were a total of {issue_count} issues.")
            raise CWLValidationError

    def create_object(self, user_obj):
        """
        Create the CWL Workflow object
        :param user_obj:
        :return:
        """

        # Create the cwl workflow object
        author_class = self.get_author_extension_field(user_obj)

        self.cwl_obj = Workflow(
            id=f"{self.name}--{self.version}",
            label=f"{self.name} v({self.version})",
            doc=to_multiline_string(f"Documentation for {self.name} v{self.version}\n"),
            inputs=[],
            steps=[],
            outputs=[],
            cwlVersion="v1.1",
            extension_fields={
                "https://schema.org/author": [
                    author_class
                ]
            },
            loadingOptions=LoadingOptions(
                schemas=["https://schema.org/version/latest/schemaorg-current-http.rdf"],
                namespaces={
                    "s": "https://schema.org/"
                }
            )
        )

    def write_object(self, user_obj):
        """
        Write the workflow to the cwl workflow file path
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
            "doc": self.cwl_obj.doc,
            "requirements": {key: {} for key in self.DEFAULT_REQUIREMENTS},
            "inputs": self.cwl_obj.inputs,
            "steps": self.cwl_obj.steps,
            "outputs": self.cwl_obj.outputs
        })

        with open(self.cwl_file_path, 'w') as cwl_h:
            dump_yaml(write_obj, cwl_h)

