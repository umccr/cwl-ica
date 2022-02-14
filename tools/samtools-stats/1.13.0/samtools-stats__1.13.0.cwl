cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: http://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: samtools-stats--1.13.0
label: samtools-stats v(1.13.0)
doc: |
    samtools stats collects statistics from BAM files and outputs in a text format. 
    The output can be visualized graphically using plot-bamstats.

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: xlarge
        coresMin: 4
        ramMin: 14000
    DockerRequirement:
        dockerPull: quay.io/biocontainers/samtools:1.13--h8c37831_0

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: "run-samtools-stats.sh"
        entry: |
          #!/usr/bin/env bash

          # Set up for failure
          set -euo pipefail

          # Run stats command, write to output file
          eval samtools stats '"\${@}"' 1> "$(inputs.output_filename).txt"

baseCommand: [ "bash", "run-samtools-stats.sh" ]

inputs:
  output_filename:
    label: output filename
    doc: |
      Redirects stdout
    type: string
  input_bam:
    label: input BAM 
    doc: |
      The BAM file to gather statistics from
    type: File
    secondaryFiles:
      - pattern: ".bai"
        required: false
    inputBinding:
      # After all other arguments
      position: 100
  coverage:
    label: coverage
    doc: |
      Set coverage distribution to the specified range (MIN, MAX, STEP all given as integers) [1,1000,1]
    type: int[]?
    inputBinding:
      prefix: "--coverage"
  remove_dups:
    label: remove dups
    doc: |
      Exclude from statistics reads marked as duplicates
    type: boolean?
    inputBinding:
      prefix: "--remove-dups"
  required_flag:
    label: required flag
    doc: |
      Required flag, 0 for unset. See also `samtools flags` [0]
    type: int?
    inputBinding:
      prefix: "--required-flag"
  filtering_flag:
    label: filtering flag
    doc: |
      iltering flag, 0 for unset. See also `samtools flags` [0]
    type: int?
    inputBinding:
      prefix: "--filtering-flag"
  GC_depth:
    label: GC depth 
    doc: |
      the size of GC-depth bins (decreasing bin size increases memory requirement) [2e4]
    type: float?
    inputBinding:
      prefix: "--GC-depth"
  insert_size:
    label: insert size 
    doc: |
      Maximum insert size [8000]
    type: int?
    inputBinding:
      prefix: "--insert-size"
  id:
    label: id
    doc: |
      Include only listed read group or sample name []
    type: string?
    inputBinding:
      prefix: "--id"
  read_length:
    label: read length 
    doc: |
      Include in the statistics only reads with the given read length [-1]
    type: int?
    inputBinding:
      prefix: "--read-length"
  most_inserts:
    label: most inserts
    doc: |
      Report only the main part of inserts [0.99]
    type: float?
    inputBinding:
      prefix: "--most-inserts"
  split_prefix:
    label: split prefix
    doc: |
      A path or string prefix to prepend to filenames output when creating categorised 
      statistics files with -S/--split. [input filename]
    type: string?
    inputBinding:
      prefix: "--split-prefix"
  trim_quality:
    label: trim quality
    doc: |
      The BWA trimming parameter [0]
    type: int?
    inputBinding:
      prefix: "--trim-quality"
  ref_seq:
    label: ref seq
    doc: |
      Reference sequence (required for GC-depth and mismatches-per-cycle calculation). []
    type: File?
    secondaryFiles:
      - pattern: ".fai"
        required: true
    inputBinding:
      prefix: "--ref-seq"
  split:
    label: split
    doc: |
      In addition to the complete statistics, also output categorised statistics based on the tagged field TAG 
      (e.g., use --split RG to split into read groups).
    type: string?
    inputBinding:
      prefix: "--split"
  target_regions:
    label: target regions
    doc: |
      Do stats in these regions only. Tab-delimited file chr,from,to, 1-based, inclusive. []
    type: File?
    inputBinding:
      prefix: "--target-regions"
  sparse:
    label: sparse
    doc: |
      Suppress outputting IS rows where there are no insertions.
    type: boolean?
    inputBinding:
      prefix: "--sparse"
  remove_overlaps:
    label: remove overlaps
    doc: |
      Remove overlaps of paired-end reads from coverage and base count computations.
    type: boolean?
    inputBinding:
      prefix: "--remove-overlaps"
  cov_threshold:
    label: cov threshold
    doc: |
      Only bases with coverage above this value will be included in the target percentage computation [0]
    type: int?
    inputBinding:
      prefix: "--cov-threshold"
  threads:
    label: threads
    doc: |
      Number of input/output compression threads to use in addition to main thread [0].
    type: int?
    inputBinding:
      prefix: "--threads"

outputs:
  output_file:
    label: output file
    doc: |
      Output file, of varying format depending on the command run
    type: File
    outputBinding:
      glob: "$(inputs.output_filename).txt"

successCodes:
  - 0
