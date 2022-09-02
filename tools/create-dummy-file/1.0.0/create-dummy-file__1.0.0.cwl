cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
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

hints:
    ResourceRequirement:
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
