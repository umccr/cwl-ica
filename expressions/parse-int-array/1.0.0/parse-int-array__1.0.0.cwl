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

# ID/Docs
id: parse-int-array--1.0.0
label: parse-int-array v(1.0.0)
doc: |
    Parse an array of ints. Useful in situations where the source needs to be a string, but the file needs to come from the valueFrom expression.

inputs:
  input_int_array:
    label: int_array
    doc: |
      An array of integers
    type: int[]


outputs:
  output_int_array:
    label: output int array
    doc: |
      Output array of integers (identical to the input)
    type: int[]

expression: >-
  ${
    return {"output_int_array": inputs.input_int_array};
  }
