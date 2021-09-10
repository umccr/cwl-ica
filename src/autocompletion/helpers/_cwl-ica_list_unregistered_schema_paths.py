#!/usr/bin/env python3

"""
List the unregistered schema paths
"""

from utils.repo import get_schema_yaml_path
from utils.repo import get_schemas_dir
from utils.miscell import read_yaml
from pathlib import Path
from os import getcwd
from os.path import relpath

all_paths = [s_file.relative_to(get_schemas_dir())
             for s_file in get_schemas_dir().glob("**/*.yaml")]

registered_schema_paths = [Path(schema["path"]) / Path(version["path"])
                           for schema in read_yaml(get_schema_yaml_path())["schemas"]
                           for version in schema["versions"]]

schema_paths = [a_path
                for a_path in all_paths
                if a_path not in registered_schema_paths]


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
# 4. Subfolder of schemas dir = "OneDrive/GitHub/UMCCR/schemas/contig/" -> current path resolved
if current_word_value is not None:
    if current_word_value.endswith("/"):
        current_path_resolved = Path(getcwd()).joinpath(Path(current_word_value)).resolve()
    else:
        current_path_resolved = Path(getcwd()).joinpath(Path(current_word_value).parent).resolve()

else:
    current_word_value = ""
    current_path_resolved = Path(getcwd()).absolute()

# Is the current_path_resolved a subpath of the schemas directory?
try:
    _ = current_path_resolved.relative_to(get_schemas_dir())
    in_schemas_dir = True
except ValueError:
    in_schemas_dir = False

if in_schemas_dir:
    current_path_resolved_relative_to_schemas_dir = current_path_resolved.relative_to(get_schemas_dir())
    if current_path_resolved_relative_to_schemas_dir == Path("."):
        for s_path in schema_paths:
            if current_word_value.endswith("/"):
                print(Path(current_word_value) / s_path)
            else:
                print(Path(current_word_value).parent / s_path)
    else:
        for s_path in schema_paths:
            if str(s_path).startswith(str(current_path_resolved_relative_to_schemas_dir)):
                if current_word_value.endswith("/"):
                    print(Path(current_word_value) / s_path.relative_to(current_path_resolved_relative_to_schemas_dir))
                else:
                    print(Path(current_word_value).parent / s_path.relative_to(current_path_resolved_relative_to_schemas_dir))

else:
    # Now get the schemas yaml path relative to the current path
    try:
        schemas_dir = get_schemas_dir().relative_to(current_path_resolved)
    except ValueError:
        # We could be in a different mount point OR just in a subdirectory
        if str(get_schemas_dir().absolute()) in str(relpath(get_schemas_dir(), current_path_resolved)):
            # Separate mount point
            schemas_dir = get_schemas_dir().absolute()
        else:
            schemas_dir = Path(relpath(get_schemas_dir(), current_path_resolved))

    # Now iterate through paths
    for s_path in schema_paths:
        if current_word_value.endswith("/"):
            print(Path(current_word_value) / schemas_dir.joinpath(s_path))
        else:
            print(Path(current_word_value).parent / schemas_dir.joinpath(s_path))