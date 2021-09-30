#!/usr/bin/env python

"""
One great goal of mine is to never have a file called miscell.py
Yet every project of mine has always had one, and probably always will.

A refined goal is to actively reduce the number of functions in this file.
"""

from utils.repo import read_yaml, get_blob_url, get_raw_url
from utils.yaml import dump_yaml
from pathlib import Path
from utils.repo import get_project_yaml_path
from utils.logging import get_logger
from utils.errors import CWLFileNameError
from utils.repo import get_tenant_yaml_path, get_cwl_ica_repo_path
import os
from base64 import b64encode, b64decode
import zlib
from deepdiff import DeepDiff
import json
from typing import Dict

logger = get_logger()


def get_items_dir_from_cwl_file_path(cwl_file_path: Path) -> Path:
    """
    Get the absolute path of the items directory from the cwl file path
    :param cwl_file_path:
    :return:
    """
    return Path(list(cwl_file_path.absolute().relative_to(get_cwl_ica_repo_path()).parents)[-2]).absolute()


def filter_projects_by_item(projects, item_name, item_type_key):
    """
    Filter a list of project objects by an item name and item type
    :param projects - a list of project objects
    :param item_name - the name of an item
    :param item_type_key - the type of item, either tools or workflows
    :return:
    """

    new_project_list = []

    # Yes, this is a little bit of WET typing.
    # Please fix this if you know a better way of collecting a property by a variable name
    for project in projects:
        if item_type_key == "tools":
            for item in project.ica_tools_list:
                if item.name == item_name:
                    new_project_list.append(project)
                break
        else:  # workflows
            for item in project.ica_workflows_list:
                if item.name == item_name:
                    new_project_list.append(project)
                break

    # Return the new project list
    return new_project_list


def filter_projects_by_item_version(projects, item_name, item_version, item_type_key):
    """
    Given an item name, item version name, filter the projects by item version
    :param projects:
    :param item_name
    :param item_version:
    :param item_type_key:
    :return:
    """

    new_project_list = []

    # Yes, this is a little bit of WET typing.
    # Please fix this if you know a better way of collecting a property by a variable name
    for project in projects:
        if item_type_key == "tools":
            for item in project.ica_tools_list:
                if item.name == item_name:
                    for version in item.versions:
                        if version.name == item_version:
                            new_project_list.append(project)
                            break
        else:  # workflows
            for item in project.ica_workflows_list:
                if item.name == item_name:
                    for version in item.versions:
                        if version.name == item_version:
                            new_project_list.append(project)
                            break

    # Return the new project list
    return new_project_list


def set_projects(project_list):
    """
    :param: A list of projects
    :return:
    """

    # Required imports for this function
    from classes.project_production import ProductionProject
    from classes.project import Project

    all_projects_list = read_yaml(get_project_yaml_path())['projects']
    new_project_list = []

    for project_name_l in project_list:
        for project_dict in all_projects_list:
            project_name_d = project_dict.get("project_name", None)
            if project_name_d == project_name_l:
                if project_dict.get("production", False):
                    new_project_list.append(ProductionProject.from_dict(project_dict))
                else:
                    new_project_list.append(Project.from_dict(project_dict))
                break
        else:
            # We didn't find a match for this project in the projects list
            logger.warning(f"Could not find \"{project_name_l}\" in project.yaml. Skipping project")

    return new_project_list


def set_tenants_list(tenants_arg):
    """
    Gets tenants argument from --tenants
    :return:
    """
    # Pull in tenants list
    all_tenants_list = read_yaml(get_tenant_yaml_path())['tenants']
    new_tenants_list = []

    # Check if tenants list is defined
    if tenants_arg is None:
        default_tenant_env = os.environ.get("CWL_ICA_DEFAULT_TENANT", None)
        if default_tenant_env is None:
            new_tenants_list = [tenant_dict.get("tenant_id", None) for tenant_dict in all_tenants_list]
        else:
            new_tenants_list = [tenant_dict.get("tenant_id", None) for tenant_dict in all_tenants_list
                                if tenant_dict.get("tenant_name", None) == default_tenant_env]
    elif tenants_arg == "all":
        new_tenants_list = [tenant_dict.get("tenant_id", None) for tenant_dict in all_tenants_list]
    else:
        new_tenants_list = [tenant_dict.get("tenant_id", None) for tenant_dict in all_tenants_list
                            if tenant_dict.get("tenant_name", None) in ','.split(tenants_arg)]

    return new_tenants_list


def set_projects_list(projects_arg, tenants_list):
    """
    Sets the projects list from the --projects attribute
    :return:
    """
    # Read project yaml
    all_projects_list = read_yaml(get_project_yaml_path())["projects"]
    new_projects_list = []

    # Check if projects defined
    # Assign the project_list first
    if projects_arg is None and os.environ.get("CWL_ICA_DEFAULT_PROJECT", None) is None:
        pass
    elif projects_arg == "all":
        # Iterate through all projects
        for project_dict in all_projects_list:
            # Check tenants
            if project_dict.get("tenant_id", None) not in tenants_list:
                continue
            new_projects_list.append(project_dict.get("project_name"))
    else:
        # Split project by comma separated values
        new_projects_list = projects_arg.split(",")

    return new_projects_list


def write_projects_yaml(projects):
    """
    Re-write projects dictionary
    :return:
    """

    all_projects_list = read_yaml(get_project_yaml_path())['projects']
    new_all_projects_list = all_projects_list.copy()

    for i, project_dict in enumerate(all_projects_list):
        if project_dict.get("project_name") not in [project.project_name for project in projects]:
            continue
        for j, project_obj in enumerate(projects):
            if not project_dict.get("project_name") == project_obj.project_name:
                continue
            # Update the project object with the new project dict
            new_all_projects_list[i] = project_obj.to_dict()

    with open(get_project_yaml_path(), "w") as project_h:
        dump_yaml({"projects": new_all_projects_list}, project_h)


