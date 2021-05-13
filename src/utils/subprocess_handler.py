#!/usr/bin/env python3


from utils.logging import get_logger
import subprocess

logger = get_logger()


def run_subprocess_proc(*args, **kwargs):
    """
    Utilities runner for running a subprocess command and printing log files
    :param args:
    :param kwargs:
    :return:
    """

    subprocess_proc = subprocess.run(*args, **kwargs)

    command_str = '" "'.join(map(str, ["\'%s\'" % arg for arg in subprocess_proc.args])) \
        if type(subprocess_proc.args) == list \
        else subprocess_proc.args
    command_str = '"' + command_str + '"'

    # Get outputs
    if subprocess_proc.stdout is not None:
        command_stdout = subprocess_proc.stdout.decode()
    else:
        command_stdout = None

    if subprocess_proc.stderr is not None:
        command_stderr = subprocess_proc.stderr.decode()
    else:
        command_stderr = None

    # Get return code
    command_returncode = subprocess_proc.returncode

    if not command_returncode == 0:
        # Print returncode to warning
        logger.warning("Received exit code \"{}\" for command {}".format(
            command_returncode,
            command_str
        ))
        # Print stdout/stderr to console
        if command_stdout is not None:
            logger.warning("Stdout was: \n\"{}\"".format(command_stdout.strip()))
        if command_stderr is not None:
            logger.warning("Stderr was: \n\"{}\"".format(command_stderr.strip()))
    else:
        # Let debug know command returned successfully
        logger.debug("Command \"{}\" returned successfully".format(command_str))
        # Print stdout/stderr to console
        if command_stdout is not None:
            logger.debug("Stdout was: \n\"{}\"".format(command_stdout.strip()))
        if command_stderr is not None:
            logger.debug("Stderr was: \n\"{}\"".format(command_stderr.strip()))

    return command_returncode, command_stdout, command_stderr
