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
id: multiqc--1.14.0
label: multiqc v(1.14.0)
doc: |
    Documentation for multiqc v1.14.0

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: large
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: public.ecr.aws/biocontainers/multiqc:1.14--pyhdfd78af_0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_input_dir = function(){
          /*
          Just returns the name of the input directory
          */
          return "multiqc_input_dir";
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: run_multiqc.sh
        entry: |
          #!/usr/bin/env bash

          # Set up to fail
          set -euo pipefail

          # Create input dir
          mkdir "$(get_input_dir())"

          # Create an array of dirs
          input_dir_path_array=( $(inputs.input_directories.map(function(a) {return '"' + a.path + '"';}).join(' ')) )
          input_dir_basename_array=( $(inputs.input_directories.map(function(a) {return '"' + a.basename + '"';}).join(' ')) )

          # Iterate through input direcotires
          for input_dir_path in "\${input_dir_path_array[@]}"; do
            ln -s "\${input_dir_path}" "$(get_input_dir())/"
          done

          # Run multiqc
          eval multiqc '"\${@}"'

          # Unlink input directories - otherwise ICA tries to upload them onto gds (and fails)
          for input_dir_basename in "\${input_dir_basename_array[@]}"; do
            unlink "$(get_input_dir())/\${input_dir_basename}"
          done


baseCommand: ["bash", "run_multiqc.sh"]

arguments:
  - position: 100
    valueFrom: "$(get_input_dir())"

inputs:
  # Required inputs
  input_directories:
    label: input directories
    doc: |
      The list of directories to place in the analysis
    type: Directory[]
  output_directory_name:
    label: output directory
    doc: |
      The output directory
    type: string
    inputBinding:
      prefix: "--outdir"
      valueFrom: "$(runtime.outdir)/$(self)"
  output_filename:
    label: output filename
    doc: |
      Report filename in html format.
      Defaults to 'multiqc-report.html"
    type: string
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
  comment:
    label: comment
    doc: |
      Custom comment, will be printed at the top of the report.
    type: string?
    inputBinding:
      prefix: "--comment"
  config:
    label: config
    doc: |
      Configuration file for bclconvert
    type: File?
    streamable: true
    inputBinding:
      prefix: "--config"
  cl_config:
    label: cl config
    doc: |
      Override config from the cli
    type: string?
    inputBinding:
      prefix: "--cl-config"
  dummy_file:
    label: dummy file
    doc: |
      testing inputs stream logic
      If used will set input mode to stream on ICA which
      saves having to download the entire input folder
    type: File?
    streamable: true


outputs:
  output_directory:
    label: output directory
    doc: |
      Directory that contains all multiqc analysis data
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory_name)"
  output_file:
    label: output file
    doc: |
      Output html file
    type: File
    outputBinding:
      glob: "$(inputs.output_directory_name)/$(inputs.output_filename)"

successCodes:
  - 0
