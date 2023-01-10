#!/usr/bin/env bash

# Create the workflow release asset

# Set Globals
export CWL_ICA_REPO_PATH="$PWD"

# Add Globals for Github actions bot
GITHUB_ACTIONS_USERNAME="github-actions[bot]"
GITHUB_ACTIONS_EMAIL="41898282+github-actions[bot]@users.noreply.github.com"

help_message="Usage: create_workflow_release_asset.sh
Wrapper script around cwl-ica github-actions-build-workflow-release-asset subcommand
Optional parameters:
         --is-pre-release: Add parameter --is-pre-release to subcommand
         --workflow-path: Add workflow path parameter to subcommand
"


# FUNCTIONS
echo_stderr(){
  : '
  Write out to stderr
  '
  echo "${@}" 1>&2
}

print_help() {
  echo_stderr "${help_message}"
}

# Check for the following env vars exist

# Check env vars
if [[ ! -v GITHUB_SERVER_URL ]]; then
  echo "Error - expected env var GITHUB_SERVER_URL" 1>&2
  exit 1
fi

if [[ ! -v GITHUB_REPOSITORY ]]; then
  echo "Error - expected env var GITHUB_REPOSITORY" 1>&2
  exit 1
fi

if [[ ! -v GITHUB_TOKEN ]]; then
  echo "Error - expected env var GITHUB_TOKEN" 1>&2
  exit 1
fi

if [[ ! -v GITHUB_TAG ]]; then
  echo "Error - expected env var GITHUB_TAG" 1>&2
  exit 1
fi

# Set conda envs
CONDA_ENVS_PATH="$(mktemp -d)"
export CONDA_ENVS_PATH

# Softlink envs into this environment
ENVS_LIST=( "cwl-ica" "cwltool-icav1" )
for env_name in "${ENVS_LIST[@]}"; do
  ln -s \
    "/home/cwl_ica_user/.conda/envs/${env_name}" \
    "${CONDA_ENVS_PATH}/${env_name}"
done


# Get args

# is pre-release

# Check workflow path

# Set github name and email as github actions bot
# See this https://github.com/orgs/community/discussions/26560 for more info


# Run create release asset command
is_prerelease="false"
workflow_path=""

while [ $# -gt 0 ]; do
  case "$1" in
    --is-prerelease)
      is_prerelease="$2"
      shift 1
      ;;
    --workflow-path)
      workflow_path="$2"
      shift 1
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      print_help
      exit 1
      ;;
  esac
  shift 1
done

# Check workflow path is readable
if [[ ! -r "${workflow_path}" ]]; then
  echo_stderr "Could not read file ${workflow_path}"
fi

# Create parameter list
arg_array=( "--workflow-path" "${workflow_path}" )

# Extend parameter list with '--draft-release' if this IS a pre-release
if [[ "${is_prerelease}" == "true" ]]; then
  arg_array+=( "--draft-release" )
fi

# Add git configuration
git config user.name "${GITHUB_ACTIONS_USERNAME}"
git config user.email "${GITHUB_ACTIONS_EMAIL}"

# Launch cwl-ica github-actions-build-workflow-release-asset
eval cwl-ica github-actions-build-workflow-release-asset '"${arg_array[@]}"'
