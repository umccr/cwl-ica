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
id: dragen-parse-snv-variant-caller-schema--4.4.4
label: dragen-parse-snv-variant-caller-schema v(4.4.4)
doc: |
    Documentation for dragen-parse-snv-variant-caller-schema
    v4.4.4

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml

# Inputs / Outputs
inputs:
  snv_variant_caller_options_input:
    label: alignment options input
    doc: |
      Alignment options or null
    type: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml#dragen-snv-variant-caller-options

outputs:
  snv_variant_caller_options_output:
    label: alignment options output
    doc: |
      Alignment options
    type:
      - "null"
      - ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml#dragen-snv-variant-caller-options


expression: |
  ${
    return {
      "snv_variant_caller_options_output": inputs.snv_variant_caller_options_input
    };
  }