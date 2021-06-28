#!/usr/bin/env bash

: '
Simple script that:
1. creates/updates conda env from yaml
2. Adds library files to site-packages 
3. Adds scripts to bin subdir in CONDA_PREFIX
'

# Ensure installation fails on non-zero exit code
set -euo pipefail

###########
# GLOBALS
###########
CWL_ICA_CONDA_ENV_NAME="cwl-ica"
REQUIRED_CONDA_VERSION="4.9.0"

##########
# GET HELP
##########
help_message="Usage: install.sh
Installs cwl-ica software and scripts into the conda env '${CWL_ICA_CONDA_ENV_NAME}'.
You must have conda (${REQUIRED_CONDA_VERSION}) and jq installed.
MacOS users, please install greadlink through 'brew install coreutils'
Optional parameters:
         -y/--yes: Create/Update conda env without asking
"

###########
# CHECKS
###########

echo_stderr() {
  echo "$@" 1>&2
}

has_conda() {
  if ! conda --version >/dev/null; then
    echo_stderr "Could find command 'conda'. Please ensure conda is installed before continuing"
    return 1
  fi
}

has_jq() {
  if ! jq --version >/dev/null; then
    echo_stderr "Could not find command 'jq'. Please ensure jq is installed before continuing"
    return 1
  fi
}

check_readlink_program() {
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    readlink_program="greadlink"
  else
    readlink_program="readlink"
  fi

  if ! type "${readlink_program}"; then
      if [[ "${readlink_program}" == "greadlink" ]]; then
        echo_stderr "On a mac but 'greadlink' not found"
        echo_stderr "Please run 'brew install coreutils' and then re-run this script"
        return 1
      else
        echo_stderr "readlink not installed. Please install before continuing"
      fi
  fi
}

check_rsync() {
  if ! type "rsync"; then
    echo_stderr "Could not find executable \"rsync\""
    return 1
  fi
}

get_this_path() {
  : '
  Mac users use greadlink over readlink
  Return the directory of where this install.sh file is located
  '
  local this_dir

  # darwin is for mac, else linux
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    readlink_program="greadlink"
  else
    readlink_program="readlink"
  fi

  # Get directory name of the install.sh file
  this_dir="$(dirname "$("${readlink_program}" -f "${0}")")"

  # Return directory name
  echo "${this_dir}"
}

_verlte() {
  [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

_verlt() {
  [ "$1" = "$2" ] && return 1 || verlte "$1" "$2"
}

############
# CONDA
############

get_conda_version() {
  local version
  version="$(conda --version | cut -d' ' -f2)"

  echo "${version}"
}

has_conda_env() {
  : '
  Check if a conda environment exists
  '
  local conda_envs
  local conda_env_path

  conda_envs="$(conda env list \
                  --json \
                  --quiet | {
                jq --raw-output '.envs[]'
               })"

  for conda_env_path in ${conda_envs}; do
    if [[ "$(basename "${conda_env_path}")" == "${CWL_ICA_CONDA_ENV_NAME}" ]]; then
      # Conda env has been found
      return 0
    fi
  done
  # Conda env was not found
  return 1
}

get_conda_env_prefix() {
  : '
  Get the prefix of a conda environment
  '

  local conda_env_prefix

  conda_env_prefix="$(conda env export \
                        --name "${CWL_ICA_CONDA_ENV_NAME}" \
                        --json | {
                      jq '.prefix' \
                        --raw-output
                    })"

  # Should return something like '/home/alexiswl/anaconda3/envs/cwl-ica'
  echo "${conda_env_prefix}"
}

check_conda_version() {
  : '
  Make sure at the latest conda version
  '
  if ! _verlte "${REQUIRED_CONDA_VERSION}" "$(get_conda_version)"; then
    echo_stderr "Your conda version is too old"
    return 1
  fi
}

run_conda_create() {
  : '
  Run the conda create command
  '

  local name="$1"
  local env_file="$2"

  conda env create \
    --quiet \
    --name="${name}" \
    --file="${env_file}"
}

run_conda_update() {
  : '
  Run the conda update command
  '

  local name="$1"
  local env_file="$2"

  conda env update \
    --quiet \
    --name="${name}" \
    --file="${env_file}"
}

print_help() {
  echo_stderr "${help_message}"
}

###############
# GET ARGUMENTS
###############

# Otherwise fails for unbound variable "$1"
set +u

yes="false"
while true; do
  case "$1" in
    -y|--yes)
      yes="true"
      shift 1
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

# Reset this
set -u

############
# RUN CHECKS
############

# Installations
echo_stderr "Checking conda and jq are installed"

if ! has_conda; then
  echo_stderr "Error, could not find conda binary."
  echo_stderr "Please install conda and ensure it is in your \"\$PATH\" environment variable before continuing"
  exit 1
fi

if ! has_jq; then
  echo_stderr "Error, could not find jq binary."
  echo_stderr "Please install jq globally (preferred) via apt/brew or locally via conda before continuing"
  exit 1
fi

if ! check_conda_version; then
  echo_stderr "Your conda version is out of date, please run \"conda update -n base -c defaults conda\" before continuing"
  exit 1
fi

