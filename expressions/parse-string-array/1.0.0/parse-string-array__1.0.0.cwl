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
id: parse-string-array--1.0.0
label: parse-string-array v(1.0.0)
doc: |
    Parse an array of strings. Useful in situations where the source needs to be a string, but the file needs to come from the valueFrom expression.

inputs:
  input_string_array:
    label: string_array
    doc: |
      An array of stringegers
    type: string[]

outputs:
  output_string_array:
    label: output string array
    doc: |
      Output array of stringegers (identical to the input)
    type: string[]

expression: >-
  ${
    return {"output_string_array": inputs.input_string_array};
  }
