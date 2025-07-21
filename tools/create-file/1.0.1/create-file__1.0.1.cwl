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
id: create-file--1.0.1
label: create-file v(1.0.1)
doc: |
    Documentation for create-file v1.0.1

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

requirements:
  InitialWorkDirRequirement:
    listing:
      - writable: true
        entryname: $(inputs.basename)
        entry: $(inputs.file_object)

baseCommand: ["true"]


inputs:
  basename:
    label: basename
    type: string
    doc: |
      The name of the file to be created.
  contents:
    label: contents
    type: string?
    doc: |
      The contents of the file to be created.
      If not provided, an empty file will be created OR the contents used by location
  file_object:
    label: file_object
    type: File
    doc: |
      A file object that contains the contents of the file to be created.
      This can be used instead of contents

outputs:
  output_file:
    type: File
    label: output_file
    doc: |
      The output file created by the expression tool.
    outputBinding:
      outputEval: |
        ${
            if (inputs.contents === null){
              return {
                  "class": "File",
                  "basename": inputs.basename,
                  "path": inputs.basename
                };
            } else {
              return {
                "class": "File",
                "basename": inputs.basename,
                "path": inputs.location,
                "contents": inputs.contents
              };
            }
        }

successCodes:
  - 0
