#!/usr/bin/env python3

"""
Again, if you're reading this, I apologise for using the naming convention ItemVersion.
I strive to better myself in future.

Never the less this class is used to handle the version attributes of an element in workflow.yaml, expression.yaml etc.

This class is significantly more important than its owner Item.

Like Item, ItemVersion is only ever invoked through its subclasses ItemVersionExpression, ItemVersionWorkflow etc.
"""

from pathlib import Path
from utils.logging import get_logger
from classes.item_version import ItemVersion
from classes.cwl_expression import CWLExpression
from utils.miscell import get_name_version_tuple_from_cwl_file_path
from utils.repo import get_expressions_dir

logger = get_logger()


class ItemVersionExpression(ItemVersion):
    """
    An ItemVersionExpression has the following properties

    * Name  # This is the version name
    * Path  # This is the version name / "Item Name" __ "Version Name" + ".cwl"  -> .yaml in CWLSchema
    * MD5sum  # This is the md5sum of the packed definition file -> This is compared to those in projects to know
              # If a project should ever be invoked
    * CWL File Path  # This is the full path to the file object.

    We then have the following functions

    * to_dict -> Which allows us to write this version back to the object.

    * get_cwl_object -> Uses the cwl_file_path attribute to read-in / validate the cwl object.

    * set_md5sum -> sets the md5sum attribute
    """

    def __init__(self, name, path, md5sum, cwl_file_path: Path):
        """
        Initialise an ItemVersion object. Check cwl_file_path exists
        :param name:
        :param path:
        :param md5sum:
        :param cwl_file_path:
        """
        # Call super class init
        super().__init__(name, path, md5sum, cwl_file_path)

    # Methods Implemented in subclass
    def set_cwl_object(self):
        """
        Create a (validated) cwl object -> Implemented in subclass
        This also validates the object so we have the md5sum of the packed file

        :return:
        """

        # Split file name
        name, version = get_name_version_tuple_from_cwl_file_path(self.cwl_file_path, items_dir=get_expressions_dir())

        # Set here
        self.cwl_obj = CWLExpression(cwl_file_path=self.cwl_file_path, name=name, version=version)

        # Validate the cwl object
        self.cwl_obj.validate_object()

        # Set the md5sum
        self.md5sum = self.cwl_obj.md5sum
