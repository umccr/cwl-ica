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
id: multiqc-interop--1.2.1
label: multiqc-interop v(1.2.1)
doc: |
    Producing QC report using interop matrix

hints:
  ResourceRequirement:
    ilmn-tes:resources: 
      type: standard
      size: medium
    coresMin: 1
    ramMin: 4000
  DockerRequirement:
    dockerPull: umccr/multiqc_dragen:1.2.1

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: generate_interop_files.sh
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Generate interop files
          interop_summary --csv=1 "$(inputs.input_directory.path)" > interop_summary.csv
          interop_index-summary --csv=1 "$(inputs.input_directory.path)" > interop_index-summary.csv
      - entryname: run_multiqc_interop.sh
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail
          
          # multiqc interop module needs to run a series of commands 
          # ref: https://github.com/umccr-illumina/stratus/blob/806c76609af4755159b12cf5302d4e4e11cc614b/TES/multiqc.json
          echo "Generating interop files" 1>&2
          bash generate_interop_files.sh

          # Now run multiqc
          echo "Running multiqc" 1>&2
          eval multiqc --module interop '"\${@}"' interop_summary.csv interop_index-summary.csv


baseCommand: ["bash", "run_multiqc_interop.sh"]

inputs:
  # Required inputs
  input_directory:
    label: input directory
    doc: |
      The bcl directory
    type: Directory
    inputBinding:
      position: 100
  output_directory_name:
    label: output directory
    doc: |
      The output directory, defaults to "multiqc-outdir"
    type: string?
    default: "multiqc-outdir"
    inputBinding:
      prefix: "--outdir"
  output_filename:
    label: output filename
    doc: |
      Report filename in html format.
      Defaults to 'multiqc-report.html'
    type: string?
    default: "multiqc-report.html"
    inputBinding:
      prefix: "--filename"
  title:
    label: title
    doc: |
      Report title.
      Printed as page header, used for filename if not otherwise specified.
    type: string
    inputBinding:
      prefix: "--title"
  dummy_file:
    label: dummy file
    doc: |
      testing inputs stream logic
      If used will set input mode to stream on ICA which
      saves having to download the entire input folder
    type: File?
    streamable: true

outputs:
  interop_multi_qc_out:
    label: multiqc output
    doc: |
      output dircetory with interop multiQC matrices
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory_name)"


successCodes:
  - 0