if ! check_readlink_program; then
  echo_stderr "Failed at readlink check stage"
  exit 1
fi

if ! check_rsync; then
  echo_stderr "Failed at rsync check stage"
  exit 1
fi


#########################
# CREATE/UPDATE CONDA ENV
#########################

conda_env_file="$(get_this_path)/cwl-ica-conda-env.yaml"

if ! has_conda_env; then
  if [[ "${yes}" == "true" ]]; then
    echo_stderr "Creating cwl-ica conda env"
    run_conda_create "${CWL_ICA_CONDA_ENV_NAME}" "${conda_env_file}"
  else
    echo_stderr "cwl-ica conda env does not exist - would you like to create one?"
    select yn in "Yes" "No"; do
      case "$yn" in
          "Yes" )
            run_conda_create "${CWL_ICA_CONDA_ENV_NAME}" "${conda_env_file}"
            break;;
          "No" )
            echo_stderr "Installation cancelled"
            exit 0;;
      esac
    done
  fi
else
  if [[ "${yes}" == "true" ]]; then
    echo_stderr "Updating cwl-ica conda env"
    run_conda_update "${CWL_ICA_CONDA_ENV_NAME}" "${conda_env_file}"
  else
    echo_stderr "Found conda env 'cwl-ica' - would you like to run an update?"
    select yn in "Yes" "No"; do
      case "$yn" in
          "Yes" )
            run_conda_update "${CWL_ICA_CONDA_ENV_NAME}" "${conda_env_file}"
            break;;
          "No" )
            echo_stderr "Installation cancelled"
            exit 0;;
      esac
    done
  fi
fi

# Now we can obtain the env prefix which is where we will place our
conda_cwl_ica_env_prefix="$(get_conda_env_prefix)"

###########
# COPY BINS
###########

# Copy over to conda env
echo_stderr "Adding main script to \"${conda_cwl_ica_env_prefix}/bin\""
cp "$(get_this_path)/cwl-ica.py" "${conda_cwl_ica_env_prefix}/bin/cwl-ica"

# Ensure all the scripts are executable
chmod +x "${conda_cwl_ica_env_prefix}/bin/cwl-ica"

###########
# COPY LIBS
###########
: '
Copy over utils/classes/subcommands to library path
'

rsync --delete --archive \
  "$(get_this_path)/utils/" "${conda_cwl_ica_env_prefix}/lib/python3.8/utils/"

rsync --delete --archive \
  "$(get_this_path)/classes/" "${conda_cwl_ica_env_prefix}/lib/python3.8/classes/"

rsync --delete --archive \
  "$(get_this_path)/subcommands/" "${conda_cwl_ica_env_prefix}/lib/python3.8/subcommands/"

#####################
# REPLACE __VERSION__
#####################
: '
Only needed in the event that one is installing from source
'

sed "s/__VERSION__/latest/" \
  "${conda_cwl_ica_env_prefix}/lib/python3.8/utils/__version__.py" > \
  "${conda_cwl_ica_env_prefix}/lib/python3.8/utils/__version__.py.tmp"

mv "${conda_cwl_ica_env_prefix}/lib/python3.8/utils/__version__.py.tmp" \
  "${conda_cwl_ica_env_prefix}/lib/python3.8/utils/__version__.py"

##################################
# Add autocompletion to activate.d
##################################

echo_stderr "Copying auto-autocompletion files to conda prefix directory"

# Create activate.d if doesn't already exist
mkdir -p "${conda_cwl_ica_env_prefix}/etc/autocompletions"

# Quick "one liner" to get 'bash' or 'zsh'
if [[ "${OSTYPE}" == "darwin"* ]]; then
  user_shell="$(basename "$(finger "${USER}" | grep 'Shell:*' | cut -f3 -d ":")")"
else
  user_shell="$(basename "$(awk -F: -v user="$USER" '$1 == user {print $NF}' /etc/passwd)")"
fi

# Bash
if [[ "${user_shell}" == "bash" ]]; then
  rsync --archive "$(get_this_path)/autocompletion/${user_shell}/" \
    "${conda_cwl_ica_env_prefix}/etc/autocompletions/${user_shell}/"
  echo_stderr "To enable autocompletions for this script add the following line to your '~/.bash_profile'"
  echo_stderr "######CWL-ICA######"
  echo_stderr "source \"${conda_cwl_ica_env_prefix}/etc/autocompletions/${user_shell}/\"*\".bash\""
  echo_stderr "###################"

# ZSH


elif [[ "${user_shell}" == "zsh" ]]; then
  rsync --archive "$(get_this_path)/autocompletion/${user_shell}/" \
    "${conda_cwl_ica_env_prefix}/etc/autocompletions/${user_shell}/"
  echo_stderr "To enable autocompletions for this script add the following lines to your '~/.zshrc'"
  echo_stderr "######CWL-ICA######"
  echo_stderr "fpath=(\"${conda_cwl_ica_env_prefix}/etc/autocompletions/${user_shell}/\" \$fpath)"
  echo_stderr "compinit"
  echo_stderr "###################"

# UNKNOWN
else
  echo_stderr "Warning, could not figure out user's default shell"
fi


###############
# END OF SCRIPT
###############
echo_stderr "Installation Complete!"