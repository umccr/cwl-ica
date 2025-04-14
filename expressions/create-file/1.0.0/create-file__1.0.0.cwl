cwlVersion: v1.1
class: ExpressionTool

# Extensions
$namespaces:
    s: https://schema.org/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: create-file--1.0.0
label: create-file v(1.0.0)
doc: |
    Documentation for create-file v1.0.0

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
  location:
    label: location
    type: string
    doc: |
      This might be the location of an existing file and can be used to create a new file with the same contents.

outputs:
  output_file:
    type: File
    label: output_file
    doc: |
      The output file created by the expression tool.

expression: |
  ${
    return {
      "output_file": {
        "class": "File",
        "basename": inputs.basename,
        "contents": inputs.contents,
        "location": inputs.location
      }
    };
  }