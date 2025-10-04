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
id: dragen-wgts-parse-alignment-schema--4.4.4
label: dragen-wgts-parse-alignment-schema v(4.4.4)
doc: |
    Documentation for dragen-wgts-parse-alignment-schema v4.4.4

# Requirements
requirements:
  InlineJavascriptRequirement: { }
  SchemaDefRequirement:
    types:
      # Nested schemas
      - $import: ../../../schemas/dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-qc-coverage/1.0.0/dragen-qc-coverage__1.0.0.yaml

      # I/O schemas
      - $import: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml

# Inputs / outputs
inputs:
  dragen_wgts_alignment_options:
    label: dragen wgts alignment options
    doc: |
      Alignment options or null
    type: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml#dragen-wgts-alignment-options

outputs:
  dragen_wgts_alignment_options_output:
    label: dragen wgts alignment options output
    doc: |
      Dragen wgts alignment options output
    type: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml#dragen-wgts-alignment-options

# Expression
expression: |
  ${
    return {
      "dragen_wgts_alignment_options_output": inputs.dragen_wgts_alignment_options
    };
  }
