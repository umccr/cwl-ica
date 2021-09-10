#!/usr/bin/env python

from utils.repo import get_tenant_yaml_path
from utils.miscell import read_yaml

for tenant in read_yaml(get_tenant_yaml_path())["tenants"]:
    print(tenant["tenant_name"])