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
for fastq_ora_output_path in "${FASTQ_ORA_OUTPUT_PATHS[@]}"; do
  fastq_ora_scratch_path="/ephemeral/ora-outputs/$(basename "${fastq_ora_output_path}")"
  mkdir -p "$(dirname "output-directory-path/${fastq_ora_output_path}")"
  rsync --archive \
    --remove-source-files \
    --include "$(basename "${fastq_ora_output_path}")" \
    --exclude "*" \
    "$(dirname "${fastq_ora_scratch_path}")/" \
    "$(dirname "output-directory-path/${fastq_ora_output_path}")/"
done

# Transfer all other files
mkdir -p "output-directory-path/ora-logs/"
mv "/ephemeral/ora-outputs/" "output-directory-path/ora-logs/compression/"
