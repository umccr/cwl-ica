#!/usr/bin/env python3

"""
List of globals
"""

CWL_ICA_REPO_PATH_ENV_VAR = "CWL_ICA_REPO_PATH"
ICA_BASE_URL_ENV_VAR = "ICA_BASE_URL"
EXPIRY_DAYS_WARNING_TRIGGER = 7
BASE_URL_NETLOC_REGEX = "(\S+).platform.illumina.com"
PROJECT_ID_REGEX = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

SCOPES_BY_ROLE = {
    "read-only": [
        "TES.RUNS.READ",
        "TES.TASKS.READ",
        "TES.VERSIONS.READ",
        "WES.RUNS.READ",
        "WES.SIGNALS.READ",
        "WES.VERSIONS.READ",
        "WES.WORKFLOWS.READ"
    ],
    # Contributor has the same roles as ica roles as an admin
    "admin": [
        # Removed ability to create/edit task runs
        "TES.RUNS.READ",
        "TES.TASKS.CREATE",
        "TES.TASKS.DELETE",
        "TES.TASKS.GRANT",
        "TES.TASKS.READ",
        "TES.TASKS.UPDATE",
        "TES.VERSIONS.CREATE",
        "TES.VERSIONS.DELETE",
        "TES.VERSIONS.GRANT",
        "TES.VERSIONS.READ",
        "TES.VERSIONS.UPDATE",
        # Removed ability to create/edit workflow runs
        "WES.RUNS.READ",
        "WES.SIGNALS.CREATE",
        "WES.SIGNALS.DELETE",
        "WES.SIGNALS.GRANT",
        "WES.SIGNALS.READ",
        "WES.SIGNALS.UPDATE",
        "WES.VERSIONS.CREATE",
        "WES.VERSIONS.DELETE",
        "WES.VERSIONS.GRANT",
        "WES.VERSIONS.READ",
        "WES.VERSIONS.UPDATE",
        "WES.WORKFLOWS.CREATE",
        "WES.WORKFLOWS.DELETE",
        "WES.WORKFLOWS.GRANT",
        "WES.WORKFLOWS.READ",
        "WES.WORKFLOWS.UPDATE"
    ]
}

