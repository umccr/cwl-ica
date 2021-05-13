#!/usr/bin/env python3

"""
All these thigns that could go wrong
"""


# CWL
class InvalidAuthorshipError(Exception):
    """
    Did not get the right authorship attributes for this file
    """
    pass


class CWLImportError(Exception):
    """
    Could not import the CWL file
    """
    pass


class CWLPackagingError(Exception):
    """
    Could not correctly pack the cwl file
    """
    pass


class CWLValidationError(Exception):
    """
    Could not validate this CWL file
    """
    pass


class CWLSchemaError(Exception):
    """
    Special CWL error reserved for schema classes
    """
    pass


class CWLItemNotFound(Exception):
    """
    Could not get path to CWL file
    """
    pass


# ICA
class ICAWorkflowError(Exception):
    """
    ICA Workflow object is misconfigured
    """
    pass


class ICAWorkflowCreationError(Exception):
    """
    Could not read in object from dictionary
    """
    pass


class ICAWorkflowVersionCreationError(Exception):
    """
    Could not read in version object from dictionary
    """
    pass


# Items
class ItemCreationError(Exception):
    """
    Could not create item from dict
    """
    pass


class ItemDirectoryNotFoundError(Exception):
    """
    Could not find item directory such as 'tools/'
    """
    pass


class ItemNotFoundError(Exception):
    """
    Could not find item in item.yaml
    """
    pass


class ItemVersionNotFoundError(Exception):
    """
    Could not find item version in item.yaml
    """
    pass


class ItemVersionExistsError(Exception):
    """
    The ItemVersion already exists in item.yaml
    """
    pass


class ItemVersionAttributeError(Exception):
    """
    A required attribute for the item version was not found
    """
    pass


class ItemVersionCreationError(Exception):
    """
    Could not create an item version object
    """
    pass

# Projects
class ProjectNotFoundError(Exception):
    """
    Could not find project inside project.yaml
    """
    pass


class ProductionProjectError(Exception):
    """
    An exception exclusive to Production Projects
    """
    pass


class CWLAccessTokenNotFoundError(Exception):
    """
    Could not retrieve the access token from the expected location
    """
    pass


class InvalidTokenError(Exception):
    """
    The token is not valid for this project
    """
    pass


class CWLApiKeyNotFoundError(Exception):
    """
    Could not get the api-key for this project
    """
    pass


class WorkflowVersionExistsError(Exception):
    """
    Workflow version already exists for this project
    """
    pass


class ProjectCreationError(Exception):
    """
    Could not create project object from dictionary
    """
    pass


# Users
class UserExistsError(Exception):
    """
    The user already exists in user.yaml
    """
    pass


class UserNotFoundError(Exception):
    """
    The user was not found in user.yaml
    """
    pass


# Tenants
class TenantExistsError(Exception):
    """
    The tenant already exists in tenant.yaml
    """
    pass


class TenantNotFoundError(Exception):
    """
    No tenant with this name was found in tenant.yaml
    """
    pass


# Categories
class CategoryExistsError(Exception):
    """
    The category already exists in category.yaml
    """
    pass


# Conda
class CondaError(Exception):
    """
    Conda env configuration error
    """
    pass


# Utils
class BaseUrlEnvNotFoundError(Exception):
    """
    Base url environment variable could not be found
    """
    pass


class InvalidBaseUrlError(Exception):
    """
    The base url was not a valid base url
    """
    pass


class TokenMembershipsError(Exception):
    """
    The token did not belong to the right project
    """
    pass


class TokenScopeError(Exception):
    """
    We don't have the right scopes on this token
    """
    pass


class TokenCreationError(Exception):
    """
    We could not successfully create the token
    """
    pass


# Repo
class CWLICARepoNotFoundError(Exception):
    """
    The CWL ICA repo could not be found
    """
    pass


class CWLICARepoAssetNotFoundError(Exception):
    """
    We could not find a particular repo asset
    """
    pass


# Validate
class CWLFileNameError(Exception):
    """
    We don't have the right file name logic for this cwl file
    """
    pass


# File naming conventions
class InvalidNameError(Exception):
    """
    The name of the tool/workflow was bad
    """
    pass

class InvalidVersionError(Exception):
    """
    The version of the tool/workflow was bad
    """
    pass

# CLI
class CheckArgumentError(Exception):
    """
    Very broad error message category, something failed in the arguments section
    """
    pass
