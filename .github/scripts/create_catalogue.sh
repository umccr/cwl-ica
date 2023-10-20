#!/usr/bin/env bash

# Set for failure
set -euo pipefail

# Set Globals
export CWL_ICA_REPO_PATH="$PWD"
N_PARALLEL_JOBS="2"

# FUNCTIONS
echo_stderr(){
  : '
  Write out to stderr
  '
  echo "${@}" 1>&2
}

get_cwl_paths_array_from_yaml(){
  : '
  Get the cwl paths in form of a bash array
  '

  local yaml_path="$1"  # Path to the yaml file
  local yaml_key="$2"   # Either 'tools', 'expressions' or 'workflows'

  # Internal vars
  local workflows_json
  local cwl_paths_array=()

  # Get workflows as a json object
  workflows_json="$(yq eval "${yaml_path}" --tojson | jq --arg top_key "${yaml_key}" '.[$top_key]')"

  # Iterate over each item in the workflow json list
  # Credit: https://www.starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/
  for workflow_64 in $(echo "${workflows_json}" | jq -r '.[] | @base64'); do
    # Functionalise base64 decode step
    _base64_to_jq() {
       local base64_in="${1}"
       echo "${base64_in}" | base64 --decode
    }

    # New local vars
    local workflow_path
    local workflow_version_paths=()

    # Get name
    workflow_path="$(_base64_to_jq "${workflow_64}" | jq -r '.path')"

    # Get versions
    readarray -t workflow_version_paths < <(_base64_to_jq "${workflow_64}" | jq -rc '.versions[] | .path')

    # Iterate through versions and append to CWL array
    for workflow_version_path in "${workflow_version_paths[@]}"; do
       cwl_paths_array+=("${yaml_key}/${workflow_path}/${workflow_version_path}")
       # or do whatever with individual element of the array
    done

  done

  # Return array
  echo "${cwl_paths_array[@]}"
}

# Check env vars
if [[ ! -v GITHUB_REPOSITORY ]]; then
  echo_stderr "Error - expected env var GITHUB_REPOSITORY"
  exit 1
fi

if [[ ! -v GITHUB_SERVER_URL ]]; then
  echo_stderr "Error - expected env var GITHUB_SERVER_URL"
  exit 1
fi

# Set home directory
if [[ -z "${HOME-}" ]]; then
  HOME="$(mktemp -d)"
  export HOME
fi

# Set conda env path
CONDA_ENVS_PATH="$(mktemp -d)"
export CONDA_ENVS_PATH

# Softlink envs into this environment
ENVS_LIST=( "cwl-ica" "cwltool-icav1" )
for env_name in "${ENVS_LIST[@]}"; do
  ln -s \
    /home/cwl_ica_user/.conda/envs/${env_name} \
    "${CONDA_ENVS_PATH}/${env_name}"
done

# Now create the markdowns for the cwl expressions
if [[ -f "config/expression.yaml" ]]; then
  # Get the array of cwl expression paths
  IFS=" " read -r -a cwl_expression_paths_array <<< "$(get_cwl_paths_array_from_yaml "config/expression.yaml" "expressions")"

  # Run create-expression-markdown file jobs in parallel
  echo_stderr "Creating markdowns for expressions"
  parallel \
    --jobs "${N_PARALLEL_JOBS}" \
    cwl-ica github-actions-create-expression-markdown \
        --expression-path "{}" \
    ::: "${cwl_expression_paths_array[@]}"
fi


# Now create the markdowns for the cwl tools
if [[ -f "config/tool.yaml" ]]; then
  # Get the array of cwl tool paths
  IFS=" " read -r -a cwl_tool_paths_array <<< "$(get_cwl_paths_array_from_yaml "config/tool.yaml" "tools")"

  # Run create-tool-markdown file jobs in parallel
  echo_stderr "Creating markdowns for tools"
  parallel \
    --jobs "${N_PARALLEL_JOBS}" \
    cwl-ica github-actions-create-tool-markdown \
        --tool-path "{}" \
    ::: "${cwl_tool_paths_array[@]}"
fi

# Get the workflows paths array
if [[ -f "config/workflow.yaml" ]]; then
  IFS=" " read -r -a cwl_workflow_paths_array <<< "$(get_cwl_paths_array_from_yaml "config/workflow.yaml" "workflows")"

  # Run create-workflow-markdown file jobs in parallel
  echo_stderr "Creating markdowns for workflows"
  parallel \
    --jobs "${N_PARALLEL_JOBS}" \
    cwl-ica github-actions-create-workflow-markdown \
        --workflow-path "{}" \
    ::: "${cwl_workflow_paths_array[@]}"
fi

# Now create the catalogue
echo_stderr "Building the CWL Catalogue"

conda run --name "cwl-ica" \
  cwl-ica github-actions-create-catalogue \
    --output-path "cwl-ica-catalogue.md"