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
id: custom-create-dummy-file--1.0.0
label: custom-create-dummy-file v(1.0.0)
doc: |
    Documentation for custom-create-dummy-file v1.0.0

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: small
        coresMin: 1
        ramMin: 1000
    DockerRequirement:
        dockerPull: alpine:latest

requirements:
  InlineJavascriptRequirement: {}

baseCommand: ["touch"]

inputs:
  file_name:
    label: file name
    doc: |
      Name of the file to create
    type: string
    default: "dummy_file.txt"
    inputBinding:
      position: 1

outputs:
  dummy_file_output:
    label: dummy file
    doc: |
      Output dummy file
    type: File
    outputBinding:
      glob: "$(inputs.file_name)"

successCodes:
  - 0
