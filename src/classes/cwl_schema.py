#!/usr/bin/env python

"""
A subclass of cwl, this function implements the validate and create for a cwl object
Based mostly on the cwl-utils package
"""

from classes.cwl import CWL
from utils.logging import get_logger
from utils.errors import CWLSchemaError
from tempfile import NamedTemporaryFile
import os
from pathlib import Path
from collections import OrderedDict
from ruamel import yaml
import json
from cwl_utils.parser_v1_1 import RecordSchema

logger = get_logger()


class CWLSchema(CWL):
    """
    Implement the validate_object and create_object and write_object implementations for a cwltool
    """

    VALID_TYPES = ["record", "enum"]

    def __init__(self, cwl_file_path, name, version, create=False, user_obj=None):
        # Call super class
        super().__init__(cwl_file_path, name, version, cwl_type="schema", create=create, user_obj=user_obj)

    def import_cwl_yaml(self):
        # Read in the cwl file from a yaml
        with open(self.cwl_file_path, "r") as cwl_h:
            yaml_obj = yaml.main.round_trip_load(cwl_h, preserve_quotes=True)

        self.cwl_obj = RecordSchema(yaml_obj).type

    def validate_object(self):
        """
        Validate a cwl schema object

        A cwl schema expects the following

        1. type is of enum or record
        2. name attribute is present
        3. If type is of type record, each field has a label and a doc
        :return:
        """

        # Initialise count
        validation_passing = True
        issue_count = 0

        # Check type attr
        schema_type = self.cwl_obj.get("type", None)
        if schema_type is None:
            logger.error(f"Expected 'type' attribute but not found in \"{self.cwl_file_path}\"")
            raise CWLSchemaError

        # Schema supports two types, records and enums
        if schema_type not in self.VALID_TYPES:
            logger.error("Expected one of \"{valid_types}\" but got \"{obj_type}\"".format(
                valid_types=", ".join(self.VALID_TYPES),
                obj_type=self.cwl_obj.get("type")
            ))
            raise CWLSchemaError

        # Check if 'name' attr present
        if self.cwl_obj.get("name") is None:
            logger.error(f"Expected to retrieve \"name\" attribute for schema in path \"{self.cwl_file_path}\"")
            validation_passing = False

        # Do record based check which just makes sure that for each attribute we have a doc / label
        validation_passing_fields = []
        if schema_type == "record":
            for field_name, field_attrs in self.cwl_obj.get("fields").items():
                validation_passing_fields, issue_count = self.check_docs([field_attrs], issue_count)

        for vpf in validation_passing_fields:
            validation_passing = validation_passing * vpf

        # Write 'type' to named temporary file
        type_tempfile = NamedTemporaryFile(suffix=".schema.packed.json")

        with open(type_tempfile.name, 'w') as type_tempfile_h:
            type_tempfile_h.write(json.dumps(self.cwl_obj))

        # Set md5sum
        self.md5sum = self.get_packed_md5sum(type_tempfile)

        if not validation_passing:
            logger.error(f"Validation failed with {issue_count} issues.")
            raise CWLSchemaError

    def create_object(self, user_obj):
        """
        Create a new cwl schema
        :return:
        """

        self.cwl_obj = RecordSchema(
            type="record",
            fields=[]
        ).type

    # Write the tool to the cwltool file path
    def write_object(self, user_obj):
        """
        Write the tool to the cwltool file path
        :return:
        """

        # Rather than use .save() (which doesn't order everything quite the way we want it to)
        # We create our own dict from the object first, then use the round_trip_dumper

        # Before we commence we have to reorganise a couple of setting

        # Create ordered dictionary ready to be written
        write_obj = OrderedDict({
            "type": self.cwl_obj.type,
            "name": self.cwl_obj.name,
            "fields": self.cwl_obj.fields,
        })

        with open(self.cwl_file_path, 'w') as cwl_h:
            yaml.main.round_trip_dump(write_obj, cwl_h)




