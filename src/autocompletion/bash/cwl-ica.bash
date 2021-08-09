#!/usr/bin/env bash

# Generated with perl module App::Spec v0.013

_cwl-ica() {

    COMPREPLY=()
    local program=cwl-ica
    local cur prev words cword
    _init_completion -n : || return
    declare -a FLAGS
    declare -a OPTIONS
    declare -a MYWORDS

    local INDEX=`expr $cword - 1`
    MYWORDS=("${words[@]:1:$cword}")

    FLAGS=('--help' 'Show command help' '-h' 'Show command help')
    OPTIONS=()
    __cwl-ica_handle_options_flags

    case $INDEX in

    0)
        __comp_current_options || return
        __cwl-ica_dynamic_comp 'commands' 'add-category-to-tool'$'\t''Add an existing category to an existing tool
'$'\n''add-category-to-workflow'$'\t''Add an existing category to an existing workflow
'$'\n''add-linked-project'$'\t''Add a linked project to another project
'$'\n''add-maintainer-to-expression'$'\t''Add a maintainter to a cwl expression
'$'\n''add-maintainer-to-tool'$'\t''Add a maintainter to a cwl tool
'$'\n''add-maintainer-to-workflow'$'\t''Add a maintainter to a cwl workflow
'$'\n''add-tool-to-project'$'\t''Add an existing tool to another project
'$'\n''add-workflow-to-project'$'\t''Add an existing workflow to another project
'$'\n''category-init'$'\t''Initialise a category in \${CWL_ICA_REPO_PATH}/config/category.yaml
'$'\n''configure-repo'$'\t''One-time command to point to the cwl-ica git repository
'$'\n''configure-tenant'$'\t''Create mapping of tenancy ids to tenancy names, convenience to save time typing out tenancy names.
Each project is linked to a tenancy id
'$'\n''configure-user'$'\t''Add a user to user.yaml
'$'\n''copy-tool-submission-template'$'\t''Copy a tool submission template for an upcoming tool run
'$'\n''copy-workflow-submission-template'$'\t''Copy a workflow submission template for an upcoming workflow run
'$'\n''create-expression-from-template'$'\t''Initialise an CWL expression from the cwl expression template
'$'\n''create-schema-from-template'$'\t''Initialise a CWL schema from the cwl schema template
'$'\n''create-tool-from-template'$'\t''Initialise a CWL tool from the cwl tool template
'$'\n''create-workflow-from-template'$'\t''Initialise a CWL workflow from the cwl workflow template
'$'\n''expression-init'$'\t''Register an expression in \${CWL_ICA_REPO_PATH}/config/expression.yaml
'$'\n''expression-sync'$'\t''Sync an expression in \${CWL_ICA_REPO_PATH}/config/expression.yaml
'$'\n''expression-validate'$'\t''Validate a CWL expression
'$'\n''get-workflow-step-ids'$'\t''Get the step ids of a CWL workflow
'$'\n''help'$'\t''Print help and exit
'$'\n''list-categories'$'\t''List registered categories
'$'\n''list-projects'$'\t''List registered projects
'$'\n''list-tenants'$'\t''List registered tenants
'$'\n''list-tool-runs'$'\t''List registered tool runs for a CWL tool in a given project
'$'\n''list-users'$'\t''List registered users
'$'\n''list-workflow-runs'$'\t''List registered workflows runs for a CWL workflow in a given project
'$'\n''project-init'$'\t''Initialise a project in \${CWL_ICA_REPO_PATH}/config/project.yaml
'$'\n''register-tool-run-instance'$'\t''Register an ICA workflow run instance of a tool for a given project
'$'\n''register-workflow-run-instance'$'\t''Register an ICA workflow run instance of a workflow for a given project
'$'\n''schema-init'$'\t''Register a schema in \${CWL_ICA_REPO_PATH}/config/schema.yaml
'$'\n''schema-sync'$'\t''Sync a schema in \${CWL_ICA_REPO_PATH}/config/schema.yaml
'$'\n''schema-validate'$'\t''Validate a CWL schema
'$'\n''set-default-project'$'\t''Set a project to the default project
'$'\n''set-default-tenant'$'\t''Set a tenant to the default tenant
'$'\n''set-default-user'$'\t''Set a user to the default user
'$'\n''tool-init'$'\t''Register a tool in \${CWL_ICA_REPO_PATH}/config/tool.yaml and with ICA projects
'$'\n''tool-sync'$'\t''Sync a tool md5sum in \${CWL_ICA_REPO_PATH}/config/tool.yaml
and update definition on ICA
'$'\n''tool-validate'$'\t''Validate a CWL tool ready for initialising on ICA
'$'\n''validate-api-key-script'$'\t''Confirm your api-key script works for a given project
'$'\n''validate-config-yamls'$'\t''Confirm all config yamls are legitimate
'$'\n''version'$'\t''Print version and exit
'$'\n''workflow-init'$'\t''Register a workflow in \${CWL_ICA_REPO_PATH}/config/workflow.yaml and with ICA projects
'$'\n''workflow-sync'$'\t''Sync a workflows md5sum in \${CWL_ICA_REPO_PATH}/config/workflow.yaml
and update definition on ICA
'$'\n''workflow-validate'$'\t''Validate a CWL workflow ready for initialising on ICA
'

    ;;
    *)
    # subcmds
    case ${MYWORDS[0]} in
      _meta)
        __cwl-ica_handle_options_flags
        case $INDEX in

        1)
            __comp_current_options || return
            __cwl-ica_dynamic_comp 'commands' 'completion'$'\t''Shell completion functions'$'\n''pod'$'\t''Pod documentation'

        ;;
        *)
        # subcmds
        case ${MYWORDS[1]} in
          completion)
            __cwl-ica_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __cwl-ica_dynamic_comp 'commands' 'generate'$'\t''Generate self completion'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              generate)
                FLAGS+=('--zsh' 'for zsh' '--bash' 'for bash')
                OPTIONS+=('--name' 'name of the program (optional, override name in spec)')
                __cwl-ica_handle_options_flags
                case ${MYWORDS[$INDEX-1]} in
                  --name)
                  ;;

                esac
                case $INDEX in

                *)
                    __comp_current_options || return
                ;;
                esac
              ;;
            esac

            ;;
            esac
          ;;
          pod)
            __cwl-ica_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __cwl-ica_dynamic_comp 'commands' 'generate'$'\t''Generate self pod'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              generate)
                __cwl-ica_handle_options_flags
                __comp_current_options true || return # no subcmds, no params/opts
              ;;
            esac

            ;;
            esac
          ;;
        esac

        ;;
        esac
      ;;
      add-category-to-tool)
        OPTIONS+=('--tool-name' 'Name of the tool
' '--category-name' 'The name of the category
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tool-name)
            _cwl-ica_add-category-to-tool_option_tool_name_completion
          ;;
          --category-name)
            _cwl-ica_add-category-to-tool_option_category_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      add-category-to-workflow)
        OPTIONS+=('--workflow-name' 'Name of the workflow
' '--category-name' 'The name of the category
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-name)
            _cwl-ica_add-category-to-workflow_option_workflow_name_completion
          ;;
          --category-name)
            _cwl-ica_add-category-to-workflow_option_category_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      add-linked-project)
        OPTIONS+=('--src-project' 'The name of your project in project.yaml
' '--target-project' 'ID of the target project to receive all ica workflows and ica workflow versions
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --src-project)
            _cwl-ica_add-linked-project_option_src_project_completion
          ;;
          --target-project)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      add-maintainer-to-expression)
        OPTIONS+=('--expression-path' 'Path to cwl expression
' '--project-name' 'Name of project
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --expression-path)
            _cwl-ica_add-maintainer-to-expression_option_expression_path_completion
          ;;
          --project-name)
            _cwl-ica_add-maintainer-to-expression_option_project_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      add-maintainer-to-tool)
        OPTIONS+=('--tool-path' 'Path to cwl tool
' '--project-name' 'Name of project
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tool-path)
            _cwl-ica_add-maintainer-to-tool_option_tool_path_completion
          ;;
          --project-name)
            _cwl-ica_add-maintainer-to-tool_option_project_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      add-maintainer-to-workflow)
        OPTIONS+=('--workflow-path' 'Path to cwl workflow
' '--project-name' 'Name of project
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-path)
            _cwl-ica_add-maintainer-to-workflow_option_workflow_path_completion
          ;;
          --project-name)
            _cwl-ica_add-maintainer-to-workflow_option_project_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      add-tool-to-project)
        OPTIONS+=('--tool-path' 'Path to the tool
' '--project' 'Name of the project
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tool-path)
            _cwl-ica_add-tool-to-project_option_tool_path_completion
          ;;
          --project)
            _cwl-ica_add-tool-to-project_option_project_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      add-workflow-to-project)
        OPTIONS+=('--workflow-path' 'Path to the workflow
' '--project' 'Name of the project to add the workflow to
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-path)
            _cwl-ica_add-workflow-to-project_option_workflow_path_completion
          ;;
          --project)
            _cwl-ica_add-workflow-to-project_option_project_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      category-init)
        OPTIONS+=('--category-name' 'Name of category
' '--category-description' 'Category description
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --category-name)
          ;;
          --category-description)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      configure-repo)
        OPTIONS+=('--repo-path' 'path to local cwl-ica repository
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --repo-path)
            compopt -o dirnames
            return
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      configure-tenant)
        OPTIONS+=('--tenant-id' 'The id of the tenant
' '--tenant-name' 'The name of the tenant
' '--set-as-default' 'Set as default tenant
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tenant-id)
          ;;
          --tenant-name)
          ;;
          --set-as-default)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      configure-user)
        OPTIONS+=('--username' 'The name of the user
' '--email' 'The users email address
' '--identifier' 'The orcid ID of the user
' '--set-as-default' 'Set as default user
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --username)
          ;;
          --email)
          ;;
          --identifier)
          ;;
          --set-as-default)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      copy-tool-submission-template)
        OPTIONS+=('--ica-workflow-run-instance-id' 'A ica workflow run instance id
' '--prefix' 'The prefix to the outputs files and name attribute in the json file
' '--curl' 'Use curl binary over ica binary to launch workflow
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --ica-workflow-run-instance-id)
            _cwl-ica_copy-tool-submission-template_option_ica_workflow_run_instance_id_completion
          ;;
          --prefix)
          ;;
          --curl)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      copy-workflow-submission-template)
        OPTIONS+=('--ica-workflow-run-instance-id' 'A ica workflow run instance id
' '--prefix' 'The prefix to the outputs files and name attribute in the json file
' '--curl' 'Use curl binary over ica binary to launch workflow
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --ica-workflow-run-instance-id)
            _cwl-ica_copy-workflow-submission-template_option_ica_workflow_run_instance_id_completion
          ;;
          --prefix)
          ;;
          --curl)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      create-expression-from-template)
        OPTIONS+=('--expression-name' 'The name of the expression
' '--expression-version' 'Version of the expression
' '--username' 'CWL Creator
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --expression-name)
          ;;
          --expression-version)
          ;;
          --username)
            _cwl-ica_create-expression-from-template_option_username_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      create-schema-from-template)
        OPTIONS+=('--schema-name' 'The name of the schema
' '--schema-version' 'Version of the schema
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --schema-name)
          ;;
          --schema-version)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      create-tool-from-template)
        OPTIONS+=('--tool-name' 'The name of the tool
' '--tool-version' 'Version of the tool
' '--username' 'CWL Creator
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tool-name)
          ;;
          --tool-version)
          ;;
          --username)
            _cwl-ica_create-tool-from-template_option_username_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      create-workflow-from-template)
        OPTIONS+=('--workflow-name' 'The name of the workflow
' '--workflow-version' 'Version of the workflow
' '--username' 'CWL Creator
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-name)
          ;;
          --workflow-version)
          ;;
          --username)
            _cwl-ica_create-workflow-from-template_option_username_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      expression-init)
        OPTIONS+=('--expression-path' 'Path to the expression
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --expression-path)
            _cwl-ica_expression-init_option_expression_path_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      expression-sync)
        OPTIONS+=('--expression-path' 'Path to the expression
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --expression-path)
            _cwl-ica_expression-sync_option_expression_path_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      expression-validate)
        OPTIONS+=('--expression-path' 'Path to the expression
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --expression-path)
            _cwl-ica_expression-validate_option_expression_path_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      get-workflow-step-ids)
        OPTIONS+=('--workflow-path' 'A cwl workflow file
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-path)
            _cwl-ica_get-workflow-step-ids_option_workflow_path_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      help)
        __cwl-ica_handle_options_flags
        __comp_current_options true || return # no subcmds, no params/opts
      ;;
      list-categories)
        __cwl-ica_handle_options_flags
        __comp_current_options true || return # no subcmds, no params/opts
      ;;
      list-projects)
        OPTIONS+=('--tenant-name' 'Name of tenant
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tenant-name)
            _cwl-ica_list-projects_option_tenant_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      list-tenants)
        __cwl-ica_handle_options_flags
        __comp_current_options true || return # no subcmds, no params/opts
      ;;
      list-tool-runs)
        OPTIONS+=('--tool-path' 'A cwl tool file
' '--project' 'A project name
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tool-path)
            _cwl-ica_list-tool-runs_option_tool_path_completion
          ;;
          --project)
            _cwl-ica_list-tool-runs_option_project_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      list-users)
        __cwl-ica_handle_options_flags
        __comp_current_options true || return # no subcmds, no params/opts
      ;;
      list-workflow-runs)
        OPTIONS+=('--workflow-path' 'A cwl workflow file
' '--project' 'A project name
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-path)
            _cwl-ica_list-workflow-runs_option_workflow_path_completion
          ;;
          --project)
            _cwl-ica_list-workflow-runs_option_project_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      project-init)
        OPTIONS+=('--project-id' 'The ICA project id
' '--project-name' 'The name of the project
' '--project-api-key-name' 'Required, this is NOT an api-key, but merely an api-key with a workgroup
context that can create an access-token for this project
' '--project-description' 'Required, a short summary of the project
' '--project-abbr' 'Required, a quick abbreviation of the project name - used to append
to workflow names
' '--production' 'Optional, boolean, if set, the project is a production project
' '--tenant-name' 'Optional, the tenant name
' '--set-as-default' 'Optional, set as the default project
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --project-id)
          ;;
          --project-name)
          ;;
          --project-api-key-name)
          ;;
          --project-description)
          ;;
          --project-abbr)
          ;;
          --production)
          ;;
          --tenant-name)
            _cwl-ica_project-init_option_tenant_name_completion
          ;;
          --set-as-default)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      register-tool-run-instance)
        OPTIONS+=('--ica-workflow-run-instance-id' 'A workflow run instance id (starts with wfr.)
' '--project-name' 'Name of project
' '--access-token' 'ica access token, if run instance was executed in a linked project context
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --ica-workflow-run-instance-id)
          ;;
          --project-name)
            _cwl-ica_register-tool-run-instance_option_project_name_completion
          ;;
          --access-token)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      register-workflow-run-instance)
        OPTIONS+=('--ica-workflow-run-instance-id' 'A workflow run instance id (starts with wfr.)
' '--project-name' 'Name of project
' '--access-token' 'ica access token, if run instance was executed in a linked project context
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --ica-workflow-run-instance-id)
          ;;
          --project-name)
            _cwl-ica_register-workflow-run-instance_option_project_name_completion
          ;;
          --access-token)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      schema-init)
        OPTIONS+=('--schema-path' 'Path to the schema
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --schema-path)
            _cwl-ica_schema-init_option_schema_path_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      schema-sync)
        OPTIONS+=('--schema-path' 'Path to the schema
' '--force' 'Overwrite on ICA even if mod time in yaml is behind
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --schema-path)
            _cwl-ica_schema-sync_option_schema_path_completion
          ;;
          --force)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      schema-validate)
        OPTIONS+=('--schema-path' 'Path to the schema
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --schema-path)
            _cwl-ica_schema-validate_option_schema_path_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      set-default-project)
        OPTIONS+=('--project-name' 'Name of project
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --project-name)
            _cwl-ica_set-default-project_option_project_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      set-default-tenant)
        OPTIONS+=('--tenant-name' 'Name of tenant
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tenant-name)
            _cwl-ica_set-default-tenant_option_tenant_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      set-default-user)
        OPTIONS+=('--username' 'Name of user
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --username)
            _cwl-ica_set-default-user_option_username_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      tool-init)
        OPTIONS+=('--tool-path' 'Path to the tool
' '--projects' 'List of projects to add the tool to
' '--tenants' 'List of tenants to filter by when project set to '"\\'"'all'"\\'"'
' '--categories' 'List of categories to add to tool
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tool-path)
            _cwl-ica_tool-init_option_tool_path_completion
          ;;
          --projects)
            _cwl-ica_tool-init_option_projects_completion
          ;;
          --tenants)
            _cwl-ica_tool-init_option_tenants_completion
          ;;
          --categories)
            _cwl-ica_tool-init_option_categories_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      tool-sync)
        OPTIONS+=('--tool-path' 'Path to the tool
' '--projects' 'List of projects to sync the tool to
' '--tenants' 'List of tenants to filter by when project set to '"\\'"'all'"\\'"'
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tool-path)
            _cwl-ica_tool-sync_option_tool_path_completion
          ;;
          --projects)
            _cwl-ica_tool-sync_option_projects_completion
          ;;
          --tenants)
            _cwl-ica_tool-sync_option_tenants_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      tool-validate)
        OPTIONS+=('--tool-path' 'Path to the tool
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --tool-path)
            _cwl-ica_tool-validate_option_tool_path_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      validate-api-key-script)
        OPTIONS+=('--project-name' 'Name of your project
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --project-name)
            _cwl-ica_validate-api-key-script_option_project_name_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      validate-config-yamls)
        __cwl-ica_handle_options_flags
        __comp_current_options true || return # no subcmds, no params/opts
      ;;
      version)
        __cwl-ica_handle_options_flags
        __comp_current_options true || return # no subcmds, no params/opts
      ;;
      workflow-init)
        OPTIONS+=('--workflow-path' 'Path to the workflow
' '--projects' 'List of projects to add the tool to
' '--tenants' 'List of tenants to filter by when project set to '"\\'"'all'"\\'"'
' '--categories' 'List of categories to add to tool
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-path)
            _cwl-ica_workflow-init_option_workflow_path_completion
          ;;
          --projects)
            _cwl-ica_workflow-init_option_projects_completion
          ;;
          --tenants)
            _cwl-ica_workflow-init_option_tenants_completion
          ;;
          --categories)
            _cwl-ica_workflow-init_option_categories_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      workflow-sync)
        OPTIONS+=('--workflow-path' 'Path to the workflow
' '--projects' 'List of projects to sync the workflow to
' '--tenants' 'List of tenants to filter by when project set to '"\\'"'all'"\\'"'
' '--force' 'Overwrite on ICA even if mod time in yaml is behind
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-path)
            _cwl-ica_workflow-sync_option_workflow_path_completion
          ;;
          --projects)
            _cwl-ica_workflow-sync_option_projects_completion
          ;;
          --tenants)
            _cwl-ica_workflow-sync_option_tenants_completion
          ;;
          --force)
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
      workflow-validate)
        OPTIONS+=('--workflow-path' 'Path to the workflow
')
        __cwl-ica_handle_options_flags
        case ${MYWORDS[$INDEX-1]} in
          --workflow-path)
            _cwl-ica_workflow-validate_option_workflow_path_completion
          ;;

        esac
        case $INDEX in

        *)
            __comp_current_options || return
        ;;
        esac
      ;;
    esac

    ;;
    esac

}

