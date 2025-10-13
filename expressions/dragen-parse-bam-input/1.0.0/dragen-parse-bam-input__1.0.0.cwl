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
id: dragen-parse-bam-input--1.0.0
label: dragen-parse-bam-input v(1.0.0)
doc: |
    Documentation for dragen-parse-bam-input v1.0.0

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml

# Inputs/Outputs
inputs:
  bam_input:
    label: bam
    doc: |
      bam
    type:
      - "null"
      - ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml#bam-input

outputs:
  bam_output:
    label: bam output
    doc: |
      bam output
    type:
      - "null"
      - ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml#bam-input

expression: |
  ${
    return {
      "bam_output": inputs.bam_input
    };
  }
