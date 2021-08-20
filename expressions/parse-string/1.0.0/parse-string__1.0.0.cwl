cwlVersion: v1.1
class: ExpressionTool

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

requirements:
  InlineJavascriptRequirement: {}

# ID/Docs
id: parse-string--1.0.0
label: parse-string v(1.0.0)
doc: |
    Parse an string. Useful in situations where the source needs to be a string, but the file needs to come from the valueFrom expression.

inputs:
  input_string:
    label: input string
    doc: |
      The input stringeger
    type: string

outputs:
  output_string:
    label: output string
    doc: |
      The same as the input stringeger
    type: string

expression: >-
  ${
    return {"output_string": inputs.input_string};
  }
