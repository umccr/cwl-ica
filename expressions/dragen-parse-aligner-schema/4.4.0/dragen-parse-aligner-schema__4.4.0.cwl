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

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-aligner-options/4.4.0/dragen-aligner-options__4.4.0.yaml
    
# ID/Docs
id: dragen-parse-aligner-schema--4.4.0
label: dragen-parse-aligner-schema v(4.4.0)
doc: |
    Documentation for dragen-parse-aligner-schema v4.4.0

inputs:
  aligner_options_input:
    label: alignment options input
    doc: |
      Alignment options
    type: ../../../schemas/dragen-aligner-options/4.4.0/dragen-aligner-options__4.4.0.yaml#dragen-aligner-options


outputs:
  aligner_options_output:
    label: alignment options output
    doc: |
      Alignment options
    type: ../../../schemas/dragen-aligner-options/4.4.0/dragen-aligner-options__4.4.0.yaml#dragen-aligner-options


expression: |
  ${
    return {
      "aligner_options_output": inputs.aligner_options_input
    };
  }
