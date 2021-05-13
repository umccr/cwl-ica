#!/usr/bin/env python3

"""
Test the configure-repo subcommand
"""

import pytest
from mockito import when
from pathlib import Path
from subcommands.configure.configure_repo import ConfigureRepo, CWL_ICA_REPO_PATH_ENV_VAR, CWL_ICA_REPO_ACTIVATE_D_FILENAME
from ruamel.yaml import YAML
from collections import OrderedDict
import utils.conda
from utils.conda import get_conda_activate_dir


@pytest.fixture(scope="session")
def repo_path(tmp_path_factory):
    repo_path = tmp_path_factory.mktemp("cwl-ica")

    yield repo_path


@pytest.fixture
def cwl_ica_env_var(monkeypatch, repo_path):
    monkeypatch.setenv("CWL_ICA_REPO_PATH", str(repo_path))


@pytest.fixture(scope="session")
def conda_prefix(tmp_path_factory):
    conda_prefix = tmp_path_factory.mktemp("cwl-ica")

    yield conda_prefix


class TestConfigureRepo:

    def test_valid_init(self, repo_path):
        """
        Ensure that the args are assigned to the correct attributes for a ConfigureRepo object
        :param repo_path:
        :return:
        """
        # Initialse a ConfigureRepo object and make sure the attributes are correct

        # Inputs
        valid_command_args = [
            "configure-repo",
            "--repo-path", str(repo_path)
        ]

        # Expected outputs
        expected_attributes = {
            "repository_path": repo_path
        }

        configure_repo_object = ConfigureRepo(command_argv=valid_command_args)

        for key in expected_attributes.keys():
            assert getattr(configure_repo_object, key) == expected_attributes.get(key)

    def test_valid_call(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Check the check_args method
        :return:
        """

        when(utils.conda).get_conda_prefix(...).thenReturn(conda_prefix)

        # Inputs
        valid_command_args = [
            "configure-repo",
            "--repo-path", str(repo_path)
        ]

        # Initialise repo object
        configure_repo_object = ConfigureRepo(command_argv=valid_command_args)

        # Call repo object
        configure_repo_object()

        # Assert that the conda CWL_ICA_REPO_PATH src has been written to
        src_file = get_conda_activate_dir() / Path(CWL_ICA_REPO_ACTIVATE_D_FILENAME)

        assert src_file.is_file(), "Error, expected to write cwl-ica-repo-path.sh in conda prefix activate.d directory"

        with open(src_file, "r") as src_h:
            src_file_lines = src_h.readlines()

        # Check there's only one line in this file
        assert len(src_file_lines) == 1, "Error, expected only one line for the cwl-ica-repo-path.sh file in the " \
                                         "conda prefix activate.d directory but got {num_lines}".format(
            num_lines=len(src_file_lines)
        )

        # Check that the first line in this file
        expected_line = "export {env_var}=\"{repo_path}\"".format(
            env_var=CWL_ICA_REPO_PATH_ENV_VAR,
            repo_path=repo_path
        )

        actual_line = src_file_lines[0].strip()

        assert actual_line == expected_line, "Error, expected line was {expected_line} but got {actual_line}".format(
            expected_line=expected_line,
            actual_line=actual_line
        )
