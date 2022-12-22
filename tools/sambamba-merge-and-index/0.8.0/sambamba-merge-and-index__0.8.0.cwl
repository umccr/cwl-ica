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
id: sambamba-merge-and-index--0.8.0
label: sambamba-merge-and-index v(0.8.0)
doc: |
  Merge a list of bam files and then index the merged bam file
  Uses sambamba merge command.
  More info can be found [here](https://lomereiter.github.io/sambamba/docs/sambamba-merge.html)

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
  InitialWorkDirRequirement:
    listing:
      - entryname: sambamba-merge-and-index.sh
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Run the sambamba sort command
          eval sambamba merge '"\${@}"'

          # Index the output file
          sambamba index "$(inputs.output_filename)"

baseCommand: [ "bash", "sambamba-merge-and-index" ]

arguments:
  - prefix: "--nthreads"
    valueFrom: "$(get_num_threads())"
    position: 1

inputs:
  # Mandatory args
  bams_sorted:
    label: bams sorted
    doc: |
      Array of sorted bam files
    type: File[]
    inputBinding:
      # After all other args
      position: 100
  output_filename:
    label: output filename
    doc: |
      Name of merged output bam
    type: string
    inputBinding:
      # After all others but before input bams
      position: 99
  # Optional args
  compression_level:
    label: compression level
    doc: |
      level of compression for sorted BAM, from 0 to 9
    type: int?
    inputBinding:
      prefix: "--compression-level"
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

outputs:
  bam_indexed:
    label: output bam
    doc: |
      Output indexed bam file
    type: File
    outputBinding:
      glob: "$(inputs.output_filename)"
    secondaryFiles:
      - .bai

successCodes:
  - 0