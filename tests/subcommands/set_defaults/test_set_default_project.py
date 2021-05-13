#!/usr/bin/env python3

"""
Test the set-default-tenant subcommand
"""

import pytest
from mockito import when
from pathlib import Path
from subcommands.updaters.set_default_project import SetDefaultProject
from ruamel.yaml import YAML
from collections import OrderedDict
import utils.conda
from utils.conda import get_conda_activate_dir
from utils.repo import read_yaml, get_project_yaml_path
from utils.yaml import dump_yaml
from utils.repo import get_project_yaml_path


@pytest.fixture(scope="session")
def repo_path(tmp_path_factory):
    repo_path = tmp_path_factory.mktemp("cwl-ica")

    # Also make sure that there exists a "config" directory
    (Path(repo_path) / Path("config")).mkdir(exist_ok=True)

    yield repo_path


@pytest.fixture
def cwl_ica_env_var(monkeypatch, repo_path):
    monkeypatch.setenv("CWL_ICA_REPO_PATH", str(repo_path))


@pytest.fixture(scope="session")
def conda_prefix(tmp_path_factory):
    conda_prefix = tmp_path_factory.mktemp("cwl-ica")

    yield conda_prefix


class TestSetDefaultProject:

    def test_valid_init(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Ensure that the args are assigned to the correct attributes for a ConfigureRepo object
        :param repo_path:
        :return:
        """

        # Inputs
        valid_command_args = [
            "set-default-project",
            "--project-name", "development"
        ]

        # Expected outputs
        expected_attributes = {
            "project_name": "development"
        }

        # Components of project.yaml
        project_list = [{
            "project_name": "development",
            "project_id": "dc8e6ba9-b744-437b-b070-4cf014694b3d",
            "project_description": "Development project",
            "project_abbr": "dev",
            "project_api_key_name": "development",
            "tenant_id": "YXdzLXVzLXBsYXRmb3JtOjEwMDAwNTM3OjBiYTU5YWUxLWZkYWUtNDNiYS1hM2I1LTRkMzY3YTQzYWJkNQ",
            "production": True,
            "tools": [],
            "workflows": []
        }]

        # Dump yaml
        project_dict = {"projects": project_list}
        with open(get_project_yaml_path(non_existent_ok=True), 'w') as project_h:
            dump_yaml(project_dict, project_h)

        set_default_project_object = SetDefaultProject(command_argv=valid_command_args)

        for key in expected_attributes.keys():
            assert getattr(set_default_project_object, key) == expected_attributes.get(key)

    def test_valid_call(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Check the check_args method
        :return:
        """

        when(utils.conda).get_conda_prefix(...).thenReturn(conda_prefix)

        # Inputs
        valid_command_args = [
            "set-default-project",
            "--project-name", "development"
        ]

        project_list = [{
            "project_name": "development"
        }]

        # Dump yaml
        project_dict = {"projects": project_list}
        with open(get_project_yaml_path(), 'w') as project_h:
            dump_yaml(project_dict, project_h)

        # Initialise repo object
        set_default_project_object = SetDefaultProject(command_argv=valid_command_args)

        # Call repo object
        set_default_project_object()

        # Assert that the conda CWL_ICA_REPO_PATH src has been written to
        import os
        print(os.listdir(get_conda_activate_dir()))
        src_file = get_conda_activate_dir() / Path("default_project.sh")

        assert src_file.is_file(), "Error, expected to write default_project.sh in conda prefix activate.d directory"

        with open(src_file, "r") as src_h:
            src_file_lines = src_h.readlines()

        # Check there's only one line in this file
        assert len(src_file_lines) == 1, "Error, expected only one line for the default_project.sh file in the " \
                                         "conda prefix activate.d directory but got {num_lines}".format(
            num_lines=len(src_file_lines)
        )

        # Check that the first line in this file
        expected_line = "export {env_var}=\"{project_name}\"".format(
            env_var="CWL_ICA_DEFAULT_PROJECT",
            project_name="development"
        )

        actual_line = src_file_lines[0].strip()

        assert actual_line == expected_line, "Error, expected line was {expected_line} but got {actual_line}".format(
            expected_line=expected_line,
            actual_line=actual_line
        )
