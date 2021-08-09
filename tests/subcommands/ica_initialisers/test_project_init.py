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


class TestProjectInit:

    def test_valid_init(self, repo_path):
        """
        Ensure that the args are assigned to the correct attributes for a ConfigureRepo object
        :param repo_path:
        :return:
        """
        # Initialise a ProjectInit object and make sure the attributes are correct

        # TODO - we need to mock up the following before proceeding
        # TODO - get_api_key
        # TODO - create_personal_access_token
        # TODO - get_projects_list
        # TODO - create_token_api_key_with_role
        # TODO - get_jwt_token_obj

        assert False
