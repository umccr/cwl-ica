#!/usr/bin/env python3


"""
Few quick shortcuts for ica
"""

from urllib.parse import urlparse
import re
from jwt import decode, InvalidTokenError
from datetime import datetime
import libica.openapi.libconsole
import os
from utils.logging import get_logger
from utils.globals import SCOPES_BY_ROLE, ICA_BASE_URL_ENV_VAR, BASE_URL_NETLOC_REGEX, EXPIRY_DAYS_WARNING_TRIGGER
from utils.subprocess_handler import run_subprocess_proc
from utils.conda import create_tokens_dir, get_conda_tokens_dir
from utils.errors import BaseUrlEnvNotFoundError, InvalidBaseUrlError, \
    TokenMembershipsError, TokenScopeError, TokenCreationError, CheckArgumentError
from pathlib import Path
import time

logger = get_logger()


def get_base_url():
    """
    Get the baseurl from the environment variable ICA_BASE_URL
    :return:
    """

    # Get ICA_BASE_URL_ENV var
    ica_base_url = os.environ.get(ICA_BASE_URL_ENV_VAR, None)
    if ica_base_url is None:
        logger.error("Could not get the environment variable ICA_BASE_URL, "
                     "have you run cwl-ica configure-repo and activated the cwl-ica conda environment?")
        raise BaseUrlEnvNotFoundError

    validate_base_url(ica_base_url)

    return ica_base_url


def validate_base_url(base_url):
    """
    Simple checks
    Make sure scheme matches 'https'
    Make sure netloc matches regex
    :return:
    """

    base_url_parse = urlparse(base_url)

    if not base_url_parse.scheme == "https":
        logger.error(f"Base url \"{base_url}\" does not start with \"https\"")
        raise InvalidBaseUrlError

    if not re.match(BASE_URL_NETLOC_REGEX, base_url_parse.netloc):
        logger.error(f"Base url netloc: \"{base_url_parse.netloc}\" does not match regex \"{BASE_URL_NETLOC_REGEX}\"")


def get_region_from_base_url(base_url):
    """
    If base_url is https://aps2.platform.illumina.com
    :param base_url:
    :return:
    """

    base_url_obj = urlparse(base_url)

    base_url_re_obj = re.match(BASE_URL_NETLOC_REGEX, base_url_obj.netloc)

    if base_url_re_obj is None:
        raise InvalidBaseUrlError

    # Return 'aps2'
    return base_url_re_obj.group(1)


def get_jwt_token_obj(jwt_token, audience):
    """
    Get the jwt token object through the pyjwt package
    :param jwt_token:
    :param audience:
    :return:
    """
    try:
        token_object = decode(jwt_token,
                              options={
                                         "verify_signature": False,
                                         "require_exp": True
                                       },
                              audience=[audience],
                              algorithms="RS256",
                              )
    except InvalidTokenError:
        raise InvalidTokenError

    return token_object


def get_token_expiry(jwt_token_obj):
    """
    Get the token expiry from a jwt token object
    Takes the 'exp' key and then converts to datetime format.
    :param jwt_token_obj:
    :return:
    """

    # Get expiry key
    expiry = jwt_token_obj.get("exp", None)

    # Check expiry key exists
    if expiry is None:
        raise InvalidTokenError

    # Convery expiry epoch to datetime object
    expiry_date = datetime.fromtimestamp(expiry)

    return expiry_date


def check_token_expiry(expiry_date, warn_on_near_expiry=True):
    """
    Check a tokens' expiry date
    :param expiry_date:
    :return:
    """
    # Get time diff
    time_to_expiry = expiry_date - datetime.now()

    # Check token hasn't yet expired
    if time_to_expiry.total_seconds() <= 0:
        logger.error(f"This token has expired, please update your token with cwl-ica update-project ")
        raise InvalidTokenError
    # Raise warning if token is expiring soon
    elif warn_on_near_expiry and time_to_expiry.days < EXPIRY_DAYS_WARNING_TRIGGER:
        logger.warning(f"This token will expire in {time_to_expiry.days}")


