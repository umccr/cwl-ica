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
id: sambamba-sort-and-index--0.8.0
label: sambamba-sort-and-index v(0.8.0)
doc: |
  Sort a bam file and then index it.
  Uses sambamba sort command.
  More info can be found [here](https://lomereiter.github.io/sambamba/docs/sambamba-sort.html)

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: xlarge
        coresMin: 4
        ramMin: 14000
    DockerRequirement:
        dockerPull: quay.io/biocontainers/sambamba:0.8.0--h984e79f_0

baseCommand: ["bash", "sambamba-sort-and-index.sh"]

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_num_threads = function(){
          /*
          Returns the number of threads if specified
          Otherwise returns runtime.cores value
          */
          if (inputs.nthreads !== null){
            return inputs.nthreads;
          } else {
            return runtime.cores;
          }
        }
      - var get_memory_limit = function(){
          /*
          Returns the value of --memory-limit
          Otherwise returns runtime.ram value
          */
          if (inputs.memory_limit !== null){
            return inputs.memory_limit;
          } else {
            return runtime.ram + "M";
          }
        }
      - var boolean_to_string = function(input_obj){
          /*
          Returns false if null else returns .toString of object
          */
          if (input_obj === null){
            return "false";
          } else {
            return input_obj.toString();
          }
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: sambamba-sort-and-index.sh
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Run the sambamba sort command
          eval sambamba sort '"\${@}"'

          # Index the output file (if coordinate sorted only)
          if [[ "$(boolean_to_string(inputs.sort_by_name))" == "false" ]]; then
            sambamba index "$(inputs.output_filename)"
          fi

arguments:
  - prefix: "--memory-limit"
    valueFrom: "$(get_memory_limit())"
    position: 1
  - prefix: "--nthreads"
    valueFrom: "$(get_num_threads())"
    position: 1

inputs:
  # Mandatory args
  bam_unsorted:
    label: bam unsorted
    doc: |
      Unsorted bam file
    type: File
    inputBinding:
      position: 100
  output_filename:
    label: output filename
    doc: |
      Name of sorted output bam
    type: string
    inputBinding:
      prefix: "--out"
  # Optional args
  sort_by_name:
    label: sort by name
    doc: |
      sort by read name instead of coordinate (lexicographical order)
    type: boolean?
    inputBinding:
      prefix: "--sort-by-name"
  compression_level:
    label: compression level
    doc: |
      level of compression for sorted BAM, from 0 to 9
    type: int?
    inputBinding:
      prefix: "--compression-level"
  uncompressed_chunks:
    label: uncompressed chunks
    doc: |
      write sorted chunks as uncompressed BAM (default is writing with compression level 1),
      that might be faster in some cases but uses more disk space
    type: boolean?
    inputBinding:
      prefix: "--uncompressed-chunks"
  filter:
    label: filter
    doc: |
      Keep only reads that satisfy FILTER
    type: string?
    inputBinding:
      prefix: "--filter"
  # Runtime args
  nthreads:
    label: nthreads
    doc: |
      Use specified number of threads
    type: int?
  memory_limit:
    label: memory limit
    doc: |
      approximate total memory liimit for all threads
    type: string?

outputs:
  bam_sorted:
    label: output bam
    doc: |
      Output indexed bam file
    type: File
    outputBinding:
      glob: "$(inputs.output_filename)"
    secondaryFiles:
      # Exists only if bam file is coordinate sorted
      - .bai

successCodes:
  - 0
