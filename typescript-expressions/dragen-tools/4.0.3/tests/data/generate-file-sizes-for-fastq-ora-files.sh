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

# Initialise the tsv header
echo "fastqPath	fileSizeInBytes"

# Generate file sizes for the output fastq ora files
for fastq_ora_output_path in "${FASTQ_ORA_OUTPUT_PATHS[@]}"; do
  fastq_ora_scratch_path="/ephemeral/ora-outputs/$(basename "${fastq_ora_output_path}")"
  file_size="$(wc -c < "${fastq_ora_scratch_path}")"
  echo "${fastq_ora_output_path}	${file_size}"
done

# ORA script complete
