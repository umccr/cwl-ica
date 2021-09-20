#!/usr/bin/env python

"""
List all of the category names in the categories.yaml file
"""
from utils.repo import get_user_yaml_path
from utils.miscell import read_yaml

# Import yaml and print each project name
for user in read_yaml(get_user_yaml_path())["users"]:
    print(user["username"])