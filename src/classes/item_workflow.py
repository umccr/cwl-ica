#!/usr/bin/env python3

"""
ItemWorkflow is the subclass of Item.

ItemWorkflow implements the following:
  * name
  * path
  * versions
"""

from classes.item import Item
from utils.repo import get_workflows_dir
from classes.item_version_workflow import ItemVersionWorkflow
from pathlib import Path
from utils.logging import get_logger
from utils.errors import ItemVersionAttributeError

logger = get_logger()


class ItemWorkflow(Item):
    """
    ItemWorkflow represents an element under workflow.yaml etc.
    """

    def __init__(self, name, path, versions=None, categories=None):
        # Initialise super
        super(ItemWorkflow, self).__init__(name, path,
                                       root_dir=get_workflows_dir(),
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
            version["cwl_file_path"] = Path(get_workflows_dir()) / Path(self.path) / Path(version["path"])
            if not version["cwl_file_path"].is_file():
                logger.warning(f"Could not find cwl file {version['cwl_file_path']}. Skipping file")
                continue
            version_objs.append(ItemVersionWorkflow.from_dict(version))
        return version_objs
