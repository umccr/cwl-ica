#!/usr/bin/env python

"""
GitHub actions sync command super class

Syncs workflows and tools for each project
"""

from classes.command import Command
from classes.ica_workflow_version import ICAWorkflowVersion
from utils.logging import get_logger
from utils.repo import get_project_yaml_path
from utils.repo import read_yaml
from utils.miscell import set_projects, write_projects_yaml, write_item_yaml
from pathlib import Path

logger = get_logger()


class SyncGitHubActions(Command):
    """
    The syncGitHubActions command is a parent class, but most definitions are found in here.
    First we check the args and the environment variables (make sure GIT_COMMIT_ID) is defined.
    We first iterate through all items and sync them to the item.yaml (either tool.yaml or workflow.yaml)
    We keep a list of items that were updated in the process
    We iterate through each of the projects, if a given project contains an item it is also synced.
    """

    def __init__(self, command_argv, item_dir=None, item_yaml_path=None, item_type_key=None, item_type=None, item_suffix="cwl"):
        """
        After checking args
        :param command_argv:
        """
        # Get args
        super(SyncGitHubActions, self).__init__(command_argv)

        # Set null vars
        self.commit_id = None

        # Get vars from parameters
        self.item_dir = item_dir
        self.item_yaml_path = item_yaml_path
        self.item_type_key = item_type_key
        self.item_type = item_type
        self.item_suffix = item_suffix

        # Check args
        self.check_args()

        # Get items
        self.items = self.get_items()

        # Get projects
        self.projects = self.get_projects()

    def __call__(self):
        # Iterate through each item, determine if to update or not
        for item in self.items:
            for version in item.versions:
                # Call the version to set the cwl_obj
                version()
                # Update version md5sum
                version.md5sum = version.cwl_obj.md5sum

        # Write out items yaml
        logger.info(f"Writing out updated \"{self.item_type}\"(s) to \"{self.get_item_yaml()}\"")
        write_item_yaml(self.items, self.item_type_key, self.get_item_yaml())

        # Iterate through projects
        for project in self.projects:
            # Get ordered list of workflows and item objects
            project_items = self.get_project_ica_item_list(project)
            ica_workflows, item_objs = self.get_ica_workflows_to_update(project_items)
            # Iterate through ica workflows with items
            for ica_workflow, item_obj in zip(ica_workflows, item_objs):
                # Get ica workflow versions with item versions
                ica_workflow_versions, item_versions = self.get_ica_workflow_versions_to_update(ica_workflow, item_obj,
                                                                                                is_production=project.is_production,
                                                                                                project_token=project.get_project_token())
                # Iterate through workflow and version
                for ica_workflow_version, item_version in zip(ica_workflow_versions, item_versions):
                    # Get md5sum
                    md5sum = item_version.md5sum
                    # Get cwl packed object
                    cwl_packed_obj = item_version.cwl_obj.cwl_packed_obj
                    # Sync workflow
                    logger.info(f"Syncing \"{self.item_type}\" \"{item_obj.name}/{item_version.name}\" "
                                f"for project \"{project.project_name}\"")
                    project.sync_item_version_with_project(ica_workflow_version, md5sum, cwl_packed_obj)

        # Write out projects yaml
        write_projects_yaml(self.projects)

    def check_args(self):
        """
        Implemented in subclass
        :return:
        """
        raise NotImplementedError

    @staticmethod
    def get_item_yaml():
        """
        Get items
        :return:
        """
        raise NotImplementedError

    @staticmethod
    def get_item_obj_from_dict(item):
        """
        Get item object from dict
        :return:
        """
        raise NotImplementedError

    def get_items(self):
        """
        Get the list of items from the item.yaml (tool.yaml) or workflow.yaml
        :return:
        """
        items = []

        if not self.get_item_yaml().is_file():
            return []

        for item in read_yaml(self.get_item_yaml())[self.item_type_key]:
            # Read each item
            items.append(self.get_item_obj_from_dict(item))

        return items

    @staticmethod
    def get_project_ica_item_list(project):
        """
        Implemented in subclass
        Will return either the tools attribute or the workflows attribute of the project
        :return:
        """
        raise NotImplementedError

    @staticmethod
    def get_projects():
        """
        Get the projects yaml
        :return:
        """
        projects_yaml_path = get_project_yaml_path(
            non_existent_ok=True  # We could be in a repository with no projects
        )

        # Check file exists
        if not projects_yaml_path.is_file():
            return []

        # Get projects
        project_names = [project.get("project_name") for project in read_yaml(projects_yaml_path)["projects"]]

        return set_projects(project_names)

    def get_project_items(self, project_obj):
        """
        Returns the list of tools or workflows
        :return:
        """
        if self.item_type == "tool":
            return project_obj.tools
        elif self.item_type == "workflow":
            return project_obj.workflows
        else:
            logger.warning("Could not get the right project items, returning None")
            return None

    def get_ica_workflows_to_update(self, project_items):
        """
        For a given item object, match the projects whose versions need updating
        :param project_items
        :return: Two lists of an item object AND a ica workflow object
        """

        # Initialise filtered item list
        filtered_project_item_list = []
        filtered_item_obj_list = []

        # Iterate through project items
        for p_item in project_items:
            for i_item in self.items:
                if p_item.name == i_item.name:
                    filtered_project_item_list.append(p_item)
                    filtered_item_obj_list.append(i_item)
                    break
            else:
                # This tool / workflow is not in this project
                pass

        return filtered_project_item_list, filtered_item_obj_list

    def get_ica_workflow_versions_to_update(self, project_item, item_obj, is_production=False, project_token=None):
        """
        For a given project item and an item object
        Find if any of the project ICA workflow versions match the item versions
        If we're in a production project, we must first make sure that the version has an ica workflow version name __GIT_COMMIT_ID__
        :return:
        """
        # Version tuples
        project_ica_workflow_versions_list = []
        item_versions_list = []

        workflow_versions_to_append_to_project_item = []  # Used only for production projects

        # Initialise version(s) to update
        for p_item_version in project_item.versions:
            for i_item_version in item_obj.versions:
                if p_item_version.name == i_item_version.name:
                    if not is_production:
                        # We can add tuple and break here
                        project_ica_workflow_versions_list.append(p_item_version)
                        item_versions_list.append(i_item_version)
                        break
                    # For production projects
                    # First we get the sum of the number of matching versions
                    matching_p_item_versions = [p_item_version
                                                for p_item_version in project_item.versions
                                                if p_item_version.name == i_item_version.name]
                    # Do we have an 'init' of this workflow
                    if len(matching_p_item_versions) == 1 and \
                            p_item_version.ica_workflow_version_name == i_item_version.name + "--__GIT_COMMIT_ID__":
                        # We can add the tuple
                        project_ica_workflow_versions_list.append(p_item_version)
                        item_versions_list.append(i_item_version)
                        break
                    # Only compare if this is the last entry of versions
                    elif p_item_version.ica_workflow_version_name == matching_p_item_versions[-1].ica_workflow_version_name:
                        # Now compare this version's md5sum to the md5sum of the i_item_version
                        # If it is the same then we don't append.
                        # If it's different we're adding a new ica workflow version entry
                        # Call the workflow version object
                        p_item_version.get_workflow_version_object(access_token=project_token)
                        ica_workflow_md5sum = p_item_version.get_workflow_version_md5sum()
                        if ica_workflow_md5sum == i_item_version.md5sum:
                            continue
                        else:
                            # We need to make a new ICAWorkflowVersion object
                            # Add this ica workflow version object to the list of tuples and
                            # also update the project item
                            ica_workflow_version = ICAWorkflowVersion(name=i_item_version.name,
                                                                      path=Path(i_item_version.name) /
                                                                           Path(item_obj.name + "__" +
                                                                                i_item_version.name +
                                                                                self.item_suffix),
                                                                      ica_workflow_id=project_item.ica_workflow_id,
                                                                      ica_workflow_version_name=i_item_version.name +
                                                                                                "--__GIT_COMMIT_ID__",
                                                                      modification_time=None,
                                                                      run_instances=None)
                            # Append to project items
                            workflow_versions_to_append_to_project_item.append(ica_workflow_version)

                            # Append to tuples
                            project_ica_workflow_versions_list.append(ica_workflow_version)
                            item_versions_list.append(i_item_version)

        # Append items to production project
        if not len(workflow_versions_to_append_to_project_item) == 0:
            project_item.versions.extend(workflow_versions_to_append_to_project_item)

        # Return all matching tuples with the two objects
        return project_ica_workflow_versions_list, item_versions_list
