#!/usr/bin/env python3

"""
Item is a terrible name. I whole-heartedly acknowledge this and apologise for any future maintainer.

In this context item represents an element under 'workflow' in workflow.yaml, 'tool' in tool.yaml and so on.

An item itself does not contain much information.

Just a name, a path (this will just be the name relative to the tool root anyway) and the categories associated
with any of the subsequent versions of this tool / workflow.

Categories are only relevant for tools and workflows.
"""

from utils.logging import get_logger
from ruamel.yaml.comments import CommentedMap as OrderedDict
from pathlib import Path
from classes.item_version import ItemVersion
from utils.errors import ItemCreationError, ItemDirectoryNotFoundError

logger = get_logger()


class Item:
    """
    Only subclasses are actually used. These comprise ItemTool, ItemWorkflow, ItemExpression...

    Item represents an element under workflow.yaml or tool.yaml etc.
    """

    def __init__(self, name, path, root_dir=None, versions=None, categories=None):
        # Initialise name
        self.name = name
        self.path = path
        self.root_dir = root_dir

        # Get versions (these will be of a type that is a subclass of ItemVersion)
        if versions is None:
            self.versions = []
        # Confirm if versions is a list
        elif len(versions) == 0:
            self.versions = []
        elif isinstance(versions[0], ItemVersion):
            self.versions = versions
        elif isinstance(versions[0], dict):
            self.versions = self.get_versions(versions)
        else:
            # Set default
            self.versions = []

        # Get categories
        self.categories = categories if categories is not None else []

    def check_dir(self):
        """
        Check that the directory exists for this 'item' class
        :param root_dir:
        :return:
        """

        if not self.root_dir / Path(self.name) is not None:
            logger.error(f"Could not get directory \"{self.root_dir}/{self.name}\"")
            raise ItemDirectoryNotFoundError

    def to_dict(self):
        """
        Write an item to a dictionary - redefined in expression and schema class where categories are not defined
        :return:
        """
        return OrderedDict({
            "name": self.name,
            "path": str(self.path),
            "versions": [
                version.to_dict() if isinstance(version, ItemVersion) else version  # Still just a dict
                for version in self.versions
            ],
            "categories": self.categories
        })

    def get_versions(self, versions):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError

    @classmethod
    def from_dict(cls, item_dict):
        """
        Returns an item object from a dictionary
        :param item_dict:
        :return:
        """

        # Check the item_dict has the appropriate keys
        if item_dict.get("name", None) is None:
            logger.error("\"name\" attribute not found, cannot create item")
            raise ItemCreationError

        if item_dict.get("path", None) is None:
            logger.error("\"path\" attribute not found, cannot create item")
            raise ItemCreationError

        # Return the class object
        return cls(name=item_dict.get("name"),
                   path=item_dict.get("path"),
                   versions=item_dict.get("versions", None),
                   categories=item_dict.get("categories", None))
