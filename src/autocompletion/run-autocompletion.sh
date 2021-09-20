#!/usr/bin/env bash

# Set to fail on non-zero exit code
set -euo pipefail

# Get to this directory
if [[ "${OSTYPE}" == "darwin"* ]]; then
  readlink_program="greadlink"
else
  readlink_program="readlink"
fi

this_dir=$(dirname "$("${readlink_program}" -f "${0}")")
cd "${this_dir}"

# Create 'bash' and 'zsh' directories
mkdir -p "bash"
mkdir -p "zsh"

python_tempfile=$(mktemp "my_generated_python_script.XXXXXX.py")
cat > "${python_tempfile}" <<EOF
#!/usr/bin/env python
"""
Edit yaml for each item in helpers
"""
from pathlib import Path
import fileinput
import sys
helper_files = [g_item.name for g_item in (Path(sys.argv[2]) / Path("helpers")).glob("*.py")]
INDENTATION = 12
with fileinput.input(sys.argv[1], inplace=True) as template_h:
    for t_line in template_h:
        print_line_as_is = True
        for helper_file in helper_files:
            if "_%s" % helper_file in t_line.strip():
                print_line_as_is = False
                # We print the entire helper file (and indent by a magical number)
                with open(str(Path(sys.argv[2]) / "helpers" / helper_file), "r") as helper_h:
                    for h_line in helper_h.readlines():
                        print(" " * (INDENTATION - 1), h_line.rstrip())
        if print_line_as_is:
            print(t_line.rstrip())
EOF

# Replace lines in yaml file with helpers
for template in templates/*.yaml; do
  # Create an evaluation of the template first
  cp "${template}" "${template}.evalyaml"
  python "${python_tempfile}" "${template}.evalyaml" "${this_dir}"
done
rm "${python_tempfile}"

# Run through bash completions
for template in templates/*.evalyaml; do
  [[ -e "$template" ]] || break  # handle the case of no *.yaml files
  name_root="$(basename "${template%-autocompletion.yaml.evalyaml}")"
  docker run \
	--volume "$PWD:$PWD" \
        --workdir "$PWD" \
	umccr/appspec:0.006 \
	    appspec \
  		completion \
			"${template}" \
		    	--name "${name_root}" \
		    	--bash > "bash/${name_root}.bash"

	# Update first line from '#!bash' to '#!/usr/bin/env bash'
	sed -i '1c#!/usr/bin/env bash' "bash/${name_root}.bash"

	# Secondly convert any EOF) to EOF\n)
	sed -i  $'s/EOF)/EOF\\\n)/' "bash/${name_root}.bash"
done

# Run through zsh completions
for template in templates/*.evalyaml; do
  [[ -e "$template" ]] || break  # handle the case of no *.yaml files
  name_root="$(basename "${template%-autocompletion.yaml.evalyaml}")"
  docker run \
	--volume "$PWD:$PWD" \
        --workdir "$PWD" \
	umccr/appspec:0.006 \
	    appspec \
	  	completion \
        		"${template}" \
            --name "${name_root}" \
	        	--zsh > "zsh/_${name_root}"
done


