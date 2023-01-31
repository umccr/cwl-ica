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
id: illumina-interop--1.2.0
label: illumina-interop v(1.2.0)
doc: |
    Documentation for illumina-interop v1.2.0 can be found here: https://github.com/Illumina/interop

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: small
        coresMin: 1
        ramMin: 3000
    DockerRequirement:
        dockerPull: public.ecr.aws/biocontainers/illumina-interop:1.2.0--h87f3376_0

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
          interop_summary --csv=1 "$(inputs.input_run_dir.path)" > "$(inputs.output_dir_name)/interop_summary.csv"
          interop_index-summary --csv=1 "$(inputs.input_run_dir.path)" > "$(inputs.output_dir_name)/interop_index-summary.csv"


baseCommand: [ "bash", "generate_interop_files.sh" ]

inputs:
  # Required inputs
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
  dummy_file:
    label: dummy file
    doc: |
      testing inputs stream logic
      If used will set input mode to stream on ICA which
      saves having to download the entire input folder
    type: File?
    streamable: true

outputs:
  interop_outdir:
    label: multiqc output
    doc: |
      output directory
    type: Directory
    outputBinding:
      glob: "$(inputs.output_dir_name)"

successCodes:
  - 0