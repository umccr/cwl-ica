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


# Run through bash completions
for template in templates/*.yaml; do
  [[ -e "$template" ]] || break  # handle the case of no *.yaml files
  name_root="$(basename "${template%-autocompletion.yaml}")"
  docker run \
	--volume "$PWD:$PWD" \
        --workdir "$PWD" \
	agrf/appspec:0.006 \
  		completion \
			"${template}" \
		    	--name "${name_root}" \
		    	--bash > "bash/${name_root}.sh"

	# Update first line from '#!bash' to '#!/usr/bin/env bash'
	sed -i '1c#!/usr/bin/env bash' "bash/${name_root}.sh"
done

# Run through zsh completions
for template in templates/*.yaml; do
  [[ -e "$template" ]] || break  # handle the case of no *.yaml files
  name_root="$(basename "${template%-autocompletion.yaml}")"
  docker run \
	--volume "$PWD:$PWD" \
        --workdir "$PWD" \
	agrf/appspec:0.006 \
	  	completion \
        		"${template}" \
            --name "${name_root}" \
	        	--zsh > "zsh/_${name_root}"
done
