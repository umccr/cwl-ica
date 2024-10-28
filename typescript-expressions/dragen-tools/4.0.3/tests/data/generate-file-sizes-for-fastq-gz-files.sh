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

# Initialise the tsv header
echo "fastqPath	fileSizeInBytes"

# Generate file sizes for the input fastq gz files
for fastq_gz_path in "${FASTQ_GZ_PATHS[@]}"; do
  file_size="$(wc -c < "data/${fastq_gz_path}")"
  echo "${fastq_gz_path}	${file_size}"
done

# file size script complete
