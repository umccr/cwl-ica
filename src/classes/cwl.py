#!/usr/bin/env python

"""
Most of the cwl commands come in through here

Hierarchy is:

cwl object:
  - cwltool
  - cwlworkflow
  - cwlexpression
  - cwlschema -> alternate model for reading schema object
"""

from pathlib import Path
from ruamel import yaml
from utils.logging import get_logger
from utils.errors import CWLPackagingError, CWLValidationError, CWLImportError, InvalidAuthorshipError
from tempfile import NamedTemporaryFile
import json
from utils.subprocess_handler import run_subprocess_proc
from hashlib import md5
from ruamel.yaml.comments import CommentedMap as OrderedDict


logger = get_logger()


class CWL:
    """
    Used for cwl files
    """

    def __init__(self, cwl_file_path: Path, name, version, cwl_type=None, create=False, user_obj=None):
        """
        All types treated the same except for schema
        :param cwl_type:  Either tool, workflow, expression or schema
        """

        self.cwl_file_path = cwl_file_path
        self.name = name
        self.version = version
        self.cwl_type = cwl_type
        self.cwl_obj = None  # Imported through cwl
        self.cwl_packed_obj = None  # Only created for validate_object and to grab authorship schemas.
        self.md5sum = None  # Packed md5sum
        self.create = create
        self.user_obj = user_obj

        # TODO - validate version -> version should be in x.y.z syntax

        # Check file exists
        if not create and not self.cwl_file_path.is_file():
            logger.error(f"Could not find file {cwl_file_path}")
            raise FileNotFoundError
        elif not create:
            self.import_cwl_yaml()
        # Create object
        else:
            self.create_object(user_obj=user_obj)

        # Check if cwl file exists - if not we create it, don't check just populate with the following
        # * user attributes
        # * ica namespace
        # See https://github.com/common-workflow-language/cwl-utils/commit/53d415cfaf2082a24bad7e5c1ceaabe8ea9a799e
        # Figure out how to also implement name spaces
        # * An empty label, id and doc
        # Make sure cwl_type attribute exists though
        # Can we do this for a record schema object?

    def __call__(self):
        """
        If we're invoking the create method then we just write out the object to the cwl_file_path
        Otherwise we validate the object
        :return:
        """
        if self.create:
            # Create user object
            self.create_object(self.user_obj)
            # Now write out the object to the file path
            self.write_object(self.user_obj)
        else:
            # Just validate the object
            self.validate_object()

    def import_cwl_yaml(self):
        """
        For all cwl files that aren't schema
        :return:
        """
        if self.cwl_type == "schema":
            # Function re-implemented in subclass
            raise NotImplementedError

        # Read in the cwl file from a yaml
        with open(self.cwl_file_path, "r") as cwl_h:
            yaml_obj = yaml.main.round_trip_load(cwl_h, preserve_quotes=True)

        # Now based on the version we import the parser of interest
        # Import parser based on CWL Version
        if yaml_obj['cwlVersion'] == 'v1.0':
            from cwl_utils import parser_v1_0 as parser
        elif yaml_obj['cwlVersion'] == 'v1.1':
            from cwl_utils import parser_v1_1 as parser
        elif yaml_obj['cwlVersion'] == 'v1.2':
            from cwl_utils import parser_v1_2 as parser
        else:
            logger.error("Version error. Did not recognise {} as a CWL version".format(yaml_obj["CWLVersion"]))
            raise CWLImportError

        # Due to https://github.com/common-workflow-language/cwl-utils/issues/74
        # We must first check for SchemaDefRequirement types and add them to the name spaces
        if yaml_obj.get("requirements", None) is None:
            pass
        elif yaml_obj.get("requirements").get("SchemaDefRequirement", None) is None:
            pass
        elif yaml_obj.get("requirements").get("SchemaDefRequirement").get("types", None) is None:
            pass
        else:
            for imports in yaml_obj.get("requirements").get("SchemaDefRequirement").get("types"):
                # Get import key
                if imports.get("$import", None) is None:
                    continue

                # We need the relative import path and the schema path
                schema_relative_imports_path = imports.get("$import")
                schema_import_path = (Path(self.cwl_file_path).parent / Path(schema_relative_imports_path)).resolve()

                # Log this
                logger.info(f"Manually adding in \"{schema_relative_imports_path}\" into namespaces before "
                            f"we import the cwl object")

                # Import schema
                from classes.cwl_schema import CWLSchema
                from utils.repo import get_schemas_dir
                from utils.miscell import get_name_version_tuple_from_cwl_file_path
                schema_name, schema_version = get_name_version_tuple_from_cwl_file_path(schema_import_path,
                                                                                        get_schemas_dir())
                schema_obj = CWLSchema(schema_import_path, name=schema_name, version=schema_version)

                # Get name and type
                schema_name = schema_obj.cwl_obj.get("name")

                # Schema path
                schema_namespace_str = "#".join(map(str, [schema_relative_imports_path, schema_name]))

                # Now add to namespaces
                if yaml_obj.get('$namespaces') is None:
                    yaml_obj['$namespaces'] = OrderedDict({
                        schema_namespace_str: schema_namespace_str
                    })
                else:
                    yaml_obj['$namespaces'][schema_namespace_str] = schema_namespace_str

        # Now import cwl object as a file
        self.cwl_obj = parser.load_document_by_yaml(yaml_obj, self.cwl_file_path.absolute().as_uri())

    def validate_object(self):
        """
        Validate should be a separate function
        For all types that aren't schema we perform the following validations
        Check user attributes are there
        Check for each input, there exists an ID, label and doc
        Check for each output, there exists an ID, label and doc
        Check DockerRequirement and ResourceRequirement are in hints (not requirements)
        Check none of the input ids are the same as the output ids

        If a workflow, we check each step recursively.
        Make sure each step conforms
        Make sure each step is not 'inline' -> force 'run:' to be a string or something

        If this is a schema object, check each field has label and doc and type (go through type attribute)
        Check namespaces and schemas
        If field attribute is a dict, iteratively check
        If subtype is a list, iteratively check through

        :return:
        """
        # Defined in subclass
        raise NotImplementedError

    def create_object(self, user_obj):
        """
        Based on
        https://github.com/common-workflow-language/cwl-utils/blob/main/create_cwl_from_objects.py

        For all requirements we add in the namespace based on the username

        For a CWL workflow we create a bareminimum inputs / outputs and steps with
        the four main requirements for a workflow,
        * InlineJavascriptRequirement
        * ScatterFeatureRequirement
        * MultipleInputFeatureRequirement
        * StepInputExpressionRequirement

        For a tool we put in an id, label and doc and
        Place the DockerRequirement and Resource Requirements in hints and add in the ilmn-tes-resources

        Expressions just need an input, output and expression with InlineJavascript Requirement set,

        For schema we create a namespace with schema assuming username has been set as well.
        :return:
        """

        # Defined in subclass
        raise NotImplementedError

    def write_object(self, user_obj):
        """
        Write out object to cwl_file_path.
        Used in the create invocation of the command
        Each write is different, this is implemented in the subclass
        :param user_obj:
        :return:
        """

        # Defined in subclass
        raise NotImplementedError

    def check_docs(self, cwl_attr_list, issue_count):
        """
        Check labels and docs for inputs, outputs or steps
        :param cwl_attr_list:
        :param issue_count:
        :return:
        """
        validation_passing = True
        # Check inputs
        for cwl_obj in cwl_attr_list:
            # Check label and doc
            if cwl_obj.label is None:
                issue_count += 1
                logger.error(f"Issue {issue_count}: Input \"{cwl_obj.id}\" "
                             f"does not have a 'label' attribute \"{self.cwl_file_path}\"")
                validation_passing = False
            if cwl_obj.doc is None:
                issue_count += 1
                logger.error(f"Issue {issue_count}: Input \"{cwl_obj.id}\" "
                             f"does not have a 'doc' attribute \"{self.cwl_file_path}\"")
                validation_passing = False

        return validation_passing, issue_count

    def run_cwltool_pack(self, packed_file: NamedTemporaryFile):
        """
        Run subprocess command ["cwltool", "--pack", "/path/to/cwl"]
        A packed file should also be tested through cwltool validate
        :return:
        """

        # Pack
        _return_code, _stdout, _stderr = run_subprocess_proc(["cwltool", "--pack", self.cwl_file_path],
                                                             capture_output=True)

        if not _return_code == 0:
            raise CWLPackagingError

        with open(packed_file.name, "w") as cwl_packed_h:
            cwl_packed_h.write(_stdout)

    @staticmethod
    def run_cwltool_validate(cwl_file_path: Path):
        """
        Run subprocess command ["cwltool", "--validate", "/path/to/cwl"]
        :return:
        """

        _return_code, _stdout, _stderr = run_subprocess_proc(["cwltool", "--validate", cwl_file_path],
                                                             capture_output=True)

        # cwltool validation failed
        if not _return_code == 0:
            raise CWLValidationError

    @staticmethod
    def read_packed_file(packed_file: NamedTemporaryFile):
        """
        Read a graph based packed cwl file, query
        :return:
        """

        with open(packed_file.name, 'r') as packed_h:
            cwl_packed_obj = json.load(packed_h)

        return cwl_packed_obj

    @staticmethod
    def get_packed_md5sum(packed_file: NamedTemporaryFile):
        """
        :param packed_file:
        :return:
        """

        with open(packed_file.name, 'rb') as packed_h:
            data = packed_h.read()
            md5sum = md5(data).hexdigest()
        return md5sum

    @staticmethod
    def get_author_extension_field(user_obj):
        """
        Get the author extension field from the user_obj
        :param user_obj:
        :return:
        """

        author_class = {
            "class": "s:Person",
            "s:name": user_obj.get("username"),
            "s:email": user_obj.get("email")
        }

        if user_obj.get("identifier", None) is not None:
            author_class["s:identifier"] = user_obj.get("identifier")

        return author_class

    @staticmethod
    def validate_authorship_attr(authorship_dict):
        """
        Use the packed cwl object attribute to validate the authorship attribute
        :return:
        """

        validated = True

        expected_keys = ['https://schema.org/name',
                         'https://schema.org/email']

        # XYZ
        if len(list(set(list(authorship_dict.keys())).intersection(set(expected_keys)))) < len(expected_keys):
            logger.error("Could not find all of the following attributes in the tool {expected_keys}".format(
                expected_keys=", ".join([key for key in expected_keys])
            ))
            validated = False

        if not validated:
            raise InvalidAuthorshipError
