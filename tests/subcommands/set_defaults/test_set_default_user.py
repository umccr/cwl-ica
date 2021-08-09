#!/usr/bin/env python3

"""
Test the set-default-user subcommand
"""

import pytest
from mockito import when
from pathlib import Path
from subcommands.updaters.set_default_user import SetDefaultUser
from ruamel.yaml import YAML
from collections import OrderedDict
import utils.conda
from utils.conda import get_conda_activate_dir
from utils.repo import read_yaml, get_user_yaml_path
from utils.yaml import dump_yaml


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


class TestSetDefaultUser:

    def test_valid_init(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Ensure that the args are assigned to the correct attributes for a ConfigureRepo object
        :param repo_path:
        :return:
        """

        # Initialse a ConfigureRepo object and make sure the attributes are correct

        # Inputs
        valid_command_args = [
            "set-default-user",
            "--username", "FirstName LastName"
        ]

        # Expected outputs
        expected_attributes = {
            "username": "FirstName LastName"
        }

        # Components of user.yaml
        user_list = [{
            "username": "FirstName LastName",
            "email": "FirstName.LastName@umccr.org"
        }]

        # Dump yaml
        user_dict = {"users": user_list}
        with open(get_user_yaml_path(non_existent_ok=True), 'w') as user_h:
            dump_yaml(user_dict, user_h)

        set_default_user_object = SetDefaultUser(command_argv=valid_command_args)

        for key in expected_attributes.keys():
            assert getattr(set_default_user_object, key) == expected_attributes.get(key)

    def test_valid_call(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Check the check_args method
        :return:
        """

        when(utils.conda).get_conda_prefix(...).thenReturn(conda_prefix)

        # Inputs
        valid_command_args = [
            "set-default-user",
            "--username", "FirstName LastName"
        ]

        user_list = [{
            "username": "FirstName LastName",
            "email": "FirstName.LastName@umccr.org"
        }]

        # Dump yaml
        user_dict = {"users": user_list}
        with open(get_user_yaml_path(), 'w') as user_h:
            dump_yaml(user_dict, user_h)

        # Initialise repo object
        set_default_user_object = SetDefaultUser(command_argv=valid_command_args)

        # Call repo object
        set_default_user_object()

        # Assert that the conda CWL_ICA_REPO_PATH src has been written to
        import os
        src_file = get_conda_activate_dir() / Path("default_user.sh")

        assert src_file.is_file(), "Error, expected to write default_user.sh in conda prefix activate.d directory"

        with open(src_file, "r") as src_h:
            src_file_lines = src_h.readlines()

        # Check there's only one line in this file
        assert len(src_file_lines) == 1, "Error, expected only one line for the default_user.sh file in the " \
                                         "conda prefix activate.d directory but got {num_lines}".format(
            num_lines=len(src_file_lines)
        )

        # Check that the first line in this file
        expected_line = "export {env_var}=\"{user_name}\"".format(
            env_var="CWL_ICA_DEFAULT_USER",
            user_name="FirstName LastName"
        )

        actual_line = src_file_lines[0].strip()

        assert actual_line == expected_line, "Error, expected line was {expected_line} but got {actual_line}".format(
            expected_line=expected_line,
            actual_line=actual_line
        )
