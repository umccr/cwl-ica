#!/usr/bin/env bash

# Fail on non-zero exit of subshell
set -euo pipefail

# Create staging directory
echo "Creating scratch directory at /ephemeral/hg38" 1>&2
mkdir -p "/ephemeral/hg38"

# Create output directory
echo "Creating output directory at hg38_alt_ht_3_8_4" 1>&2
mkdir -p "hg38_alt_ht_3_8_4"

# Change to staging directory
echo "Running dragen command at /ephemeral/hg38" 1>&2

# Run dragen command inside scratch dir
( \
  cd "/ephemeral/hg38" && \
  eval "/opt/edico/bin/dragen" '"${@}"' \
)

# tar up output directory
tar \
  --directory "$(dirname "hg38_alt_ht_3_8_4")" \
  --create \
  --gzip \
  --file "hg38_alt_ht_3_8_4.tar.gz" \
  "hg38_alt_ht_3_8_4"
