#!/usr/bin/env python

"""
A few little shortcuts for conda
"""

import os
from pathlib import Path
from utils.logging import get_logger
from utils.errors import CondaError

logger = get_logger()


def get_conda_env_name():
    """
    Return the name of the conda environment we're currently in
    :return:
    """
    # Need to find a use-case for this.
    # TODO
    pass


def get_conda_prefix():
    """
    Return the env var CONDA_PREFIX
    :return:
    """
    # Get conda prefix from env
    conda_prefix = os.environ["CONDA_PREFIX"]

    # Make sure conda prefix isn't none before returning and exists
    if conda_prefix is None:
        logger.error("Could not get env var 'CONDA_PREFIX'. Make sure you're running this repo in a conda environment")
        raise CondaError

    if not Path(conda_prefix).is_dir():
        logger.error("CONDA_PREFIX env var \"{conda_prefix}\" is not a directory".format(conda_prefix=conda_prefix))
        raise CondaError

    return conda_prefix


def get_conda_activate_dir(create_if_non_existent=True):
    """
    Simply returns Path(conda-prefix) / etc / conda / activate.d
    :return:
    """

    activate_d_dir = Path(get_conda_prefix()) / "etc" / "conda" / "activate.d"

    if not activate_d_dir.is_dir() and create_if_non_existent:
        activate_d_dir.mkdir(parents=True)

    return activate_d_dir


def get_conda_tokens_dir():
    """
    Simply returns Path(conda-prefix) / etc / ica / tokens
    :return:
    """

    return Path(get_conda_prefix()) / "etc" / "ica" / "tokens"


def create_tokens_dir(tokens_dir: Path):
    """
    Create tokens dir with 700 permissions
    :param tokens_dir:
    :return:
    """
    # Create tokens directory
    if not tokens_dir.is_dir():
        tokens_dir.mkdir(mode=0o700, parents=True)


def check_tokens_dir(tokens_dir):
    """
    Make sure tokens dir is modifications 700
    :param tokens_dir:
    :return:
    """
