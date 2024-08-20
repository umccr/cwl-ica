#!/usr/bin/env bash

set -euo pipefail

# Move the output files from the scratch space to the working directory
mkdir -p "$(dirname "output-directory-path/MY_SAMPLE_ID_L002_R1_001.fastq.ora")"
mv "/ephemeral/ora-outputs/MY_SAMPLE_ID_L002_R1_001.fastq.ora" "output-directory-path/MY_SAMPLE_ID_L002_R1_001.fastq.ora"
mv "/ephemeral/ora-outputs/MY_SAMPLE_ID_L002_R2_001.fastq.ora" "output-directory-path/MY_SAMPLE_ID_L002_R2_001.fastq.ora"
mkdir -p "$(dirname "output-directory-path/MY_SAMPLE_ID_L004_R1_001.fastq.ora")"
mv "/ephemeral/ora-outputs/MY_SAMPLE_ID_L004_R1_001.fastq.ora" "output-directory-path/MY_SAMPLE_ID_L004_R1_001.fastq.ora"
mv "/ephemeral/ora-outputs/MY_SAMPLE_ID_L004_R2_001.fastq.ora" "output-directory-path/MY_SAMPLE_ID_L004_R2_001.fastq.ora"
# Transfer all other files
mv "/ephemeral/ora-outputs/" "output-directory-path/ora-compression-logs/"
