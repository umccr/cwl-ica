#!/usr/bin/env python3

"""
Link a project in project-init to a target project.

Future acl updates to workflow / workflow version will allow target project to see workflow and workflow version
"""
import re

from classes.command import Command
from utils.repo import read_yaml, get_project_yaml_path
from utils.logging import get_logger
from classes.project import Project
from classes.project_production import ProductionProject
from utils.yaml import dump_yaml
from utils.errors import CheckArgumentError
from utils.globals import PROJECT_ID_REGEX

logger = get_logger()


class LinkProject(Command):
    """Usage:
    cwl-ica [options] add-linked-project help
    cwl-ica [options] add-linked-project (--src-project project-name)
                                         (--target-project project-id)

Description:
    Add a linked project (target project) to the source project (src project).
    The source project must be present in project.yaml.
    This will update the acls for all ica workflows and ica workflow versions in the existing project.yaml for
    the source project's tools and workflows and will update project.yaml to contain the linked project attribute.


Options:
    --src-project=<project name>                              Name of your project in project.yaml
    --target-project=<the project id of the new project>      Name of the target project to receive all ica workflows
                                                              And ica workflow versions

Example:
    cwl-ica add-linked-project --src-project development_workflows --target-project dc8e6ba9-b744-437b-b070-4cf014694b3d
    """

    def __init__(self, command_argv):
        # Collect args from doc strings
        super().__init__(command_argv)

        # Initialise vars
        self.src_project_obj = None
        self.target_project_id = None

        # Check help
        logger.debug("Checking args length")
        self.check_length(command_argv)

        # Check if help has been called
        if self.args["help"]:
            self._help()

        # Confirm 'required' arguments are present and valid
        try:
            logger.debug("Checking args")
            self.check_args()
        except CheckArgumentError:
            self._help(fail=True)

    def __call__(self):
        """
        Add the tool / workflow to the project
        :return:
        """

        # Iterate through project tools and workflows and add update ica workflows and ica workflow versions with new 'acl'
        for item_list in [ self.src_project_obj.ica_tools_list, self.src_project_obj.ica_workflows_list ]:

          for ica_item_obj in item_list:
              logger.info(f"Updating acl of workflow '{ica_item_obj.ica_workflow_id}'")
              # Get existing acl - update existing acl
              workflow_response = ica_item_obj.get_workflow_object(access_token=self.src_project_obj.get_project_token())
              acl_list = workflow_response.acl + [f"cid:{self.target_project_id}"]
              ica_item_obj.update_ica_workflow_item(access_token=self.src_project_obj.get_project_token(), acl=acl_list)

              # Update item versions
              for ica_item_version in ica_item_obj.versions:
                  logger.info(f"Updating acl of workflow '{ica_item_obj.ica_workflow_id}' version '{ica_item_version.name}'")
                  # Get existing item version
                  workflow_version_response = ica_item_version.get_workflow_version_object(access_token=self.src_project_obj.get_project_token())

                  # Update acl list
                  acl_list = workflow_version_response.acl + [f"cid:{self.target_project_id}"]

                  # Update ica workflow item
                  ica_item_version.update_workflow_version(access_token=self.src_project_obj.get_project_token(),
                                                           acl=acl_list)

        # Update project yaml
        # Workflow versions now have an updated time stamp
        logger.info(f"Adding project {self.target_project_id} to {self.src_project_obj.project_name} in project.yaml")
        self.src_project_obj.linked_projects.append(self.target_project_id)

        # Write out project.yaml
        self.write_projects_yaml()

    def check_args(self):
        """
        Check arguments
        :return:
        """
        # Check source project exists
        source_project_arg = self.args.get("--src-project", None)

        if source_project_arg is None:
            logger.error("--src-project not specified")
            raise CheckArgumentError

        # Get project object
        # FIXME - this is a duplicate of check_project from add_to_project.py
        projects_list = read_yaml(get_project_yaml_path())["projects"]

        for project_dict in projects_list:
            # Not the right project, skip it
            if not project_dict.get("project_name", None) == source_project_arg:
                continue

            # Check production
            if project_dict.get("production", False):
                self.src_project_obj = ProductionProject.from_dict(project_dict)
            else:
                self.src_project_obj = Project.from_dict(project_dict)

            break

        else:
            logger.error(f"Could not find project \"{source_project_arg}\" in project.yaml. "
                         f"Please first run 'cwl-ica project-init' for this project")

        # Check target project
        target_project_arg = self.args.get("--target-project", None)

        if target_project_arg is None:
            logger.error("--target-project not specified")
            raise CheckArgumentError

        # Check regex
        if not re.fullmatch(PROJECT_ID_REGEX, target_project_arg):
            logger.error(f"Target project value \"{target_project_arg}\" doesn't look like a valid project ID")
            raise CheckArgumentError

        # Check target project isn't already in linked projects
        if target_project_arg in self.src_project_obj.linked_projects:
            logger.error(f"Target project \"{target_project_arg}\" is already a linked project to \"{self.src_project_obj.project_name}\"")

        # Set the target project value
        self.target_project_id = target_project_arg

    # FIXME - thi is also duplicate code
    def write_projects_yaml(self):
        """
        Re-write projects dictionary
        :return:
        """

        all_projects_list = read_yaml(get_project_yaml_path())['projects']
        new_all_projects_list = all_projects_list.copy()

        for i, project_dict in enumerate(all_projects_list):
            if not project_dict.get("project_name") == self.src_project_obj.project_name:
                continue
            new_all_projects_list[i] = self.src_project_obj.to_dict()

        with open(get_project_yaml_path(), "w") as project_h:
            dump_yaml({"projects": new_all_projects_list}, project_h)


