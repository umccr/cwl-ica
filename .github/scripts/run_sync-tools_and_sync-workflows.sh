#!/usr/bin/env bash

# Set for failure
set -euo pipefail

# Set Globals
CONDA_ENV_NAME="cwl-ica"
CWL_ICA_REPO_PATH="$PWD"

# Exports
export CWL_ICA_REPO_PATH

# Check env vars
if [[ ! -v GIT_COMMIT_ID ]]; then
  echo "Error - expected env var GIT_COMMIT_ID" 1>&2
  exit 1
fi

if [[ ! -v SECRETS_JSON ]]; then
  echo "Error - expected env var SECRETS_JSON" 1>&2
  exit 1
fi

# Run export over jq secrets -
# Secrets are in nested form:
# '{"PROJECT_X": {"ICA_ACCESS_TOKEN": "foo"}, "PROJECT_Y": {"ICA_ACCESS_TOKEN": "bar"}}'
echo "Collecting access tokens" 1>&2

# Reset secrets json
SECRETS_JSON="$(echo "${SECRETS_JSON}" | sed 's/#/{/g' | sed 's/%/}/g')"

for project in $(echo "${SECRETS_JSON}" | jq -r 'keys[]'); do
    # Now export each token env var as CWL_ICA_ACCESS_TOKEN_PROJECT_X=<PROJECT_X_ACCESS_TOKEN>
    # Sub out hypens for underscores
    project_underscore="${project//-/_}"
    # Get token from secrets json
    project_token="$(echo "${SECRETS_JSON}" | \
                     jq -r \
                       --arg project "${project}" \
                       '.[$project].ICA_ACCESS_TOKEN' \
                   )"
    # Get env var name
    project_token_env_var_name="CWL_ICA_ACCESS_TOKEN_${project_underscore^^}"
    # Export env var from project token
    export "${project_token_env_var_name}"="${project_token}"
done

# Install cwl-ica through installation script
echo "Installing cwl-ica software into conda env" 1>&2
bash src/install.sh --yes

# Now run the github-tool-sync-command
echo "Syncing all tools" 1>&2
conda run \
  --name "${CONDA_ENV_NAME}" \
  cwl-ica github-actions-sync-tools \

# Now run the github-workflow-sync-command
echo "Syncing all workflows" 1>&2
conda run \
  --name "${CONDA_ENV_NAME}" \
  cwl-ica github-actions-sync-workflows


