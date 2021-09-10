#!/usr/bin/env python3

"""
List the registered tool paths
"""

from utils.repo import get_tool_yaml_path
from utils.repo import get_tools_dir
from utils.miscell import read_yaml
from pathlib import Path
from os import getcwd
from os.path import relpath

tool_paths = [Path(tool["path"]) / Path(version["path"])
              for tool in read_yaml(get_tool_yaml_path())["tools"]
              for version in tool["versions"]]

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
# 4. Subfolder of tools dir = "OneDrive/GitHub/UMCCR/tools/contig/" -> current path resolved
if current_word_value is not None:
    if current_word_value.endswith("/"):
        current_path_resolved = Path(getcwd()).joinpath(Path(current_word_value)).resolve()
    else:
        current_path_resolved = Path(getcwd()).joinpath(Path(current_word_value).parent).resolve()

else:
    current_word_value = ""
    current_path_resolved = Path(getcwd()).absolute()

# Is the current_path_resolved a subpath of the tools directory?
try:
    _ = current_path_resolved.relative_to(get_tools_dir())
    in_tools_dir = True
except ValueError:
    in_tools_dir = False

if in_tools_dir:
    current_path_resolved_relative_to_tools_dir = current_path_resolved.relative_to(get_tools_dir())
    if current_path_resolved_relative_to_tools_dir == Path("."):
        for s_path in tool_paths:
            if current_word_value.endswith("/"):
                print(Path(current_word_value) / s_path)
            else:
                print(Path(current_word_value).parent / s_path)
    else:
        for s_path in tool_paths:
            if str(s_path).startswith(str(current_path_resolved_relative_to_tools_dir)):
                if current_word_value.endswith("/"):
                    print(Path(current_word_value) / s_path.relative_to(current_path_resolved_relative_to_tools_dir))
                else:
                    print(Path(current_word_value).parent / s_path.relative_to(
                        current_path_resolved_relative_to_tools_dir))

else:
    # Now get the tools yaml path relative to the current path
    try:
        tools_dir = get_tools_dir().relative_to(current_path_resolved)
    except ValueError:
        # We could be in a different mount point OR just in a subdirectory
        if str(get_tools_dir().absolute()) in str(relpath(get_tools_dir(), current_path_resolved)):
            # Separate mount point
            tools_dir = get_tools_dir().absolute()
        else:
            tools_dir = Path(relpath(get_tools_dir(), current_path_resolved))

    # Now iterate through paths
    for s_path in tool_paths:
        if current_word_value.endswith("/"):
            print(Path(current_word_value) / tools_dir.joinpath(s_path))
        else:
            print(Path(current_word_value).parent / tools_dir.joinpath(s_path))
