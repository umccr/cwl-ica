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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: custome-create-directory--1.0.1
label: custome-create-directory v(1.0.1)
doc: |
    Documentation for custome-create-directory v1.0.1
    Create a directory based on **content** of list of input directories, i.e. not the
    directory itself. rsync interprets a directory with no trailing slash as copy this directory, 
    and a directory with a trailing slash as copy the contents of this directory.  

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources:tier: standard
        ilmn-tes:resources:type: standardHiCpu
        ilmn-tes:resources:size: small
        coresMin: 15
        ramMin: 28
    DockerRequirement:
        dockerPull: ghcr.io/umccr/alpine-rsync:3.2.3

requirements:
  InlineJavascriptRequirement: {}

# Runs a simple rsync command over the input files and input directories
baseCommand: [ "rsync" ]

arguments:
  - position: 1
    valueFrom: -a

# Inputs and outputs
inputs:
  input_directories:
    label: input directories
    doc: |
      List of input directories to go into the output directory
    type: Directory[]?
    inputBinding:
      position: 2
      valueFrom: |
        ${
          return self.map(function(a) {return a["path"] + "/"});
        }
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string
    inputBinding:
      position: 3

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

