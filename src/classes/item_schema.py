#!/usr/bin/env python3

"""
ItemSchema is the subclass of Item.

ItemSchema implements the following:
  * name
  * path
  * versions
"""

from classes.item import Item
from utils.repo import get_schemas_dir
from classes.item_version_schema import ItemVersionSchema
from pathlib import Path
from utils.logging import get_logger
from utils.errors import ItemVersionAttributeError

logger = get_logger()


class ItemSchema(Item):
    """
    ItemSchema represents an element under schema.yaml etc.
    """

    def __init__(self, name, path, versions=None, categories=None):
        # Initialise super
        super(ItemSchema, self).__init__(name, path,
                                       root_dir=get_schemas_dir(),
                                       versions=versions,
                                       categories=categories)

    def get_versions(self, versions):
        """
        Converts versions into dicts
        :param versions:
        :return:
        """
        # Don't want to overwrite dict
        versions = versions.copy()
        # Initialise new version objects
        version_objs = []
        for version in versions.copy():
            if version.get("path", None) is None:
                logger.error("Path attribute not found")
                raise ItemVersionAttributeError
            # Need to add in the cwl file path
            version["cwl_file_path"] = Path(get_schemas_dir()) / Path(self.path) / Path(version["path"])
            version_objs.append(ItemVersionSchema.from_dict(version))
        return version_objs
