#!/usr/bin/env python3

"""
Initialise a project into project.yaml

There're are two required parameters, project-id and project-name.
You can also specify an access-token too that will be used for this project.
You may also specify a tenant name, if no tenant name is selected, it is expected that at one and only one tenant id / name combination
exists under tenant.yaml
"""

from classes.command import Command
from utils.logging import get_logger
from ruamel.yaml.comments import CommentedMap as OrderedDict
from pathlib import Path
from utils.ica_utils import get_jwt_token_obj, \
    get_base_url, get_region_from_base_url, \
    create_personal_access_token, create_token_from_api_key_with_role, \
    get_projects_list_with_token, get_api_key, store_token
from utils.conda import get_conda_tokens_dir
from utils.repo import get_tenant_yaml_path, read_yaml, get_cwl_ica_repo_path, get_project_yaml_path
from utils.conda import get_conda_activate_dir
from utils.yaml import dump_yaml, to_multiline_string
import os
from utils.errors import CheckArgumentError, TenantNotFoundError, InvalidTokenError
from classes.project import Project

logger = get_logger()


class ProjectInit(Command):
    """Usage:
    cwl-ica [options] project-init help
    cwl-ica [options] project-init (--project-id=<"the_project_id">)
                                   (--project-name=<"the_project_name">)
                                   (--project-description=<"describe_the_project>")
                                   (--project-abbr="<project_abbreviation>")
                                   (--project-api-key-name="<project_api_key_name>")
                                   [--tenant-name="<name_of_tenant>"]
                                   [--linked-projects="<list-of-linked-projects>"]
                                   [--set-as-default]


Description:
    Add in a project to 'project.yaml' in the configuration folder.
    The project name does not necessarily need to match the name of the project in ica, although that may be
    convenient. One must specify an api-key by specifying the --project-api-key-name variable s.t when CWL_ICA_API_KEY_SH is run
    with the value of --project-api-key-name set as the env var PROJECT_API_KEY_PATH, will return an api-key for this project.
    Your api-key is not saved in a file, it is just used to generate a project-level access token.
    --project-abbr is used for when multiple projects are under the one tenant. One cannot use the same workflow name across
    multiple projects in the one tenant.

Options:
    --project-id=<the project id>                 Required, the project's ICA id
    --project-name=<the project name>             Required, the project's name
    --project-api-key-name<an api-key name>       Required, this is NOT an api-key, but merely an api-key with a workgroup context that can create an access-token for this project
    --project-description=<project description>   Required, a short summary of the project
    --project-abbr<project abbreviation>          Required, a quick abbreviation of the project name - used to append to workflow names
    --production                                  Optional, boolean, if set, the project is a production project
    --linked-projects=<list-of-linked-projects>   Optional, for every ICA workflow id and workflow version, the acl attributes will also allow access to these projects.
    --tenant-name=<project tenant name>           Optional, the tenant name
    --set-as-default                              Optional, set as the default project

Environment Variables:
    CWL_ICA_DEFAULT_TENANT    Can be used as an alternative for --tenant-name.
    CWL_ICA_API_KEY_SH        A path to a script that has a placeholder PROJECT_API_KEY_PATH for any project name such that when
                              PROJECT_API_KEY_PATH is set to --project-name the script returns an api-key for that project.
                              Such an example may be a script that runs "pass /ica/api-keys/PROJECT_API_KEY_PATH" or
                              a script that runs "aws ssm get-parameter --name PROJECT_API_KEY_PATH --with-decryption | jq '.Parameter.Value'

Example:
    cwl-ica project-init --project-id "d2zf..." --project-name "development" --project-api-key-name "ica-api-key-development" --project-abbr "dev"
    cwl-ica project-init --project-id "d2zf..." --project-name "development" --project-api-key-name "ica-api-key-development" --project-abbr "dev" --project-description "UMMCR development project"
    cwl-ica project-init --project-id "d2zf..." --project-name "development" --project-api-key-name "ica-api-key-development" --project-abbr "dev" --project-description "UMMCR development project"
    cwl-ica project-init --project-id "d2zf..." --project-name "development" --project-api-key-name "ica-api-key-development" --project-abbr "dev" --project-description "UMMCR development project" --set-as-default
    cwl-ica project-init --project-id "adfx..." --project-name "development-umccr-dev" --project-api-key-name "ica-api-key-development" --project-abbr "dev" --project-description "UMMCR development project" --tenant-name "umccr-dev"
    cwl-ica project-init --project-id "adfx..." --project-name "development-umccr-dev" --project-api-key-name "ica-api-key-development" --project-abbr "dev" --project-description "UMMCR development project" --tenant-name "umccr-dev"
    cwl-ica project-init --project-id "adfx..." --project-name "development-workflows-umccr-dev" --project-api-key-name "ica-api-key-development" --project-abbr "dev-wf" --project-description "UMMCR development project" --linked-projects "development" --tenant-name "umccr-dev"
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise values
        self.project_id = None
        self.project_name = None
        self.project_abbr = None
        self.project_access_token = None
        self.project_api_key_name = None
        self.project_description = None
        self.linked_projects = []
        self.tenant_id = None
        self.production = False
        self.set_as_default = False

        # Check args
        self.check_args()

    def __call__(self):
        # if project_token property exists ->
        # create "${CONDA_PREFIX}/ica/tokens/" with 700 permissions
        # write to "${CONDA_PREFIX}/ica/tokens/<project-name>.txt with 600 permissions"
        # then we add project under ${CWL_ICA_REPO_PATH}/config/project.yaml
        if self.project_access_token is not None:
            logger.info(f"Storing access token for this project in \"{get_conda_tokens_dir()}\"")
            store_token(self.project_access_token, self.project_name)

        # Now add project to project yaml
        logger.info(f"Adding project to \"{get_project_yaml_path()}\"")
        self.add_project_to_project_yaml()

        if self.set_as_default:
            logger.info("Setting project as default project")
            activate_dir = get_conda_activate_dir()

            project_activate_path = Path(activate_dir) / "default_project.sh"

            with open(project_activate_path, 'w') as user_h:
                user_h.write(f"export CWL_ICA_DEFAULT_PROJECT=\"{self.project_name}\"\n")
            logger.info("You will need to reactivate your conda environment for this to take effect")

    def check_args(self):
        """
        Perform the following checks:
        * --project-id exists
        * --project-name exists
        * check CWL_ICA_REPO_PATH env var exists
        * check config folder exists inside CWL_ICA_REPO_PATH
        * Read up tenant.yaml make sure there's a tenant id in there
        * check if --tenant-id exists, make sure it's present in tenant.yaml
        * if --access-token exists
            * check that the token matches the project id
            * check the token expiry
        * if --api-key exists then:
            * generate a personal access token
            * then list project ids using the personal access token
            * make sure --project-id is in the list of projects
            * generate a new project token with the api-key
        * cross check access-token against tenant id
        :return:
        """

        # Check expected variables exist
        if self.args.get("--project-id", None) is None:
            logger.error("--project-id must be defined for cwl-ica project-init command")
            raise CheckArgumentError
        self.project_id = self.args.get("--project-id")

        if self.args.get("--project-name", None) is None:
            logger.error("--project-name must be defined for cwl-ica project-init command")
            raise CheckArgumentError
        self.project_name = self.args.get("--project-name")

        if self.args.get("--project-abbr", None) is None:
            logger.error("--project-abbr must be defined for cwl-ica project-init command")
            raise CheckArgumentError
        self.project_abbr = self.args.get("--project-abbr")

        if self.args.get("--project-api-key-name", None) is None:
            logger.error("--project-api-key-name must be defined for cwl-ica project-init command")
            raise CheckArgumentError
        self.project_api_key_name = self.args.get("--project-api-key-name")

        if self.args.get("--project-description", None) is None:
            logger.error("--project-description must be defined for cwl-ica project-init command")
            raise CheckArgumentError
        self.project_description = self.args.get("--project-description")

        # Check if set_as_default parameter is set
        if self.args.get("--set-as-default", False):
            self.set_as_default = True

        # Check production boolean
        if self.args.get("--production", False):
            self.production = True

        # Check linked projects
        if self.args.get("--linked-projects", None) is not None:
            self.linked_projects = self.args.get("--linked-projects").split(",")

        # Check linked projects are in the current tenancy
        # TODO

        # Check repo path
        repo_path = get_cwl_ica_repo_path()

        # Check tenant id
        tenant_name = self.args.get("--tenant-name", None)
        tenant_config_path = get_tenant_yaml_path()
        tenant_config_list = read_yaml(tenant_config_path)["tenants"]

        # Check tenant length is more than one
        if len(tenant_config_list) < 1:
            logger.error(f"Could not find any tenants in {tenant_config_list}. Please run cwl-ica configure-tenant")
            raise TenantNotFoundError
        elif tenant_name is not None:
            for tenant in tenant_config_list:
                if tenant.get("tenant_name", None) == tenant_name:
                    self.tenant_id = tenant.get("tenant_id", None)
                break
            else:
                logger.error(f"Could not match tenant name \"{tenant_name}\" with a tenant id in \"{tenant_config_path}\"")
                raise TenantNotFoundError
        elif len(tenant_config_list) == 1:
            self.tenant_id = tenant_config_list[0].get("tenant_id", None)
            if self.tenant_id is None:
                logger.error(f"Could not get tenant_id attribute from single entry in \"{tenant_config_path}\"")
                raise TenantNotFoundError
        elif os.environ.get("CWL_ICA_DEFAULT_TENANT", None) is not None:
            tenant_name = os.environ.get("CWL_ICA_DEFAULT_TENANT")
            for tenant in tenant_config_list:
                if tenant.get("tenant_name", None) == tenant_name:
                    self.tenant_id = tenant.get("tenant_id", None)
                break
            else:
                logger.error("Could not get tenant_id attribute from tenant name "
                             "but \"CWL_ICA_DEFAULT_TENANT\" environment variable is set")
        else:
            logger.error(f"Please specify --tenant-name parameter, multiple tenants are present in \"{tenant_config_path}\"")
            raise TenantNotFoundError

        # Before we get project token, we need to make sure that ICA_BASE_URL env var exists
        base_url = get_base_url()
        region = get_region_from_base_url(base_url)
        audience = f"iap-{region}"

        # Create PAT token from api-key
        # Create personal access token
        api_key = get_api_key(self.project_api_key_name)

        personal_access_token = create_personal_access_token(base_url, api_key)

        # List projects with personal access token
        personal_projects_list = [project.id
                                  for project in get_projects_list_with_token(base_url, personal_access_token)]

        # Like --access-token input logic, compare
        if self.project_id not in personal_projects_list:
            logger.error("Listed "
                         "but needed \"{project_id}\" in membership".format(
                             token_projects=", ".join(["'%s'" % project for project in personal_projects_list]),
                             project_id=self.project_id)
                         )
            raise CheckArgumentError

        # We don't need PAT anymore, secrets shouldn't be kept around longer than they
        # need to be
        del personal_access_token

        # We can now run get a project access token from the api key
        self.project_access_token = create_token_from_api_key_with_role(base_url, api_key, project_id=self.project_id, role="admin")

        # We don't need the api-key var anymore either
        del api_key

        # One final check to make sure that this project token is in the correct tenant id
        token_obj = get_jwt_token_obj(self.project_access_token, audience)
        token_tenant_id = token_obj.get("tid", None)
        if token_tenant_id is None:
            raise InvalidTokenError
        if not token_tenant_id == self.tenant_id:
            logger.error("The tenant id in the project access token does NOT match that of the tenant id. "
                         "Got \"{project_tenant_id}\" against \"{token_tenant_id}\"".format(
                            project_tenant_id=self.tenant_id,
                            token_tenant_id=token_tenant_id
                         ))
            raise InvalidTokenError

    def add_project_to_project_yaml(self):
        """
        Add our project with the project attributes to the project yaml

        :return:
        """

        # Get the path to repo-path/config/project.yaml
        project_yaml_path = get_project_yaml_path(non_existent_ok=True)

        # Read in project yaml if it exists or create a new one
        if not project_yaml_path.is_file():
            # Initialise project yaml dictionary
            project_list = []
        else:
            # Read in project yaml dictionary
            project_list = read_yaml(project_yaml_path).get("projects", [])

        # Check another project doesn't exist with the same name or id
        for project in project_list:
            if project.get("project_id", None) == self.project_id:
                logger.error("Cannot initialise this project, it has the same id as {project_name}".format(
                    project_name=project.get("project_name", None)
                ))
            if project.get("project_name", None) == self.project_name:
                logger.error("Cannot initialise this project, it has the same name as {project_id}".format(
                    project_id=project.get("project_id", None)
                ))

        # Append project
        project_list.append(Project.from_dict(OrderedDict({
            "project_name": self.project_name,
            "project_id": self.project_id,
            "project_description": to_multiline_string(self.project_description),
            "project_abbr": self.project_abbr,
            "project_api_key_name": self.project_api_key_name,
            "linked_projects": self.linked_projects,
            "tenant_id": self.tenant_id,
            "production": self.production,
            "tools": [],  # List of tools available for this project
            "workflows": []  # List of workflows available for this project
        })).to_dict())

        project_dict = {
            "projects": project_list
        }

        # Write out project
        with open(project_yaml_path, 'w') as project_yaml_h:
            dump_yaml(project_dict, project_yaml_h)
