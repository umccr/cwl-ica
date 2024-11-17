#!/usr/bin/env bash

# Exit on failure
set -euo pipefail

# Get fastq gz paths
FASTQ_GZ_PATHS=(
  "MY_SAMPLE_ID_L002_R1_001.fastq.gz" \
  "MY_SAMPLE_ID_L002_R2_001.fastq.gz" \
  "MY_SAMPLE_ID_L004_R1_001.fastq.gz" \
  "MY_SAMPLE_ID_L004_R2_001.fastq.gz" \
)

# Run md5sum in parallel
parallel -j4 -0 zcat "data/{}" \| md5sum \| sed "s%-%{}%\;s%.gz$%%" ::: "${FASTQ_GZ_PATHS[@]}"

# Md5sum script complete