def get_token_memberships(jwt_token_obj):
    """
    Get token memberships - gets the token membership keys
    :param jwt_token_obj:
    :return:
    """

    # Get the memberships dictionary
    memberships_dict = jwt_token_obj.get("mem", None)

    # Make sure memberships are present
    if memberships_dict is None or len(memberships_dict.keys()) == 0:
        logger.error("Could not get memberships from the jwt token object")
        raise TokenMembershipsError

    # Collect only 'project' memberships
    memberships_list = list(memberships_dict.keys())

    project_memberships_list = [membership.split(":", 1)[-1]
                                for membership in memberships_list
                                if membership.split(":", 1)[0] == "cid"]

    if len(project_memberships_list) == 0:
        logger.error("Could not find any projects as memberships for this token")
        raise TokenMembershipsError

    return project_memberships_list


def get_token_scopes(jwt_token_obj):
    """
    Return the list of token scopes in 'list' format
    :param jwt_token_obj:
    :return:
    """

    scopes_str = jwt_token_obj.get("scope", None)

    # Check scope attribute is not none
    if scopes_str is None:
        logger.error("Could not get scopes attribute from token object")
        raise TokenScopeError

    scopes_list = scopes_str.split(",")

    # Check we have more than one scopes
    if len(scopes_list) == 0:
        logger.error("No scopes available from token object")
        raise TokenScopeError

    return scopes_list


def get_projects_list_with_personal_access_token(base_url, personal_access_token):
    """
    List project using an api-key for authorization
    :param base_url:
    :param personal_access_token:
    :return:
    """
    # Initialise page count
    counted_pages = 0
    total_page_count = 1
    projects = []
    next_page_token = None

    # Set the configuration
    configuration = libica.openapi.libconsole.Configuration(host=base_url,
                                                            api_key={
                                                                "Authorization": personal_access_token
                                                            },
                                                            api_key_prefix={
                                                                "Authorization": "Bearer"
                                                            })
    # Open up the api client context
    with libica.openapi.libconsole.ApiClient(configuration) as api_client:
        while counted_pages < total_page_count:
            # Create an instance from the client
            api_instance = libica.openapi.libconsole.ProjectsApi(api_client)
            # Create a token with the scopes from
            api_response = api_instance.list_projects()
            # Update counted pages
            counted_pages += 1
            # Get total page count
            total_page_count = api_response.total_page_count
            # Get next token
            next_page_token = api_response.next_page_token
            # Append items to project before retrieving next batch
            projects.extend(api_response.items)

    # Check number of projects is more than one
    if len(projects) < 1:
        logger.error("Could not find any projects using personal access token. "
                     "Make sure --api-key has correct scope")
        raise TokenMembershipsError

    return [project.id for project in projects]


def create_personal_access_token(base_url, api_key):
    """
    Create a personal access token (s.t we can list projects)
    :param base_url:
    :param api_key:
    :return:
    """
    # Set the configuration
    configuration = libica.openapi.libconsole.Configuration(host=base_url,
                                                            api_key={
                                                                "Authorization": api_key
                                                            })

    # Open up the api client context
    with libica.openapi.libconsole.ApiClient(configuration) as api_client:
        # Create an instance from the client
        api_instance = libica.openapi.libconsole.TokensApi(api_client)
        # Create a token with the scopes from
        api_response = api_instance.create_token(x_api_key=api_key)

    # Make sure token is an attribute
    access_token = api_response.to_dict().get("access_token", None)

    # Get access token
    if access_token is None:
        logger.error("Could not create a personal access token")
        raise TokenCreationError

    return access_token


def create_token_from_api_key_with_role(base_url, api_key, project_id, role):
    """
    We create an api key with a given role based on globals.SCOPES_BY_ROLE
    role can either be 'read-only' (a viewer) or 'admin' (either contributor or admin)
    A project id is required.
    :param base_url:
    :param api_key:
    :param project_id:
    :param role:
    :return:
    """
    # Check roles
    if role not in list(SCOPES_BY_ROLE.keys()):
        logger.error("Cannot select scopes for {role}. Must be one of {roles}".format(
            role=role,
            roles=", ".join(["'%s'" % role for role in list(SCOPES_BY_ROLE.keys())])
        ))

    # Set the configuration
    configuration = libica.openapi.libconsole.Configuration(host=base_url,
                                                            api_key={
                                                                "Authorization": api_key
                                                            })

    # Open up the api client context
    with libica.openapi.libconsole.ApiClient(configuration) as api_client:
        # Create an instance from the client
        api_instance = libica.openapi.libconsole.TokensApi(api_client)
        # Create a token with the scopes from
        api_response = api_instance.create_token(x_api_key=api_key, cid=project_id, scopes=SCOPES_BY_ROLE[role])

    # Make sure token is an attribute
    access_token = api_response.to_dict().get("access_token", None)

    # Get access token
    if access_token is None:
        logger.error("Could not create access token")
        raise TokenCreationError

    # Wait two seconds before we validate the token
    time.sleep(2)

    return access_token


