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
id: custom-create-directory--1.0.0
label: custom-create-directory v(1.0.0)
doc: |
  Documentation for custom-create-directory v1.0.0
  Create a directory based on a list of inputs generated as input files or input directories

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/ICA_CLI/Content/SW/ICA/IAPWES_RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            type: standardHiCpu
            size: small
        coresMin: 15.5
        ramMin: 28
    DockerRequirement:
        dockerPull: umccr/alpine-rsync:3.2.3

requirements:
  InlineJavascriptRequirement: {}

# Runs a simple rsync command over the input files and input directories
baseCommand: [ "rsync" ]

arguments:
  - position: -1
    valueFrom: "--archive"

# Inputs and outputs
inputs:
  input_files:
    label: input files
    doc: |
      List of input files to go into the output directory
    type: File[]?
    inputBinding:
      position: 1
  input_directories:
    label: input directories
    doc: |
      List of input directories to go into the output directory
    type: Directory[]?
    inputBinding:
      position: 2
      # Strip trailing slash to ensure directory becomes a subdirectory
      valueFrom: |
        ${
          return self.map(function(a) {return a.path.replace(/\/$/, "")});
        }
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string
    inputBinding:
      position: 3
      valueFrom: |
        ${
          return self.replace(/\/$/, "") + "/";
        }

outputs:
  output_directory:
    label: output directory
    doc: |
      The output directory with all of the outputs collected
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory_name)"

successCodes:
  - 0
