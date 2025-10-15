cwlVersion: v1.2
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
id: dragen-parse-qc-coverage-schema--1.0.0
label: dragen-parse-qc-coverage-schema v(1.0.0)
doc: |
  Documentation for dragen-parse-qc-coverage-schema v1.0.0

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-qc-coverage/1.0.0/dragen-qc-coverage__1.0.0.yaml

# Inputs/Outputs
inputs:
  dragen_qc_coverage_options_input:
    label: alignment options input
    doc: |
      Alignment options or null
    type:
      - "null"
      - ../../../schemas/dragen-qc-coverage/1.0.0/dragen-qc-coverage__1.0.0.yaml#dragen-qc-coverage

outputs:
  dragen_qc_coverage_options_output:
    label: alignment options output
    doc: |
      Alignment options
    type:
      - "null"
      - ../../../schemas/dragen-qc-coverage/1.0.0/dragen-qc-coverage__1.0.0.yaml#dragen-qc-coverage

expression: |
  ${
    return {
      "dragen_qc_coverage_options_output": inputs.dragen_qc_coverage_options_input
    };
  }