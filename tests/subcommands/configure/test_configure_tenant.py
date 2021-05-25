#!/usr/bin/env python3

"""
Test the configure-repo subcommand
"""

import pytest
from pathlib import Path
from subcommands.configure.configure_tenant import ConfigureTenant
from ruamel.yaml import YAML
import utils.conda
from utils.conda import get_conda_activate_dir
from mockito import when


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


class TestConfigureTenant:

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
            "configure-tenant",
            "--tenant-id", "my-tenant-id",
            "--tenant-name", "my-tenant-name"
        ]

        # Expected outputs
        expected_attributes = {
            "tenant_id": "my-tenant-id",
            "tenant_name": "my-tenant-name",
        }

        configure_tenant_object = ConfigureTenant(command_argv=valid_command_args)

        for key in expected_attributes.keys():
            assert getattr(configure_tenant_object, key) == expected_attributes.get(key)

    def test_valid_call(self, repo_path, cwl_ica_env_var):
        """
        Basically just checking the __call__ method
        :return:
        """

        # Inputs
        valid_command_args = [
            "configure-tenant",
            "--tenant-id", "my-tenant-id",
            "--tenant-name", "my-tenant-name"
        ]

        expected_yaml_list = [
            {
                "tenant_id": "my-tenant-id",
                "tenant_name": "my-tenant-name"
            }
        ]

        # Initialise tenant object
        configure_tenant_object = ConfigureTenant(command_argv=valid_command_args)

        # Call tenant object
        configure_tenant_object()

        # Run assertions on expected outputs
        tenant_yaml_output = repo_path / Path("config") / Path("tenant.yaml")
        assert tenant_yaml_output.is_file()

        # Re load file and assert dict is as expected
        ruamel_yaml = YAML(typ="safe")

        # First make sure file exists
        assert tenant_yaml_output.is_file(), "Error, output tenant.yaml configuration file does not exist"

        # Then load file
        with open(tenant_yaml_output, 'r') as user_h:
            actual_yaml_list = ruamel_yaml.load(user_h)["tenants"]

        # Check file is not empty
        assert actual_yaml_list is not None, "Error, output tenant.yaml configuration file was empty"

        # Now make sure the dicts are identical (in the identical order)
        assert actual_yaml_list == expected_yaml_list

    def test_valid_set_as_default(self, repo_path, cwl_ica_env_var, conda_prefix):
        """

        :param self:
        :param repo_path:
        :param cwl_ica_env_var:
        :return:
        """

        when(utils.conda).get_conda_prefix(...).thenReturn(conda_prefix)

        # Inputs
        valid_command_args = [
            "configure-tenant",
            "--tenant-id", "my-second-tenant-id",
            "--tenant-name", "my-second-tenant-name",
            "--set-as-default"
        ]

        # Initialise tenant object
        configure_tenant_object = ConfigureTenant(command_argv=valid_command_args)

        # Call tenant object
        configure_tenant_object()

        # Assert that the conda CWL_ICA_REPO_PATH src has been written to
        src_file = get_conda_activate_dir() / Path("default_tenant.sh")

        assert src_file.is_file(), "Error, expected to write default_tenant.sh in conda prefix activate.d directory"

        with open(src_file, "r") as src_h:
            src_file_lines = src_h.readlines()

        # Check there's only one line in this file
        assert len(src_file_lines) == 1, "Error, expected only one line for the cwl-ica-repo-path.sh file in the " \
                                         "conda prefix activate.d directory but got {num_lines}".format(
            num_lines=len(src_file_lines)
        )

        # Check that the first line in this file
        expected_line = "export {env_var}=\"{tenant_name}\"".format(
            env_var="CWL_ICA_DEFAULT_TENANT",
            tenant_name="my-second-tenant-name"
        )

        # Add in actual line
        actual_line = src_file_lines[0].strip()

        assert actual_line == expected_line, "Error, expected line was {expected_line} but got {actual_line}".format(
            expected_line=expected_line,
            actual_line=actual_line
        )
