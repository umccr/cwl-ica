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
id: dragen-parse-mapper-schema--4.4.4
label: dragen-parse-mapper-schema v(4.4.4)
doc: |
    Documentation for dragen-parse-mapper-schema v4.4.4

# Requirements
requirements:
  InlineJavascriptRequirement: { }
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4.yaml

# Inputs/Outputs
inputs:
  mapper_options_input:
    label: alignment options input
    doc: |
      Alignment options or null
    type: ../../../schemas/dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4.yaml#dragen-mapper-options

outputs:
  mapper_options_output:
    label: alignment options output
    doc: |
      Alignment options
    type: ../../../schemas/dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4.yaml#dragen-mapper-options


expression: |
  ${
    return {
      "mapper_options_output": inputs.mapper_options_input
    };
  }