#!/usr/bin/env bash

set -euo pipefail

# Generate md5sums for the output fastq ora files
# Change directory to the output directory to get relative md5sum
cd "/ephemeral/ora-outputs/"
md5sum "MY_SAMPLE_ID_L002_R1_001.fastq.ora"
md5sum "MY_SAMPLE_ID_L002_R2_001.fastq.ora"
md5sum "MY_SAMPLE_ID_L004_R1_001.fastq.ora"
md5sum "MY_SAMPLE_ID_L004_R2_001.fastq.ora"
# Md5sum script complete
