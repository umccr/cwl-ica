#!/usr/bin/env python

"""
Handy functions for working with projects
"""

from classes.project import Project
from classes.project_production import ProductionProject
from classes.ica_workflow import ICAWorkflow
from classes.ica_workflow_version import ICAWorkflowVersion
from utils.repo import read_yaml, get_project_yaml_path
from utils.ica_utils import get_base_url, get_projects_list_with_token
from typing import List
from pathlib import Path

from utils.logging import get_logger
from utils.errors import ProjectNotFoundError

logger = get_logger()


def read_project_yaml() -> List[Project]:
    """
    Read the project yaml file, return a list of projects
    :return:
    """

    # Get project yaml path
    project_yaml_path: Path = get_project_yaml_path()

    # Check project yaml path exists
    if not project_yaml_path.is_file():
        logger.warning("Tried to read project yaml file, but doesn't exist, returning empty list")
        return []

    # Read in projects
    projects_list: List[Project] = [Project.from_dict(project_dict)
                                    if not project_dict.get("production", False)
                                    else ProductionProject.from_dict(project_dict)
                                    for project_dict in read_yaml(get_project_yaml_path())["projects"]]

    return projects_list


def get_project_object_from_project_name(project_name: str) -> Project:
    """
    Get the project object -> this is the project that the workflow belongs to,
    not necessarily the run itself
    """

    projects_list: List[Project] = read_project_yaml()

    for project in projects_list:
        if project.project_name == project_name:
            return project
    else:
        raise ProjectNotFoundError


def get_project_name_from_project_id(project_id: str, project_token: str) -> str:
    """
    Get project name from project id
    :return:
    """
    # Use wes ica to list projects and then find items that match said project
    project_list = get_projects_list_with_token(get_base_url(), project_token)
    for project in project_list:
        if project.id == project_id:
            return project.name
    else:
        raise ProjectNotFoundError
