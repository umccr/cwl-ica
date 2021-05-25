#!/usr/bin/env python3

"""
Test the configure-repo subcommand
"""

import pytest
from mockito import when
from pathlib import Path
from subcommands.configure.configure_user import ConfigureUser
from ruamel.yaml import YAML
from collections import OrderedDict
import utils.conda
from utils.conda import get_conda_activate_dir


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


class TestConfigureUser:

    def test_valid_call(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Check the check_args method
        :return:
        """

        when(utils.conda).get_conda_prefix(...).thenReturn(conda_prefix)

        # Inputs
        valid_command_args = [
            "configure-user",
            "--username", "Alexis Lucattini",
            "--email", "Alexis.Lucattini@umccr.org",
        ]

        expected_yaml_dict = {
            "username": "Alexis Lucattini",
            "email": "Alexis.Lucattini@umccr.org",
        }

        # Initialise repo object
        configure_user_object = ConfigureUser(command_argv=valid_command_args)

        # Call repo object
        configure_user_object()

        # Run assertions on expected outputs
        user_yaml_output = repo_path / Path("config") / Path("user.yaml")
        assert user_yaml_output.is_file()

        # Re load file and assert dict is as expected
        ruamel_yaml = YAML(typ="safe")

        # First make sure file exists
        assert user_yaml_output.is_file(), "Error, output user.yaml configuration file does not exist"

        # Then load file
        with open(user_yaml_output, 'r') as user_h:
            actual_yaml_list = ruamel_yaml.load(user_h)['users']

        # Check file is not empty
        assert actual_yaml_list is not None, "Error, output user.yaml configuration file was empty"

        # Now make sure the dicts are identical (in the identical order)
        assert OrderedDict(actual_yaml_list[0]) == OrderedDict(expected_yaml_dict)

    def test_valid_call_with_identifier(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Check the check_args method
        :return:
        """

        when(utils.conda).get_conda_prefix(...).thenReturn(conda_prefix)

        # Inputs
        valid_command_args = [
            "configure-user",
            "--username", "Alexis Lucattini 2",
            "--email", "Alexis.Lucattini.2@umccr.org",
            "--identifier", "https://orcid.org/0000-0001-9754-647X"
        ]

        expected_yaml_dict = {
            "username": "Alexis Lucattini 2",
            "email": "Alexis.Lucattini.2@umccr.org",
            "identifier": "https://orcid.org/0000-0001-9754-647X"
        }

        # Initialise repo object
        configure_user_obj = ConfigureUser(command_argv=valid_command_args)

        # Call repo object
        configure_user_obj()

        # Run assertions on expected outputs
        user_yaml_output = repo_path / Path("config") / Path("user.yaml")
        assert user_yaml_output.is_file()

        # Re load file and assert dict is as expected
        ruamel_yaml = YAML(typ="safe")

        # First make sure file exists
        assert user_yaml_output.is_file(), "Error, output user.yaml configuration file does not exist"

        # Then load file
        with open(user_yaml_output, 'r') as user_h:
            actual_yaml_list = ruamel_yaml.load(user_h)['users']

        # Check file is not empty
        assert actual_yaml_list is not None, "Error, output user.yaml configuration file was empty"

        # Now make sure the dicts are identical (in the identical order)
        assert OrderedDict(actual_yaml_list[-1]) == OrderedDict(expected_yaml_dict)

    def test_valid_call_set_as_default(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Check the check_args method
        :return:
        """

        when(utils.conda).get_conda_prefix(...).thenReturn(conda_prefix)

        # Inputs
        valid_command_args = [
            "configure-user",
            "--username", "Alexis Lucattini 3",
            "--email", "Alexis.Lucattini3@umccr.org",
            "--set-as-default"
        ]

        # Initialise repo object
        configure_user_object = ConfigureUser(command_argv=valid_command_args)

        # Call repo object
        configure_user_object()

        # Assert that the conda CWL_ICA_REPO_PATH src has been written to
        src_file = get_conda_activate_dir() / Path("default_user.sh")

        assert src_file.is_file(), "Error, expected to write default_user.sh in conda prefix activate.d directory"

        with open(src_file, "r") as src_h:
            src_file_lines = src_h.readlines()

        # Check there's only one line in this file
        assert len(src_file_lines) == 1, "Error, expected only one line for the cwl-ica-repo-path.sh file in the " \
                                         "conda prefix activate.d directory but got {num_lines}".format(
            num_lines=len(src_file_lines)
        )

        # Check that the first line in this file
        expected_line = "export {env_var}=\"{user_name}\"".format(
            env_var="CWL_ICA_DEFAULT_USER",
            user_name="Alexis Lucattini 3"
        )

        # Add in actual line
        actual_line = src_file_lines[0].strip()

        assert actual_line == expected_line, "Error, expected line was {expected_line} but got {actual_line}".format(
            expected_line=expected_line,
            actual_line=actual_line
        )
