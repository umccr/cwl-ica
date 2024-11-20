#!/usr/bin/env bash

# Exit on failure
set -euo pipefail

# Get fastq ora paths
FASTQ_ORA_OUTPUT_PATHS=(
  "MY_SAMPLE_ID_L002_R1_001.fastq.ora" \
  "MY_SAMPLE_ID_L002_R2_001.fastq.ora" \
  "MY_SAMPLE_ID_L004_R1_001.fastq.ora" \
  "MY_SAMPLE_ID_L004_R2_001.fastq.ora" \
)

# Move all ora files to the final output directory
xargs \
  --max-args=1 \
  --max-procs=16 \
  bash -c \
    '
      fastq_ora_scratch_path="/ephemeral/ora-outputs/$(basename "$@")"
      mkdir -p "$(dirname "output-directory-path/$@")"
      rsync \
        --archive \
        --remove-source-files \
        --include "$(basename "$@")" \
        --exclude "*" \
        "$(dirname "${fastq_ora_scratch_path}")/" \
        "$(dirname "output-directory-path/$@")/"
    ' \
  _ \
  <<< "${FASTQ_ORA_OUTPUT_PATHS[@]}"

# Transfer all other files
mkdir -p "output-directory-path/ora-logs/"
mv "/ephemeral/ora-outputs/" "output-directory-path/ora-logs/compression/"
