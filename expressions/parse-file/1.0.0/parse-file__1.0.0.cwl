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
id: parse-file--1.0.0
label: parse-file v(1.0.0)
doc: |
    Parse a file. Useful in situations where the source needs to be a string, but the file needs to come from the valueFrom expression.

requirements:
  InlineJavascriptRequirement: {}

inputs:
  input_file:
    label: input file
    doc: |
      The input file
    type: File

outputs:
  output_file:
    label: output file
    doc: |
      Also the input file
    type: File

expression: >-
  ${
    return {"output_file": inputs.input_file};
  }