_cwl-ica_compreply() {
    local prefix=""
    cur="$(printf '%q' "$cur")"
    IFS=$'\n' COMPREPLY=($(compgen -P "$prefix" -W "$*" -- "$cur"))
    __ltrim_colon_completions "$prefix$cur"

    # http://stackoverflow.com/questions/7267185/bash-autocompletion-add-description-for-possible-completions
    if [[ ${#COMPREPLY[*]} -eq 1 ]]; then # Only one completion
        COMPREPLY=( "${COMPREPLY[0]%% -- *}" ) # Remove ' -- ' and everything after
        COMPREPLY=( "${COMPREPLY[0]%%+( )}" ) # Remove trailing spaces
    fi
}

_cwl-ica_add-category-to-tool_option_tool_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tool_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_tool_yaml_path\n\nfor tool in read_yaml(get_tool_yaml_path())["tools"]:\n    print(tool.get("name"))\n""")')"
    _cwl-ica_compreply "$param_tool_name"
}
_cwl-ica_add-category-to-tool_option_category_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_category_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_category_yaml_path\n\nfor category in read_yaml(get_category_yaml_path())["categories"]:\n    print(category.get("name"))\n""")')"
    _cwl-ica_compreply "$param_category_name"
}
_cwl-ica_add-category-to-workflow_option_workflow_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_workflow_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_workflow_yaml_path\n\nfor workflow in read_yaml(get_workflow_yaml_path())["workflows"]:\n    print(workflow.get("name"))\n""")')"
    _cwl-ica_compreply "$param_workflow_name"
}
_cwl-ica_add-category-to-workflow_option_category_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_category_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_category_yaml_path\n\nfor category in read_yaml(get_category_yaml_path())["categories"]:\n    print(category.get("name"))\n""")')"
    _cwl-ica_compreply "$param_category_name"
}
_cwl-ica_add-linked-project_option_src_project_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_src_project="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_src_project"
}
_cwl-ica_add-maintainer-to-expression_option_expression_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_expression_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_expressions_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_expressions_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_expressions_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_expression_path"
}
_cwl-ica_add-maintainer-to-expression_option_project_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project_name"
}
_cwl-ica_add-maintainer-to-tool_option_tool_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tool_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_tools_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_tools_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_tools_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_tool_path"
}
_cwl-ica_add-maintainer-to-tool_option_project_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project_name"
}
_cwl-ica_add-maintainer-to-workflow_option_workflow_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_workflow_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_workflows_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_workflows_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_workflows_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_workflow_path"
}
_cwl-ica_add-maintainer-to-workflow_option_project_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project_name"
}
_cwl-ica_add-tool-to-project_option_tool_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tool_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_tools_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_tools_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_tools_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_tool_path"
}
_cwl-ica_add-tool-to-project_option_project_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project"
}
_cwl-ica_add-workflow-to-project_option_workflow_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_workflow_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_workflows_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_workflows_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_workflows_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_workflow_path"
}
_cwl-ica_add-workflow-to-project_option_project_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project"
}
_cwl-ica_copy-tool-submission-template_option_ica_workflow_run_instance_id_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_ica_workflow_run_instance_id="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_run_yaml_path\n\nfor run in read_yaml(get_run_yaml_path())["runs"]:\n    print(run.get("ica_workflow_run_instance_id"))\n""")')"
    _cwl-ica_compreply "$param_ica_workflow_run_instance_id"
}
_cwl-ica_copy-workflow-submission-template_option_ica_workflow_run_instance_id_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_ica_workflow_run_instance_id="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_run_yaml_path\n\nfor run in read_yaml(get_run_yaml_path())["runs"]:\n    print(run.get("ica_workflow_run_instance_id"))\n""")')"
    _cwl-ica_compreply "$param_ica_workflow_run_instance_id"
}
_cwl-ica_create-expression-from-template_option_username_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_username="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_user_yaml_path\n\nfor user in read_yaml(get_user_yaml_path())["users"]:\n    print(user.get("username"))\n""")')"
    _cwl-ica_compreply "$param_username"
}
_cwl-ica_create-tool-from-template_option_username_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_username="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_user_yaml_path\n\nfor user in read_yaml(get_user_yaml_path())["users"]:\n    print(user.get("username"))\n""")')"
    _cwl-ica_compreply "$param_username"
}
_cwl-ica_create-workflow-from-template_option_username_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_username="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_user_yaml_path\n\nfor user in read_yaml(get_user_yaml_path())["users"]:\n    print(user.get("username"))\n""")')"
    _cwl-ica_compreply "$param_username"
}
_cwl-ica_expression-init_option_expression_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_expression_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_expressions_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_expressions_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_expressions_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_expression_path"
}
_cwl-ica_expression-sync_option_expression_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_expression_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_expressions_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_expressions_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_expressions_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_expression_path"
}
_cwl-ica_expression-validate_option_expression_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_expression_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_expressions_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_expressions_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_expressions_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_expression_path"
}
_cwl-ica_get-workflow-step-ids_option_workflow_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_workflow_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_workflows_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_workflows_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_workflows_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_workflow_path"
}
_cwl-ica_list-projects_option_tenant_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tenant_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_tenant_yaml_path\n\nfor tenant in read_yaml(get_tenant_yaml_path())["tenants"]:\n    print(tenant.get("tenant_name"))\n""")')"
    _cwl-ica_compreply "$param_tenant_name"
}
_cwl-ica_list-tool-runs_option_tool_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tool_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_tools_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_tools_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_tools_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_tool_path"
}
_cwl-ica_list-tool-runs_option_project_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project"
}
_cwl-ica_list-workflow-runs_option_workflow_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_workflow_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_workflows_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_workflows_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_workflows_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_workflow_path"
}
_cwl-ica_list-workflow-runs_option_project_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project"
}
_cwl-ica_project-init_option_tenant_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tenant_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_tenant_yaml_path\n\nfor tenant in read_yaml(get_tenant_yaml_path())["tenants"]:\n    print(tenant.get("tenant_name"))\n""")')"
    _cwl-ica_compreply "$param_tenant_name"
}
_cwl-ica_register-tool-run-instance_option_project_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project_name"
}
_cwl-ica_register-workflow-run-instance_option_project_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project_name"
}
_cwl-ica_schema-init_option_schema_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_schema_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_schemas_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_schemas_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_schemas_dir().absolute())\n""")')" -name "*.yaml")"
    _cwl-ica_compreply "$param_schema_path"
}
_cwl-ica_schema-sync_option_schema_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_schema_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_schemas_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_schemas_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_schemas_dir().absolute())\n""")')" -name "*.yaml")"
    _cwl-ica_compreply "$param_schema_path"
}
_cwl-ica_schema-validate_option_schema_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_schema_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_schemas_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_schemas_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_schemas_dir().absolute())\n""")')" -name "*.yaml")"
    _cwl-ica_compreply "$param_schema_path"
}
_cwl-ica_set-default-project_option_project_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project_name"
}
_cwl-ica_set-default-tenant_option_tenant_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tenant_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_tenant_yaml_path\n\nfor tenant in read_yaml(get_tenant_yaml_path())["tenants"]:\n    print(tenant.get("tenant_name"))\n""")')"
    _cwl-ica_compreply "$param_tenant_name"
}
_cwl-ica_set-default-user_option_username_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_username="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_user_yaml_path\n\nfor user in read_yaml(get_user_yaml_path())["users"]:\n    print(user.get("username"))\n""")')"
    _cwl-ica_compreply "$param_username"
}
_cwl-ica_tool-init_option_tool_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tool_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_tools_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_tools_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_tools_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_tool_path"
}
_cwl-ica_tool-init_option_projects_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_projects="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_projects"
}
_cwl-ica_tool-init_option_tenants_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tenants="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_tenant_yaml_path\n\nfor tenant in read_yaml(get_tenant_yaml_path())["tenants"]:\n    print(tenant.get("tenant_name"))\n""")')"
    _cwl-ica_compreply "$param_tenants"
}
_cwl-ica_tool-init_option_categories_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_categories="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_category_yaml_path\n\nfor category in read_yaml(get_category_yaml_path())["categories"]:\n    print(category.get("name"))\n""")')"
    _cwl-ica_compreply "$param_categories"
}
_cwl-ica_tool-sync_option_tool_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tool_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_tools_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_tools_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_tools_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_tool_path"
}
_cwl-ica_tool-sync_option_projects_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_projects="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_projects"
}
_cwl-ica_tool-sync_option_tenants_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tenants="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_tenant_yaml_path\n\nfor tenant in read_yaml(get_tenant_yaml_path())["tenants"]:\n    print(tenant.get("tenant_name"))\n""")')"
    _cwl-ica_compreply "$param_tenants"
}
_cwl-ica_tool-validate_option_tool_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tool_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_tools_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_tools_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_tools_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_tool_path"
}
_cwl-ica_validate-api-key-script_option_project_name_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_project_name="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_project_name"
}
_cwl-ica_workflow-init_option_workflow_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_workflow_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_workflows_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_workflows_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_workflows_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_workflow_path"
}
_cwl-ica_workflow-init_option_projects_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_projects="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_projects"
}
_cwl-ica_workflow-init_option_tenants_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tenants="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_tenant_yaml_path\n\nfor tenant in read_yaml(get_tenant_yaml_path())["tenants"]:\n    print(tenant.get("tenant_name"))\n""")')"
    _cwl-ica_compreply "$param_tenants"
}
_cwl-ica_workflow-init_option_categories_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_categories="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_category_yaml_path\n\nfor category in read_yaml(get_category_yaml_path())["categories"]:\n    print(category.get("name"))\n""")')"
    _cwl-ica_compreply "$param_categories"
}
_cwl-ica_workflow-sync_option_workflow_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_workflow_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_workflows_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_workflows_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_workflows_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_workflow_path"
}
_cwl-ica_workflow-sync_option_projects_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_projects="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_project_yaml_path\n\nfor project in read_yaml(get_project_yaml_path())["projects"]:\n    print(project.get("project_name"))\n""")')"
    _cwl-ica_compreply "$param_projects"
}
_cwl-ica_workflow-sync_option_tenants_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_tenants="$(python -c 'exec("""\nfrom utils.repo import read_yaml, get_tenant_yaml_path\n\nfor tenant in read_yaml(get_tenant_yaml_path())["tenants"]:\n    print(tenant.get("tenant_name"))\n""")')"
    _cwl-ica_compreply "$param_tenants"
}
_cwl-ica_workflow-validate_option_workflow_path_completion() {
    local CURRENT_WORD="${words[$cword]}"
    local param_workflow_path="$(find "$(python -c 'exec("""\nfrom utils.repo import get_workflows_dir\nfrom pathlib import Path\nfrom os import getcwd\n\ntry:\n  print(get_workflows_dir().absolute().relative_to(Path(getcwd())))\nexcept ValueError:\n  print(get_workflows_dir().absolute())\n""")')" -name "*.cwl")"
    _cwl-ica_compreply "$param_workflow_path"
}

__cwl-ica_dynamic_comp() {
    local argname="$1"
    local arg="$2"
    local name desc cols desclength formatted
    local comp=()
    local max=0

    while read -r line; do
        name="$line"
        desc="$line"
        name="${name%$'\t'*}"
        if [[ "${#name}" -gt "$max" ]]; then
            max="${#name}"
        fi
    done <<< "$arg"

    while read -r line; do
        name="$line"
        desc="$line"
        name="${name%$'\t'*}"
        desc="${desc/*$'\t'}"
        if [[ -n "$desc" && "$desc" != "$name" ]]; then
            # TODO portable?
            cols=`tput cols`
            [[ -z $cols ]] && cols=80
            desclength=`expr $cols - 4 - $max`
            formatted=`printf "%-*s -- %-*s" "$max" "$name" "$desclength" "$desc"`
            comp+=("$formatted")
        else
            comp+=("'$name'")
        fi
    done <<< "$arg"
    _cwl-ica_compreply ${comp[@]}
}

function __cwl-ica_handle_options() {
    local i j
    declare -a copy
    local last="${MYWORDS[$INDEX]}"
    local max=`expr ${#MYWORDS[@]} - 1`
    for ((i=0; i<$max; i++))
    do
        local word="${MYWORDS[$i]}"
        local found=
        for ((j=0; j<${#OPTIONS[@]}; j+=2))
        do
            local option="${OPTIONS[$j]}"
            if [[ "$word" == "$option" ]]; then
                found=1
                i=`expr $i + 1`
                break
            fi
        done
        if [[ -n $found && $i -lt $max ]]; then
            INDEX=`expr $INDEX - 2`
        else
            copy+=("$word")
        fi
    done
    MYWORDS=("${copy[@]}" "$last")
}

function __cwl-ica_handle_flags() {
    local i j
    declare -a copy
    local last="${MYWORDS[$INDEX]}"
    local max=`expr ${#MYWORDS[@]} - 1`
    for ((i=0; i<$max; i++))
    do
        local word="${MYWORDS[$i]}"
        local found=
        for ((j=0; j<${#FLAGS[@]}; j+=2))
        do
            local flag="${FLAGS[$j]}"
            if [[ "$word" == "$flag" ]]; then
                found=1
                break
            fi
        done
        if [[ -n $found ]]; then
            INDEX=`expr $INDEX - 1`
        else
            copy+=("$word")
        fi
    done
    MYWORDS=("${copy[@]}" "$last")
}

__cwl-ica_handle_options_flags() {
    __cwl-ica_handle_options
    __cwl-ica_handle_flags
}

__comp_current_options() {
    local always="$1"
    if [[ -n $always || ${MYWORDS[$INDEX]} =~ ^- ]]; then

      local options_spec=''
      local j=

      for ((j=0; j<${#FLAGS[@]}; j+=2))
      do
          local name="${FLAGS[$j]}"
          local desc="${FLAGS[$j+1]}"
          options_spec+="$name"$'\t'"$desc"$'\n'
      done

      for ((j=0; j<${#OPTIONS[@]}; j+=2))
      do
          local name="${OPTIONS[$j]}"
          local desc="${OPTIONS[$j+1]}"
          options_spec+="$name"$'\t'"$desc"$'\n'
      done
      __cwl-ica_dynamic_comp 'options' "$options_spec"

      return 1
    else
      return 0
    fi
}


complete -o default -F _cwl-ica cwl-ica

