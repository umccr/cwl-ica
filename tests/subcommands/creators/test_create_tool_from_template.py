#!/usr/bin/env python3

"""
Test the create-tool-from-template subcommand
"""

import pytest
from pathlib import Path
from subcommands.creators.test_create_tool_from_template import CreateToolFromTemplate
from ruamel.yaml import YAML
from utils.repo import get_user_yaml_path
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


@pytest.fixture
def cwl_ica_default_user_env_var(monkeypatch):
    monkeypatch.setenv("CWL_ICA_DEFAULT_USER", "FirstName LastName")


@pytest.fixture(scope="session")
def conda_prefix(tmp_path_factory):
    conda_prefix = tmp_path_factory.mktemp("cwl-ica")

    yield conda_prefix


class TestCreateToolFromTemplate:

    def test_valid_init(self, repo_path, cwl_ica_env_var):
        """
        Ensure that the args are assigned to the correct attributes for a ConfigureTenant object
        Essentially just checking the __init__ method
        :param repo_path:
        :return:
        """
        # Initialse a ConfigureTenant object and make sure the attributes are correct

        # Inputs
        valid_command_args = [
            "create-tool-from-template",
            "--tool-name", "samtools-merge",
            "--tool-version", "1.10.0",
            "--username", "FirstName LastName"
        ]

        user_list = [{
            "username": "FirstName LastName",
            "email": "FirstName.LastName@umccr.org"
        }]

        # Dump yaml
        user_dict = {"users": user_list}
        with open(get_user_yaml_path(non_existent_ok=True), 'w') as user_h:
            dump_yaml(user_dict, user_h)

        # Expected outputs
        expected_attributes = {
            "name": "samtools-merge",
            "version": "1.10.0",
        }

        create_tool_from_template = CreateToolFromTemplate(command_argv=valid_command_args)

        for key in expected_attributes.keys():
            assert getattr(create_tool_from_template, key) == expected_attributes.get(key)

    def test_valid_call(self, repo_path, cwl_ica_env_var, cwl_ica_default_user_env_var):
        """
        Basically just checking the __call__ method
        :return:
        """

        # Inputs
        valid_command_args = [
            "create-tool-from-template",
            "--tool-name", "samtools-fastq",
            "--tool-version", "1.10.0",
        ]

        expected_output_keys = ['cwlVersion', 'class', '$namespaces', '$schemas',
                                's:author', 'id', 'label', 'doc', 'hints', 'baseCommand', 'inputs', 'outputs']

        # Initialise tenant object
        create_tool_from_template = CreateToolFromTemplate(command_argv=valid_command_args)

        # Call tenant object
        create_tool_from_template()

        # Run assertions on expected outputs
        tool_output_path = repo_path / Path("tools") / Path("samtools-fastq") / Path("1.10.0") / Path("samtools-fastq__1.10.0.cwl")
        assert tool_output_path.is_file()

        # Re load file and assert dict is as expected
        ruamel_yaml = YAML(typ="safe")

        # First make sure file exists
        assert tool_output_path.is_file(), "Error, output tenant.yaml configuration file does not exist"

        # Then load file
        with open(tool_output_path, 'r') as cwl_h:
            actual_cwl_keys = list(ruamel_yaml.load(cwl_h).keys())

        # Check file is not empty
        assert actual_cwl_keys is not None, "Error, output tenant.yaml configuration file was empty"

        # Now make sure the dicts are identical (in the identical order)
        assert actual_cwl_keys == expected_output_keys
