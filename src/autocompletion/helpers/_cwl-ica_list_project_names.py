#!/usr/bin/env python

"""
List all of the project names in the project.yaml file
"""
from utils.repo import get_project_yaml_path
from utils.miscell import read_yaml

# Import yaml and print each project name
for project in read_yaml(get_project_yaml_path())["projects"]:
    print(project["project_name"])