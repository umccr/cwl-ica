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
id: dragen-parse-cram-input--1.0.0
label: dragen-parse-cram-input v(1.0.0)
doc: |
  Documentation for dragen-parse-cram-input v1.0.0

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml

# Inputs/Outputs
inputs:
  cram_input:
    label: cram
    doc: |
      cram
    type:
      - "null"
      - ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml#cram-input

outputs:
  cram_output:
    label: cram output
    doc: |
      cram output
    type:
      - "null"
      - ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml#cram-input

expression: |
  ${
    return {
      "cram_output": inputs.cram_input
    };
  }
