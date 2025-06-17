cwlVersion: v1.2
class: Workflow

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
id: dragen-create-wgts-dna-variant-calling-options-object--4.4.4
label: dragen-create-wgts-dna-variant-calling-options-object v(4.4.4)
doc: |
  Documentation for dragen-create-wgts-dna-variant-calling-options-object
  v4.4.4

requirements:
  SubworkflowFeatureRequirement: { }
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs
  ScatterFeatureRequirement: { }
  MultipleInputFeatureRequirement: { }
  StepInputExpressionRequirement: { }
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-sv-caller-options/4.4.4/dragen-sv-caller-options__4.4.4.yaml

inputs:
  snv_variant_caller_options:
    label: dragen-cnv-caller-options
    doc: |
      dragen-cnv-caller-options
    type: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml#dragen-snv-variant-caller-options
  sv_caller_options:
    label: dragen-cnv-caller-options
    doc: |
      dragen-cnv-caller-options
    type: ../../../schemas/dragen-sv-caller-options/4.4.4/dragen-sv-caller-options__4.4.4.yaml#dragen-sv-caller-options

steps:
  parse_snv_variant_caller_options:
    in:
      snv_variant_caller_options_input: snv_variant_caller_options
    out:
      - id: snv_variant_caller_options_output
    run: ../../../tools/dragen-parse-snv-variant-caller-schema/4.4.4/dragen-parse-snv-variant-caller-schema__4.4.4.cwl
  parse_sv_caller_options:
    in:
      sv_caller_options_input: sv_caller_options
    out:
      - id: sv_caller_options_output
    run: ../../../tools/dragen-parse-sv-caller-schema/4.4.4/dragen-parse-sv-caller-schema__4.4.4.cwl

outputs:
  snv_variant_caller_options_output:
    label: snv_variant_caller_options_output
    doc: |
      snv_variant_caller_options_output
    outputSource: parse_snv_variant_caller_options/snv_variant_caller_options_output
    type: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml#dragen-snv-variant-caller-options
  sv_caller_options_output:
    label: sv_caller_options_output
    doc: |
      sv_caller_options_output
    outputSource: parse_sv_caller_options/sv_caller_options_output
    type: ../../../schemas/dragen-sv-caller-options/4.4.4/dragen-sv-caller-options__4.4.4.yaml#dragen-sv-caller-options


