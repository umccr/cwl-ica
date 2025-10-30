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
id: dragen-parse-sv-caller-schema--4.4.0
label: dragen-parse-sv-caller-schema v(4.4.0)
doc: |
    Documentation for dragen-parse-sv-caller-schema v4.4.0

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-sv-caller-options/4.4.0/dragen-sv-caller-options__4.4.0.yaml

# Inputs/Outputs
inputs:
  sv_caller_options_input:
    label: alignment options input
    doc: |
      Alignment options or null
    type: ../../../schemas/dragen-sv-caller-options/4.4.0/dragen-sv-caller-options__4.4.0.yaml#dragen-sv-caller-options

outputs:
  sv_caller_options_output:
    label: alignment options output
    doc: |
      Alignment options
    type:
      - "null"
      - ../../../schemas/dragen-sv-caller-options/4.4.0/dragen-sv-caller-options__4.4.0.yaml#dragen-sv-caller-options


expression: |
  ${
    return {
      "sv_caller_options_output": inputs.sv_caller_options_input
    };
  }