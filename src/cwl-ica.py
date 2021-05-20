#!/usr/bin/env python3

# Basically just copied from the setup.py creator
import re
import sys

# Import the main from the cli utils
from utils.cli import main

# Then
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
