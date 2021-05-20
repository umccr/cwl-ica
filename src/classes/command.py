import sys
from docopt import docopt
from utils.logging import get_logger

logger = get_logger()


class Command:
    """
    Template object for subcommands
    """

    def __init__(self, command_argv):
        # Initialise any req vars
        self.args = self.get_args(command_argv)

    def get_args(self, command_argv):
        """
        :return:
        """
        # Get arguments from commandline
        return docopt(self.__doc__, argv=command_argv, options_first=False)

    def _help(self, fail=False):
        """
        Returns self help doc
        :return:
        """
        print(self.__doc__)
        # If fail will exit 1, else exit 0.
        sys.exit(int(fail))

    def check_length(self, command_argv):
        """
        If arg has just one length, append help
        :return:
        """
        if len(command_argv) == 1:
            logger.debug("Got only one arg, appending 'help'")
            self.args["help"] = True

    def check_args(self):
        """
        Defined in the subfunction
        :return:
        """
        raise NotImplementedError
