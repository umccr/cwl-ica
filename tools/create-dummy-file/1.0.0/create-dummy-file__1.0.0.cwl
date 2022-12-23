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
id: create-dummy-file--1.0.0
label: create-dummy-file v(1.0.0)
doc: |
    Create a dummy file for input into a workflow.
    Important if needing to set a tool into 'stream' mode by default

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: standard
    ilmn-tes:resources/size: small
    coresMin: 2
    ramMin: 4000
  DockerRequirement:
    dockerPull: alpine:latest

baseCommand: ["touch", "dummy_file.txt"]

inputs: []

outputs:
  dummy_file_output:
    label: dummy file output
    doc: |
      Output dummy file
    type: File
    outputBinding:
      glob: "dummy_file.txt"

successCodes:
  - 0
