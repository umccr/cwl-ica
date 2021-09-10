#!/usr/bin/env bash

: '
Wraps around autocompletion to run the appspec completion command from within the docker container
'

# Set to fail on non-zero exit code
set -euo pipefail

# Globals
AUTOCOMPLETION_DIR="src/autocompletion"
CWL_ICA_NAMEROOT="cwl-ica"
TEMPLATE_FILE="templates/${CWL_ICA_NAMEROOT}-autocompletion.yaml"

# Some 'global' temp files
EVAL_TEMPLATE_TEMPFILE="$(mktemp -p /tmp "my_generated_temp_cwl-ica_autocompletion.XXXXXX.yaml")"
PYTHON_TEMPFILE="$(mktemp -p /tmp "my_generated_python_script.XXXXXX.py")"

cat > "${PYTHON_TEMPFILE}" <<EOF
#!/usr/bin/env python
"""
Edit yaml for each item in helpers
"""
from pathlib import Path
import fileinput
import sys
helper_files = [g_item.name for g_item in Path("helpers").glob("*.py")]
INDENTATION = 12
with fileinput.input(sys.argv[1], inplace=True) as template_h:
    for t_line in template_h:
        print_line_as_is = True
        for helper_file in helper_files:
            if "_%s" % helper_file in t_line.strip():
                print_line_as_is = False
                # We print the entire helper file (and indent by a magical number)
                with open(str(Path("helpers") / helper_file), "r") as helper_h:
                    for h_line in helper_h.readlines():
                        print(" " * (INDENTATION - 1), h_line.rstrip())
        if print_line_as_is:
            print(t_line.rstrip())
EOF

(
  : '
  Run the rest in a subshell
  '

  # Change to autocompletion dir
  cd "${AUTOCOMPLETION_DIR}"

  # Copy over the autocompletion to the temp file
  cp "${TEMPLATE_FILE}" "${EVAL_TEMPLATE_TEMPFILE}"


  # Run auto-generator script on file
  python3 "${PYTHON_TEMPFILE}" "${EVAL_TEMPLATE_TEMPFILE}"

  # Create the bash and zsh dirs
  mkdir -p "bash"
  mkdir -p "zsh"

  # Run the bash completion script
  appspec completion \
    "${EVAL_TEMPLATE_TEMPFILE}" \
    --name "${CWL_ICA_NAMEROOT}" \
    --bash > "bash/${CWL_ICA_NAMEROOT}.bash"

  # Overwrite shebang
  sed -i '1c#!/usr/bin/env bash' "bash/${CWL_ICA_NAMEROOT}.bash"

  # Secondly convert any EOF) to EOF\n)
  sed -i  $'s/EOF)/EOF\\\n)/' "bash/${CWL_ICA_NAMEROOT}.bash"

  # Run the zsh completion script
  appspec completion \
    "${EVAL_TEMPLATE_TEMPFILE}" \
    --name "${CWL_ICA_NAMEROOT}" \
    --zsh > "zsh/_${CWL_ICA_NAMEROOT}"

)

# Delete the 'global' tempfiles
rm "${EVAL_TEMPLATE_TEMPFILE}" "${PYTHON_TEMPFILE}"
