#!/usr/bin/env python

"""cwl-ica ::: a functions suite for managing collections of cwl workflows on ica throughout multiple tenants and projects

Usage:
    cwl-ica [options] <command> [options] [<args>...]

Options:
    --debug                             Set the log level to debug

Command:

    help                                Print help and exit
    version                             Print version and exit

    ######################
    Configuration Commands
    ######################
    configure-repo                      One-time command to point to the cwl-ica git repository
    configure-tenant                    Create mapping of tenancy ids to tenancy names, convenience to save time typing out tenancy names
                                        Each project is linked to a tenancy id
    configure-user                      Add a user to user.yaml

    ##########################
    ICA Initialisers
    ##########################
    project-init                        Initialise a project in ${CWL_ICA_REPO_PATH}/config/project.yaml
    category-init                       Initialise a category in ${CWL_ICA_REPO_PATH}/config/category.yaml


    ########################
    Set Defaults Commands
    ########################
    set-default-tenant                  Set a tenant to the default tenant
    set-default-project                 Set a project to the default project
    set-default-user                    Set a user to the default user


    #########################
    # List Commands
    #########################
    list-categories                     List registered categories
    list-projects                       List registered projects
    list-tenants                        List registered tenants
    list-users                          List registered users


    #######################
    Creation Commands
    #######################
    create-expression-from-template     Initialise an CWL expression from the cwl expression template
    create-schema-from-template         Initialise a CWL schema from the cwl schema template
    create-tool-from-template           Initialise a CWL tool from the cwl tool template
    create-workflow-from-template       Initialise a CWL workflow from the cwl workflow template


    ###################
    Validation Commands
    ###################
    expression-validate                 Validate a CWL expression
    schema-validate                     Validate a CWL schema
    tool-validate                       Validate a CWL tool ready for initialising on ICA
    workflow-validate                   Validate a CWL workflow ready for initialising on ICA
    validate-config-yamls               Confirms configuration files are legit
    validate-api-key-script             Confirm an api-key-script works for a given project


    ###############
    Init Commands
    ###############
    expression-init                     Register an expression in ${CWL_ICA_REPO_PATH}/config/expression.yaml
    schema-init                         Register a schema in ${CWL_ICA_REPO_PATH}/config/schema.yaml
    tool-init                           Register a tool in ${CWL_ICA_REPO_PATH}/config/tool.yaml and with ICA projects
    workflow-init                       Register a workflow in ${CWL_ICA_REPO_PATH}/config/workflow.yaml and with ICA projects


    ########################
    Sync-to-project Commands
    ########################
    expression-sync                     Sync an expression in ${CWL_ICA_REPO_PATH}/config/expression.yaml
    tool-sync                           Sync a tool's md5sum in ${CWL_ICA_REPO_PATH}/config/tool.yaml
                                        and update definition on ICA
    schema-sync                         Sync a schema in ${CWL_ICA_REPO_PATH}/config/schema.yaml
    workflow-sync                       Sync a workflows's md5sum in ${CWL_ICA_REPO_PATH}/config/workflow.yaml
                                        and update definition on ICA


    #######################
    Add-to-project Commands
    #######################
    add-tool-to-project                 Add an existing tool to another project
    add-workflow-to-project             Add an existing workflow to another project
    add-linked-project                  Link an existing project-id to an initialised project in project.yaml


    ########################
    Add-category Commands
    ########################
    add-category-to-tool                Add an existing category to an existing tool
    add-category-to-workflow            Add an existing category to an existing workflow


    ############################
    Add-maintainer commands
    ############################
    add-maintainer-to-expression        Acknowledge a user as a maintainer of a cwl expression
    add-maintainer-to-tool              Acknowledge a user as a maintainer of a cwl tool
    add-maintainer-to-workflow          Acknowledge a user as a maintainer of a cwl workflow


    #############################
    Run-register Commands  # Not yet implemented v1.0 release
    #############################
    register-tool-run-instance-id       Register an ICA workflow run instance of a tool for a given project
    register-workflow-run-instance-id   Register an ICA workflow run instance of a workflow for a given project


    #######################
    Query workflow Commands  # Not yet implemented v1.0 release
    #######################
    get-workflow-step-ids               Get the step ids of a CWL workflow


    ##################
    Run-list Commands  # Not yet implemented  v1.0 release
    ##################
    list-tool-runs                      List registered tool runs for a CWL tool in a given project
    list-workflow-runs                  List registered workflows runs for a CWL workflow in a given project


    ################################
    Get Run-templates Commands  # Not yet implemented  v1.0 release
    ################################
    copy-tool-submission-template       Copy a tool submission template for an upcoming tool run
    copy-workflow-submission-template   Copy a workflow submission template for an upcoming workflow run


    #################################
    GitHub Actions Scripts
    #################################
    github-actions-sync-tools           Sync all tools to tool.yaml and to all projects with that tool version
    github-actions-sync-workflows       Sync workflows to workflow.yaml and to all projects with that workflow version
    github-actions-build-catalogue      Create the catalogue markdown file    # Not yet implemented v1.0 release
"""

