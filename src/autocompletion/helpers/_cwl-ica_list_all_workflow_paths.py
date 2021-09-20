#!/usr/bin/env python3

"""
List the unregistered workflow paths
"""

from utils.repo import get_workflow_yaml_path
from utils.repo import get_workflows_dir
from utils.miscell import read_yaml
from pathlib import Path
from os import getcwd
from os.path import relpath

workflow_paths = [s_file.relative_to(get_workflows_dir())
                  for s_file in get_workflows_dir().glob("**/*.cwl")]

# Get the current word value
if not "${CURRENT_WORD}" == "":
    current_word_value = "${CURRENT_WORD}"
else:
    current_word_value = None

# Resolve the current path
# If getcwd() is "/c/Users/awluc"
# 1. Non relative paths: current_word_value = "/etc" -> current_path_resolved = "/etc"
# 2. Relative parent path: current_word_value = "../../Program Files" -> current_path_resolved = "/c/Program Files"
# 3. Subfolder: current_word_value = "OneDrive" -> current_path_resolved = "/c/Users/awluc/OneDrive"
# 4. Subfolder of workflows dir = "OneDrive/GitHub/UMCCR/workflows/contig/" -> current path resolved
if current_word_value is not None:
    if current_word_value.endswith("/"):
        current_path_resolved = Path(getcwd()).joinpath(Path(current_word_value)).resolve()
    else:
        current_path_resolved = Path(getcwd()).joinpath(Path(current_word_value).parent).resolve()

else:
    current_word_value = ""
    current_path_resolved = Path(getcwd()).absolute()

# Is the current_path_resolved a subpath of the workflows directory?
try:
    _ = current_path_resolved.relative_to(get_workflows_dir())
    in_workflows_dir = True
except ValueError:
    in_workflows_dir = False

if in_workflows_dir:
    current_path_resolved_relative_to_workflows_dir = current_path_resolved.relative_to(get_workflows_dir())
    if current_path_resolved_relative_to_workflows_dir == Path("."):
        for s_path in workflow_paths:
            if current_word_value.endswith("/"):
                print(Path(current_word_value) / s_path)
            else:
                print(Path(current_word_value).parent / s_path)
    else:
        for s_path in workflow_paths:
            if str(s_path).startswith(str(current_path_resolved_relative_to_workflows_dir)):
                if current_word_value.endswith("/"):
                    print(
                        Path(current_word_value) / s_path.relative_to(current_path_resolved_relative_to_workflows_dir))
                else:
                    print(Path(current_word_value).parent / s_path.relative_to(
                        current_path_resolved_relative_to_workflows_dir))

else:
    # Now get the workflows yaml path relative to the current path
    try:
        workflows_dir = get_workflows_dir().relative_to(current_path_resolved)
    except ValueError:
        # We could be in a different mount point OR just in a subdirectory
        if str(get_workflows_dir().absolute()) in str(relpath(get_workflows_dir(), current_path_resolved)):
            # Separate mount point
            workflows_dir = get_workflows_dir().absolute()
        else:
            workflows_dir = Path(relpath(get_workflows_dir(), current_path_resolved))

    # Now iterate through paths
    for s_path in workflow_paths:
        if current_word_value.endswith("/"):
            print(Path(current_word_value) / workflows_dir.joinpath(s_path))
        else:
            print(Path(current_word_value).parent / workflows_dir.joinpath(s_path))
