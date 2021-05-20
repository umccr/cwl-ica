#!/usr/bin/env python3

"""
Again, if you're reading this, I apologise for using the naming convention ItemVersion.
I strive to better myself in future.

Never the less this class is used to handle the version attributes of an element in workflow.yaml, tool.yaml etc.

This class is significantly more important than its owner Item.

Like Item, ItemVersion is only ever invoked through its subclasses ItemVersionTool, ItemVersionWorkflow etc.
"""

from pathlib import Path
from utils.logging import get_logger
from ruamel.yaml.comments import CommentedMap as OrderedDict
from utils.errors import CWLItemNotFound, ItemVersionCreationError

logger = get_logger()


class ItemVersion:
    """
    An ItemVersion has the following properties

    * Name  # This is the version name
    * Path  # This is the version name / "Item Name" __ "Version Name" + ".cwl"  -> .yaml in CWLSchema
    * MD5sum  # This is the md5sum of the packed definition file -> This is compared to those in projects to know
              # If a project should ever be invoked
    * CWL File Path  # This is the full path to the file object.

    We then have the following functions

    * to_dict -> Which allows us to write this version back to the object.

    * get_cwl_object -> Uses the cwl_file_path attribute to read-in / validate the cwl object.
    """

    def __init__(self, name, path, md5sum, cwl_file_path: Path):
        """
        Initialise an ItemVersion object. Check cwl_file_path exists
        :param name:
        :param path:
        :param md5sum:
        :param cwl_file_path:
        """

        self.name = name
        self.path = path
        self.md5sum = md5sum
        self.cwl_file_path = cwl_file_path
        self.cwl_obj = None

        if not cwl_file_path.is_file():
            logger.error(f"Could not find the file \"{cwl_file_path}\"")
            raise CWLItemNotFound

    def __call__(self):
        """
        Sets the cwl object
        :return:
        """
        self.set_cwl_object()

    def to_dict(self):
        """
        Writes the item version object to an ordered dictionary
        :return:
        """

        return OrderedDict({
            "name": self.name,
            "path": str(self.path),
            "md5sum": self.md5sum
        })

    # Methods Implemented in subclass
    def set_cwl_object(self):
        """
        Create a (validated) cwl object -> Implemented in subclass
        :return:
        """
        raise NotImplementedError

    @classmethod
    def from_dict(cls, item_version_dict):
        """
        Returns an item object from a dictionary
        :param item_version_dict:
        :return:
        """

        # Check the item_dict has the appropriate keys
        if item_version_dict.get("name", None) is None:
            logger.error("\"name\" attribute not found, cannot create item version")
            raise ItemVersionCreationError

        if item_version_dict.get("path", None) is None:
            logger.error("\"path\" attribute not found, cannot create item version")
            raise ItemVersionCreationError

        # Return the class item_version_dict
        return cls(name=item_version_dict.get("name"),
                   path=item_version_dict.get("path"),
                   md5sum=item_version_dict.get("md5sum", None),
                   cwl_file_path=item_version_dict.get("cwl_file_path", None))
