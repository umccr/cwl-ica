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

# Generate md5sums for the input fastq ora files
for fastq_ora_output_path in "${FASTQ_ORA_OUTPUT_PATHS[@]}"; do
  fastq_ora_scratch_path="/ephemeral/ora-outputs/$(basename "${fastq_ora_output_path}")"
  md5sum "${fastq_ora_scratch_path}" | sed "s%${fastq_ora_scratch_path}%${fastq_ora_output_path}%"
done

# Md5sum script complete