def check_token_membership(token_obj, project_id):
    projects_in_token = get_token_memberships(token_obj)
    if project_id not in projects_in_token:
        logger.error("--access-token specified but got \"{token_projects}\" as membership "
                     "but needed \"{project_id}\" in membership".format(
                        token_projects=", ".join(["'%s'" % project for project in projects_in_token]),
                        project_id=project_id))
        raise CheckArgumentError


def store_token(access_token, project_name):
    """
    Store the access token in a safe location
    :param access_token:
    :param project_id:
    :param path:
    :return:
    """
    # Get tokens directory
    tokens_dir = get_conda_tokens_dir()
    if not tokens_dir.is_dir():
        create_tokens_dir(tokens_dir)
    project_secret_path = tokens_dir / Path(project_name + ".txt")
    # Create file with owner-only permissions
    project_secret_path.touch(mode=0o600)
    # Write secret access token to file
    with open(project_secret_path, 'w') as secret_h:
        secret_h.write(access_token + "\n")


def get_api_key(project_name, sh_env_var="CWL_ICA_API_KEY_SH", key_path_env_var="PROJECT_API_KEY_PATH"):
    """
    Create a file using the contents of sh_env_var, run said file with key_path_env_var set to project_name
    This should then return an api-key.  This is done with a similar idea to GIT_SSH.
    Your sh_env_var variable CWL_ICA_API_KEY_SH might point to a path with the following contents
    "
    #!/usr/bin/env bash

    pass "/ica/api-keys/${PROJECT_API_KEY_PATH}"
    "
    where key_path_env_var is "PROJECT_API_KEY_PATH" -> static for each project
    and project_key_value is "development"

    We use environment variables here to keep things open to the user's personal choice on storing secrets such as api keys.

    One may wish to store such a value in a file with user-only permissions in their home directory such as:

    "
    #!/usr/bin/env bash

    cat "$HOME/.ica/api-keys/${PROJECT_API_KEY_PATH}.txt" | tr -d '\n'
    "

    where "$HOME/.ica" has 700 permissions and "$HOME/.ica/${PROJECT_API_KEY_PATH}.txt" has 600 permissions.


    Another example may be using aws ssm
    "
    #!/usr/bin/env bash

    aws ssm get-parameter --name "/ica/api-keys/${PROJECT_API_KEY_PATH}" --with-decryption | jq '.Parameter.Value'
    "

    There may be some limitations with the aws option here. Api-keys are generally set per-user, this would only be appropriate with
    a service account where all ssm keys for all projects are stored in the one aws account, OR roles are assigned such that
    certain roles for certain projects can see some ssm parameters but not others, this may cause an extra level of complexity.

    With GitHub actions using secrets, we do not have the pass binary, and simply use "echo API_KEY_${PROJECT_API_KEY_PATH}"

    :param sh_env_var:
    :param key_path_env_var:
    :param project_name:
    :return:
    """

    if os.environ.get(sh_env_var, None) is None:
        logger.warning(f"Could not get the environment variable \"{sh_env_var}\". "
                       f"Please refer to the docs on creating an env var for \"{sh_env_var}\"")
        return None
    else:
        sh_env_path = Path(os.environ.get(sh_env_var))

    if not sh_env_path.is_file():
        logger.warning(f"Could not find file \"{sh_env_path}\"")
        return None

    if not os.access(sh_env_path, os.X_OK):
        logger.warning(f"Found path \"{sh_env_path}\" however it is not executable")
        return None

    # Run the file with the environment variables set
    env_dict = os.environ.copy()
    # Add key path env var to env dict
    env_dict[key_path_env_var] = project_name
    api_returncode, api_stdout, api_stderr = run_subprocess_proc([sh_env_path],
                                                                 capture_output=True,
                                                                 env=env_dict)
    return api_stdout.strip()
