#!/usr/bin/env bash

set -euo pipefail

# Generate md5sums for the input fastq gz files
# Change directory to the input directory to get relative outputs
cd "data"
md5sum "MY_SAMPLE_ID_L002_R1_001.fastq.gz"
md5sum "MY_SAMPLE_ID_L002_R2_001.fastq.gz"
md5sum "MY_SAMPLE_ID_L004_R1_001.fastq.gz"
md5sum "MY_SAMPLE_ID_L004_R2_001.fastq.gz"
# Md5sum script complete
