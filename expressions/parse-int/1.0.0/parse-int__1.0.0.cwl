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

requirements:
  InlineJavascriptRequirement: {}

# ID/Docs
id: parse-int--1.0.0
label: parse-int v(1.0.0)
doc: |
    Parse an int. Useful in situations where the source needs to be a string, but the file needs to come from the valueFrom expression.

inputs:
  input_int:
    label: input int
    doc: |
      The input integer
    type: int

outputs:
  output_int:
    label: output int
    doc: |
      The same as the input integer
    type: int

expression: >-
  ${
    return {"output_int": inputs.input_int};
  }