def write_item_yaml(items, item_type_key, item_yaml):
    """
    Mostly static method
    :return:
    """

    # Check if we have any tools registered
    if not Path(item_yaml).is_file():
        all_items_list = []
    else:
        all_items_list = read_yaml(item_yaml)[item_type_key]

    new_all_items_list = [item.copy() for item in all_items_list]

    for item_obj in items:
        for i, item_dict in enumerate(all_items_list):
            if item_dict.get("name") == item_obj.name:
                new_all_items_list[i] = item_obj.to_dict()
                break
        else:
            new_all_items_list.append(item_obj.to_dict())

    with open(item_yaml, "w") as item_yaml_h:
        dump_yaml({item_type_key: new_all_items_list}, item_yaml_h)


def get_name_version_tuple_from_cwl_file_path(cwl_file_path, items_dir):
    """
    We confirm that the cwl_file_path is in a subfolder of the item_dir
    :param cwl_file_path: Path to the cwl file
    :param items_dir: Either tools/ workflowls/ etc
    :return:
    """

    name_version_path = Path(cwl_file_path).absolute().relative_to(items_dir)

    name_version_file_split = name_version_path.name.split("__", 1)

    if len(name_version_file_split) < 2:
        logger.error(f"Could not split name and version from {name_version_path.name}. "
                     f"Please name under {items_dir} as "
                     f"<name>/<version>/<name>__<version>.cwl.")
        raise CWLFileNameError

    name_file = name_version_file_split[0]
    version_file = name_version_file_split[1]
    version_file = Path(version_file).resolve().stem

    name_dir = name_version_path.parent.parent.name
    version_dir = name_version_path.parent.name

    if not name_file == name_dir:
        logger.error(f"CWL file has incorrect naming convention, please name under {items_dir} as"
                     f"<name>/<version>/<name>__<version>.cwl. "
                     f"But got first <name> as {name_dir} and second <name> as {name_file}")
        raise CWLFileNameError

    if not version_file == version_dir:
        logger.error(f"CWL file has incorrect naming convention, please name under {items_dir} as"
                     f"<name>/<version>/<name>__<version>.cwl.  "
                     f"But got first <version> as {version_dir} and second <version> as {version_file}")
        raise CWLFileNameError

    return name_file, version_file


def encode_compressed_base64(uncompressed_string):
    """
    Compress string then base64 string

    1. Encode to ascii
    2. Convert to bytes for zlib compression
    3. Encode as base64
    4. Decode as ascii

    :param uncompressed_string:
    :return:
    """

    return b64encode(
            zlib.compress(bytes(uncompressed_string.encode('ascii')))
           ).decode('ascii')


def decode_compressed_base64(compressed_string):
    """
    Might thing we do the opposite? Ah no
    1. Decode base64
    2. Decompress
    3. Decode as ascii
    :param compressed_string:
    :return:
    """

    return zlib.decompress(
             b64decode(compressed_string)
           ).decode('ascii')

def get_markdown_file_from_cwl_path(cwl_path: Path) -> Path:
    """
    From the cwl file path, get the path to the markdown file path
    :param cwl_path:
    :return:
    """
    # Get the relative path
    relative_cwl_path = cwl_path.absolute().relative_to(get_cwl_ica_repo_path())

    return get_cwl_ica_repo_path() / ".github/catalogue/docs" / relative_cwl_path.parent / (relative_cwl_path.stem + ".md")


def get_blob_url_to_markdown_file_from_cwl_path(cwl_path: Path) -> str:
    """
    From the step id, get the url to the markdown file
    :param cwl_path:
    :return:
    """
    # Get the relative path to CWL_ICA_REPO_PATH and then prefix with catalogue docs path
    markdown_path = get_markdown_file_from_cwl_path(cwl_path).absolute().relative_to(get_cwl_ica_repo_path())

    return get_blob_url() + "/" + str(markdown_path)


def get_blob_url_from_path(cwl_path: Path) -> str:
    """
    From the cwl path get the cwl url
    :param cwl_path:
    :return:
    """

    relative_cwl_path = cwl_path.absolute().relative_to(get_cwl_ica_repo_path())

    return get_blob_url() + "/" + str(relative_cwl_path)


def get_raw_url_from_path(cwl_path: Path) -> str:
    """
    From the path get the raw url
    :param cwl_path:
    :return:
    """
    relative_cwl_path = cwl_path.absolute().relative_to(get_cwl_ica_repo_path())

    return get_raw_url() + "/" + str(relative_cwl_path)


def get_graph_path_from_cwl_path(cwl_path: Path) -> Path:
    """
    From the cwl path get the path to the svg graph
    :param cwl_path:
    :return:
    """
    # Get the relative path
    relative_cwl_path = cwl_path.absolute().relative_to(get_cwl_ica_repo_path())

    return get_cwl_ica_repo_path() / ".github/catalogue/images" / relative_cwl_path.parent / (relative_cwl_path.stem + ".svg")


def cwl_id_to_path(cwl_id: str) -> Path:
    """
    Returns the bit after '#' and converts to a path object
    :param cwl_id:
    :return:
    """
    return Path(cwl_id.rsplit("#", 1)[-1])


def summarise_differences_of_two_dicts(dict_1: Dict, dict_2: Dict) -> str:
    """
    Summarise the difference of two dicts with deepdiff
    Credit: https://stackoverflow.com/a/50912266/6946787
    :param dict_1:
    :param dict_2:
    :return:
    """

    diff = DeepDiff(dict_1, dict_2)

    return json.dumps(json.loads(diff.to_json()), indent=4)