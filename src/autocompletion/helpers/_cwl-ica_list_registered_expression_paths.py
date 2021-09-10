#!/usr/bin/env python3

"""
List the registered expression paths
"""

from utils.repo import get_expression_yaml_path
from utils.repo import get_expressions_dir
from utils.miscell import read_yaml
from pathlib import Path
from os import getcwd
from os.path import relpath

expression_paths = [Path(expression["path"]) / Path(version["path"])
                    for expression in read_yaml(get_expression_yaml_path())["expressions"]
                    for version in expression["versions"]]

# Get the current word value
if not "${CURRENT_WORD}" == "":
    current_word_value="${CURRENT_WORD}"
else:
    current_word_value=None

# Resolve the current path
# If getcwd() is "/c/Users/awluc"
# 1. Non relative paths: current_word_value = "/etc" -> current_path_resolved = "/etc"
# 2. Relative parent path: current_word_value = "../../Program Files" -> current_path_resolved = "/c/Program Files"
# 3. Subfolder: current_word_value = "OneDrive" -> current_path_resolved = "/c/Users/awluc/OneDrive"
# 4. Subfolder of expressions dir = "OneDrive/GitHub/UMCCR/expressions/contig/" -> current path resolved
if current_word_value is not None:
    if current_word_value.endswith("/"):
        current_path_resolved = Path(getcwd()).joinpath(Path(current_word_value)).resolve()
    else:
        current_path_resolved = Path(getcwd()).joinpath(Path(current_word_value).parent).resolve()

else:
    current_word_value = ""
    current_path_resolved = Path(getcwd()).absolute()

# Is the current_path_resolved a subpath of the expressions directory?
try:
    _ = current_path_resolved.relative_to(get_expressions_dir())
    in_expressions_dir = True
except ValueError:
    in_expressions_dir = False

if in_expressions_dir:
    current_path_resolved_relative_to_expressions_dir = current_path_resolved.relative_to(get_expressions_dir())
    if current_path_resolved_relative_to_expressions_dir == Path("."):
        for s_path in expression_paths:
            if current_word_value.endswith("/"):
                print(Path(current_word_value) / s_path)
            else:
                print(Path(current_word_value).parent / s_path)
    else:
        for s_path in expression_paths:
            if str(s_path).startswith(str(current_path_resolved_relative_to_expressions_dir)):
                if current_word_value.endswith("/"):
                    print(Path(current_word_value) / s_path.relative_to(current_path_resolved_relative_to_expressions_dir))
                else:
                    print(Path(current_word_value).parent / s_path.relative_to(current_path_resolved_relative_to_expressions_dir))

else:
    # Now get the expressions yaml path relative to the current path
    try:
        expressions_dir = get_expressions_dir().relative_to(current_path_resolved)
    except ValueError:
        # We could be in a different mount point OR just in a subdirectory
        if str(get_expressions_dir().absolute()) in str(relpath(get_expressions_dir(), current_path_resolved)):
            # Separate mount point
            expressions_dir = get_expressions_dir().absolute()
        else:
            expressions_dir = Path(relpath(get_expressions_dir(), current_path_resolved))

    # Now iterate through paths
    for s_path in expression_paths:
        if current_word_value.endswith("/"):
            print(Path(current_word_value) / expressions_dir.joinpath(s_path))
        else:
            print(Path(current_word_value).parent / expressions_dir.joinpath(s_path))