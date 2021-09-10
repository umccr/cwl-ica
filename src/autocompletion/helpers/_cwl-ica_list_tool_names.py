#!/usr/bin/env python

"""
List all of the category names in the categories.yaml file
"""
from utils.repo import get_tool_yaml_path
from utils.miscell import read_yaml

# Import yaml and print each tool name
for tool in read_yaml(get_tool_yaml_path())["tools"]:
    print(tool["name"])