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
    echo_stderr "Error: Could not find command 'conda'. Please ensure conda is installed before continuing"
    return 1
  fi
}

has_jq() {
  if ! jq --version >/dev/null; then
    echo_stderr "Error: Could not find command 'jq'. Please ensure jq is installed before continuing"
    return 1
  fi
}

has_node(){
  # Check node, then nodejq then docker ps
  if ! ( node --version >/dev/null || nodejs --version >/dev/null || docker version >/dev/null); then
    echo_stderr "Error: Please install one of node, nodejs or docker"
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

get_lib_path(){
  : '
  Returns path to sync libraries to
  '

  local conda_env_prefix="$1"

  if [[ "${OSTYPE}" == "msys" ]]; then
    echo "${conda_env_prefix}/Lib"
  else
    echo "${conda_env_prefix}/lib/python3.8"
  fi
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
  version="$($(get_conda_binary) --version | cut -d' ' -f2)"

  echo "${version}"
}

has_mamba(){
  : '
  Check if mamba exists
  '
  if ! type mamba 1>/dev/null 2>&1; then
    return 1
  fi
  return 0

}

get_conda_binary(){
  : '
  Use mamba if possible
  '
  if has_mamba; then
    echo "mamba"
  else
    echo "conda"
  fi

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
  if [[ "$OSTYPE" == "msys" ]]; then
    cygpath --path "${conda_env_prefix}"
  else
    echo "${conda_env_prefix}"
  fi
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

  "$(get_conda_binary)" env create \
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

  "$(get_conda_binary)" env update \
    --quiet \
    --name="${name}" \
    --file="${env_file}"
}

print_help() {
  echo_stderr "${help_message}"
}

###################
# CHECK INTERPRETER
###################

# Check installation type first
if type ps 2>/dev/null; then
  # Make sure user is running this through bash
  if [[ "${OSTYPE}" != "msys" && "$(basename "$(ps h -p $$ -o args="" | cut -f1 -d' ')")" != "bash" ]]; then
    echo_stderr "Error: Please make sure you are running this installation script through bash"
    exit 1
  fi
fi

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
echo_stderr "Checking conda, jq and node/nodejs/docker are installed"

if ! has_mamba; then
  echo_stderr "'mamba' not found, if you find that the installation of the conda env is slow, please try again by installing mamba through 'conda install -c conda-forge mamba'"
  if ! has_conda; then
    echo_stderr "Error, could not find conda binary."
    echo_stderr "Please install conda and ensure it is in your \"\$PATH\" environment variable before continuing"
    exit 1
  fi
fi

if ! has_jq; then
  echo_stderr "Error, could not find jq binary."
  echo_stderr "Please install jq globally (preferred) via apt/brew or locally via conda before continuing"
  exit 1
fi

if ! has_node; then
  echo_stderr "Could not one of node, nodejs or docker, required for cwltool commands"
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
  "$(get_this_path)/utils/" "$(get_lib_path "${conda_cwl_ica_env_prefix}")/utils/"

rsync --delete --archive \
  "$(get_this_path)/classes/" "$(get_lib_path "${conda_cwl_ica_env_prefix}")/classes/"

rsync --delete --archive \
  "$(get_this_path)/subcommands/" "$(get_lib_path "${conda_cwl_ica_env_prefix}")/subcommands/"

#####################
# REPLACE __VERSION__
#####################
: '
Only needed in the event that one is installing from source
'

sed "s/__VERSION__/latest/" \
  "$(get_lib_path "${conda_cwl_ica_env_prefix}")/utils/__version__.py" > \
  "$(get_lib_path "${conda_cwl_ica_env_prefix}")/utils/__version__.py.tmp"

mv "$(get_lib_path "${conda_cwl_ica_env_prefix}")/utils/__version__.py.tmp" \
  "$(get_lib_path "${conda_cwl_ica_env_prefix}")/utils/__version__.py"

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
  echo_stderr "To enable autocompletions for this script add the following lines to your '~/.zlogin'"
  echo_stderr "######CWL-ICA######"
  echo_stderr "fpath=(\"${conda_cwl_ica_env_prefix}/etc/autocompletions/${user_shell}/\" \$fpath)"
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    # Mac Users need to run 'autoload' before running compinit
    echo_stderr "autoload -Uz compinit"
  fi
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