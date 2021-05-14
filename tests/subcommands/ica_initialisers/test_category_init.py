#!/usr/bin/env python3

"""
Test the configure-repo subcommand
"""

import pytest
from mockito import when
from pathlib import Path
from subcommands.initialisers.category_init import CategoryInit
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


class TestCategoryInit:

    def test_valid_init(self, repo_path):
        """
        Ensure that the args are assigned to the correct attributes for a CategoryInit object
        :param repo_path:
        :return:
        """
        # Initialse a ConfigureRepo object and make sure the attributes are correct

        # Inputs
        valid_command_args = [
            "category-init",
            "--name", "my-category",
            "--description", "my-category-description"
        ]

        # Expected outputs
        expected_attributes = {
            "category_name": "my-category",
            "category_description": "my-category-description",  # Because it's converted to a multiline string
        }

        category_init_obj = CategoryInit(command_argv=valid_command_args)

        for key in expected_attributes.keys():
            assert getattr(category_init_obj, key) == expected_attributes.get(key)

    def test_valid_call(self, repo_path, cwl_ica_env_var, conda_prefix):
        """
        Check the check_args method
        :return:
        """

        when(utils.conda).get_conda_prefix(...).thenReturn(conda_prefix)

        # Inputs
        valid_command_args = [
            "category-init",
            "--name", "my-second-category",
            "--description", "my-second-category-description"
        ]

        expected_yaml_dict = {
            "name": "my-second-category",
            "description": "my-second-category-description\n"
        }

        # Initialise repo object
        category_init_obj = CategoryInit(command_argv=valid_command_args)

        # Call repo object
        category_init_obj()

        # Run assertions on expected outputs
        category_yaml_output = repo_path / Path("config") / Path("category.yaml")
        assert category_yaml_output.is_file()

        # Re load file and assert dict is as expected
        ruamel_yaml = YAML(typ="safe")

        # First make sure file exists
        assert category_yaml_output.is_file(), "Error, output user.yaml configuration file does not exist"

        # Then load file
        with open(category_yaml_output, 'r') as user_h:
            actual_yaml_list = ruamel_yaml.load(user_h)['categories']

        # Check file is not empty
        assert actual_yaml_list is not None, "Error, output user.yaml configuration file was empty"

        # Now make sure the dicts are identical (in the identical order)
        assert OrderedDict(actual_yaml_list[0]) == OrderedDict(expected_yaml_dict)
