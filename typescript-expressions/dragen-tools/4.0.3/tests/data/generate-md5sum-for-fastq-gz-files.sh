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

# Generate md5sums for the input fastq gz files
for fastq_gz_path in "${FASTQ_GZ_PATHS[@]}"; do
  full_input_path="data/${fastq_gz_path}"
  md5sum "${full_input_path}" | sed "s%${full_input_path}%${fastq_gz_path}%"
done

# Md5sum script complete