from docopt import docopt
from utils.__version__ import version
import sys
from utils.logging import set_basic_logger

logger = set_basic_logger()


def _dispatch():

    # This variable comprises both the subcommand AND the args
    global_args: dict = docopt(__doc__, sys.argv[1:], version=version, options_first=True)

    # Handle all global args we've set
    if global_args["--debug"]:
        logger.info("Setting logging level to 'DEBUG'")
        logger.setLevel(level="DEBUG")
    else:
        logger.setLevel(level="INFO")

    command_argv = [global_args["<command>"]] + global_args["<args>"]

    cmd = global_args['<command>']

    # Yes, this is just a massive if-else statement
    if cmd == "help":
        # We have a separate help function for each subcommand
        print(__doc__)
    elif cmd == "version":
        print(version)

    # Configuration commands
    elif cmd == "configure-repo":
        from subcommands.configure.configure_repo import ConfigureRepo
        # Initialise command
        configure_repo_obj = ConfigureRepo(command_argv)
        # Call command
        configure_repo_obj()
    elif cmd == "configure-tenant":
        from subcommands.configure.configure_tenant import ConfigureTenant
        # Initialise command
        configure_tenant_obj = ConfigureTenant(command_argv)
        # Call command
        configure_tenant_obj()
    elif cmd == "configure-user":
        from subcommands.configure.configure_user import ConfigureUser
        # Initialise command
        configure_project_obj = ConfigureUser(command_argv)
        # Call command
        configure_project_obj()

    # Config initialiser commands
    elif cmd == "category-init":
        from subcommands.initialisers.category_init import CategoryInit
        # Initialise command
        category_init_obj = CategoryInit(command_argv)
        # Call command
        category_init_obj()
    elif cmd == "project-init":
        from subcommands.initialisers.project_init import ProjectInit
        # Initialise command
        project_init_obj = ProjectInit(command_argv)
        # Call command
        project_init_obj()

    # Set default commands
    elif cmd == "set-default-tenant":
        from subcommands.updaters.set_default_tenant import SetDefaultTenant
        # Initialise command
        set_default_tenant_obj = SetDefaultTenant(command_argv)
        # Call command
        set_default_tenant_obj()
    elif cmd == "set-default-project":
        from subcommands.updaters.set_default_project import SetDefaultProject
        # Initialise command
        set_default_project_obj = SetDefaultProject(command_argv)
        # Call command
        set_default_project_obj()
    elif cmd == "set-default-user":
        from subcommands.updaters.set_default_user import SetDefaultUser
        # Initialise command
        set_default_user_obj = SetDefaultUser(command_argv)
        # Call command
        set_default_user_obj()

    # List commands
    elif cmd == "list-categories":
        from subcommands.listers.list_categories import ListCategories
        # Initialise command
        list_categories_obj = ListCategories(command_argv)
        # Call command
        list_categories_obj()
    elif cmd == "list-projects":
        from subcommands.listers.list_projects import ListProjects
        # Initialise command
        list_projects_obj = ListProjects(command_argv)
        # Call command
        list_projects_obj()
    elif cmd == "list-tenants":
        from subcommands.listers.list_tenants import ListTenants
        # Initialise Command
        list_tenants_obj = ListTenants(command_argv)
        # Call command
        list_tenants_obj()
    elif cmd == "list-users":
        from subcommands.listers.list_users import ListUsers
        # Initialise Command
        list_users_obj = ListUsers(command_argv)
        # Call command
        list_users_obj()

    # Creation commands
    elif cmd == "create-expression-from-template":
        from subcommands.creators.create_expression_from_template import CreateExpressionFromTemplate
        # Initialise command
        create_expression_obj = CreateExpressionFromTemplate(command_argv)
        # Call command
        create_expression_obj()
    elif cmd == "create-schema-from-template":
        from subcommands.creators.create_schema_from_template import CreateSchemaFromTemplate
        # Initialise command
        create_schema_obj = CreateSchemaFromTemplate(command_argv)
        # Call command
        create_schema_obj()
    elif cmd == "create-tool-from-template":
        from subcommands.creators.create_tool_from_template import CreateToolFromTemplate
        # Initialise command
        create_tool_obj = CreateToolFromTemplate(command_argv)
        # Call command
        create_tool_obj()
    elif cmd == "create-workflow-from-template":
        from subcommands.creators.create_workflow_from_template import CreateWorkflowFromTemplate
        # Initialise command
        create_workflow_obj = CreateWorkflowFromTemplate(command_argv)
        # Call command
        create_workflow_obj()

    # Validation commands
    elif cmd == "expression-validate":
        from subcommands.validators.expression_validate import ExpressionValidate
        # Initialise command
        expression_validate_obj = ExpressionValidate(command_argv)
        # Call command
        expression_validate_obj()
    elif cmd == "schema-validate":
        from subcommands.validators.schema_validate import SchemaValidate
        # Initialise command
        schema_validate_obj = SchemaValidate(command_argv)
        # Call command
        schema_validate_obj()
    elif cmd == "tool-validate":
        from subcommands.validators.tool_validate import ToolValidate
        # Initialise command
        tool_validate_obj = ToolValidate(command_argv)
        # Call command
        tool_validate_obj()
    elif cmd == "workflow-validate":
        from subcommands.validators.workflow_validate import WorkflowValidate
        # Initialise command
        workflow_validate_obj = WorkflowValidate(command_argv)
        # Call command
        workflow_validate_obj()
    elif cmd == "validate-config-yamls":
        from subcommands.validators.validate_config_yamls import ValidateConfigYamls
        # Init command
        validate_config_obj = ValidateConfigYamls(command_argv)
        # Call command
        validate_config_obj()
    elif cmd == "validate-api-key-script":
        from subcommands.validators.validate_api_key_script import ValidateApiKeyScript
        # Init command
        validate_api_key_script_obj = ValidateApiKeyScript(command_argv)
        # Call command
        validate_api_key_script_obj()

    # Initialisation commands
    elif cmd == "expression-init":
        from subcommands.initialisers.expression_init import ExpressionInitialiser
        # Initialise command
        expression_init_obj = ExpressionInitialiser(command_argv)
        # Call command
        expression_init_obj()
    elif cmd == "schema-init":
        from subcommands.initialisers.schema_init import SchemaInitialiser
        # Initialise command
        schema_init_obj = SchemaInitialiser(command_argv)
        # Call command
        schema_init_obj()
    elif cmd == "tool-init":
        from subcommands.initialisers.tool_init import ToolInitialiser
        # Initialise command
        tool_init_obj = ToolInitialiser(command_argv)
        # Call command
        tool_init_obj()
    elif cmd == "workflow-init":
        from subcommands.initialisers.workflow_init import WorkflowInitialiser
        # Initialise command
        workflow_init_obj = WorkflowInitialiser(command_argv)
        # Call command
        workflow_init_obj()

    # Sync to project commands
    elif cmd == "expression-sync":
        from subcommands.sync.sync_expression import ExpressionSync
        # Initialise Command
        expression_sync_obj = ExpressionSync(command_argv)
        # Call command
        expression_sync_obj()
    elif cmd == "schema-sync":
        from subcommands.sync.sync_schema import SchemaSync
        # Initialise Command
        schema_sync_obj = SchemaSync(command_argv)
        # Call command
        schema_sync_obj()
    elif cmd == "tool-sync":
        from subcommands.sync.sync_tool import ToolSync
        # Initialise Command
        tool_sync_obj = ToolSync(command_argv)
        # Call command
        tool_sync_obj()
    elif cmd == "workflow-sync":
        from subcommands.sync.sync_workflow import WorkflowSync
        # Initialise Command
        workflow_sync_obj = WorkflowSync(command_argv)
        # Call command
        workflow_sync_obj()

    # Add to project commands --
    elif cmd == "add-tool-to-project":
        from subcommands.updaters.add_tool_to_project import AddToolToProject
        # Initialise command
        tool_add_obj = AddToolToProject(command_argv)
        # Call command
        tool_add_obj()
    elif cmd == "add-workflow-to-project":
        from subcommands.updaters.add_workflow_to_project import AddWorkflowToProject
        # Initialise command
        workflow_add_obj = AddWorkflowToProject(command_argv)
        # Call command
        workflow_add_obj()

    # Add category to 'x' commands
    elif cmd == "add-category-to-tool":
        from subcommands.updaters.add_category_to_tool import AddCategoryToTool
        # Initialise command
        category_add_obj = AddCategoryToTool(command_argv)
        # Call command
        category_add_obj()
    elif cmd == "add-category-to-workflow":
        from subcommands.updaters.add_category_to_workflow import AddCategoryToWorkflow
        # Initialise command
        category_add_obj = AddCategoryToWorkflow(command_argv)
        # Call command
        category_add_obj()

    # Add maintainer commands
    elif cmd == "add-maintainer-to-expression":
        from subcommands.updaters.add_maintainer_to_expression import AddMaintainerToExpression
        # Initialise command
        add_maintainer_obj = AddMaintainerToExpression(command_argv)
        # Call command
        add_maintainer_obj()
    elif cmd == "add-maintainer-to-tool":
        from subcommands.updaters.add_maintainer_to_tool import AddMaintainerToTool
        # Initialise command
        add_maintainer_obj = AddMaintainerToTool(command_argv)
        # Call command
        add_maintainer_obj()
    elif cmd == "add-maintainer-to-workflow":
        from subcommands.updaters.add_maintainer_to_workflow import AddMaintainerToWorkflow
        # Initialise command
        add_maintainer_obj = AddMaintainerToWorkflow(command_argv)
        # Call command
        add_maintainer_obj()

    # Project update command
    elif cmd == "add-linked-project":
        from subcommands.updaters.add_linked_project import LinkProject
        # Initialise command
        link_project_obj = LinkProject(command_argv)
        # Call command
        link_project_obj()

    # Github actions  # TODO - sync-schema / sync-expression
    elif cmd == "github-actions-sync-tools":
        from subcommands.sync.sync_github_actions_tool import SyncGitHubActionsTool
        # Initialise command
        sync_tools_obj = SyncGitHubActionsTool(command_argv)
        # Call command
        sync_tools_obj()
    elif cmd == "github-actions-sync-workflows":
        from subcommands.sync.sync_github_actions_workflow import SyncGitHubActionsWorkflow
        # Initialise command
        sync_workflows_obj = SyncGitHubActionsWorkflow(command_argv)
        # Call command
        sync_workflows_obj()
    else:
        print(__doc__)
        print(f"Could not find cmd \"{cmd}\". Please refer to usage above")
        sys.exit(1)


def main():
    # If only cwl-ica is written, append help s.t help documentation shows
    if len(sys.argv) == 1:
        sys.argv.append('help')
    try:
        _dispatch()
    except KeyboardInterrupt:
        pass
