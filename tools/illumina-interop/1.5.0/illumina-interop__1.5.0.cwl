cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
  s: https://schema.org/
  ilmn-tes: https://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: illumina-interop--1.5.0
label: illumina-interop v(1.5.0)
doc: |
  Run illumina-interop v1.5.0, this tool

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources:tier: standard
    ilmn-tes:resources:type: standard
    ilmn-tes:resources:size: small
    coresMin: 2
    ramMin: 4000
  DockerRequirement:
    dockerPull: ghcr.io/umccr/illumina-interop:1.5.0

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: generate_interop_files.sh
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail
          
          # Create output directory
          mkdir "$(inputs.output_dir_name)"

          # Generate interop files
          interop_summary --csv=1 --level=4 "$(inputs.input_run_dir.path)" > "$(inputs.output_dir_name)/$(inputs.instrument_run_id).csv"
          interop_index-summary --csv=1 "$(inputs.input_run_dir.path)" > "$(inputs.output_dir_name)/$(inputs.instrument_run_id).csv"

          # Generate imaging table
          interop_imaging_table "$(inputs.input_run_dir.path)" > "$(inputs.output_dir_name)/imaging_table.csv"

          # Generate imaging plot
          interop_imaging_plot "$(inputs.output_dir_name)/imaging_table.csv" "$(inputs.output_dir_name)/imaging_plot.png" "$(inputs.input_run_dir.basename)"

          # Compress imaging table
          gzip "$(inputs.output_dir_name)/imaging_table.csv"

baseCommand: [ "bash", "generate_interop_files.sh" ]

inputs:
  # Required inputs
  instrument_run_id:
    label: instrument run id
    doc: |
      The instrument run id, e.g. "C123456789"
    type: string
  input_run_dir:
    label: input run directory
    doc: |
      The bcl directory
    type: Directory
    inputBinding:
      position: 100
  output_dir_name:
    label: output directory
    doc: |
      The output directory, defaults to "interop_summary_files"
    type: string?
    default: "interop_summary_files"


outputs:
  interop_out_dir:
    label: interop output
    doc: |
      output directory
    type: Directory
    outputBinding:
      glob: "$(inputs.output_dir_name)"

successCodes:
  - 0