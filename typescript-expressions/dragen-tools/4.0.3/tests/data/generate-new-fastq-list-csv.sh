#!/usr/bin/env bash

set -euo pipefail

# Generate a new fastq list csv script
# Initialise header
echo "RGID,RGLB,RGSM,Read1File,Read2File"
echo "2.MY_SAMPLE_ID,UnknownLibrary,MY_SAMPLE_ID,MY_SAMPLE_ID_L002_R1_001.fastq.ora,MY_SAMPLE_ID_L002_R2_001.fastq.ora"
echo "4.MY_SAMPLE_ID,UnknownLibrary,MY_SAMPLE_ID,MY_SAMPLE_ID_L004_R1_001.fastq.ora,MY_SAMPLE_ID_L004_R2_001.fastq.ora"
