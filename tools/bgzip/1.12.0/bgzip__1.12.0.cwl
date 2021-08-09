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
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: bgzip--1.12.0
label: bgzip v(1.12.0)
doc: |
    Documentation for bgzip v1.12.0

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/ICA_CLI/Content/SW/ICA/IAPWES_RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: xlarge
        coresMin: 4
        ramMin: 14000
    DockerRequirement:
        dockerPull: quay.io/biocontainers/tabix:1.11--hdfd78af_0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_threads_val = function(){
          /*
          Set thread count number of cores specified
          of runtime.cores
          */
          if (inputs.threads === null){
            return runtime.cores;
          } else {
            return inputs.threads;
          }
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: run_bgzip.sh
        entry: |
          #!/usr/bin/env bash

          # Set to fail
          set -euo pipefail

          # Copy file into working dir
          cp "$(inputs.uncompressed_vcf_file.path)" "$(inputs.uncompressed_vcf_file.basename)"

          # Perform bgzip
          eval bgzip '"\${@}"'

baseCommand: [ "bash", "run_bgzip.sh" ]

arguments:
  # Get threads value
  - prefix: "--threads"
    valueFrom: "$(get_threads_val())"

inputs:
  uncompressed_vcf_file:
    label: uncompressed vcf file
    doc: |
      The input uncompressed vcf file
    type: File
    inputBinding:
      position: 100
      valueFrom: |
        ${
          return self.basename;
        }
  offset:
    label: offset
    doc: |
      Decompress at virtual file pointer (0-based uncompressed offset)
    type: int?
    inputBinding:
      prefix: "--offset"
  index:
    label: index
    doc: |
      Compress and create BGZF index
    type: boolean?
    inputBinding:
      prefix: "--index"
  compress_level:
    label: compress level
    doc: |
      Compression level to use when compressing; 0 to 9, or -1 for default [-1]
    type: int?
    inputBinding:
      prefix: "--compress-level"
  threads:
    label: threads
    doc: |
      number of compression threads to use [1]
    type: int?

outputs:
  compressed_output_vcf_file:
    label: compressed output vcf file
    doc: |
      The bgzipped (and indexed?) vcf file
    type: File
    outputBinding:
      glob: "$(inputs.uncompressed_vcf_file.basename).gz"
    secondaryFiles:
      - pattern: ".tbi"
        required: false

successCodes:
  - 0
