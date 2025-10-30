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
id: dragen-create-aligner-options-object--4.4.0
label: dragen-create-aligner-options-object v(4.4.0)
doc: |
  Documentation for dragen-create-aligner-options-object
  v4.4.0

requirements:
  InlineJavascriptRequirement: { }
  ScatterFeatureRequirement: { }
  MultipleInputFeatureRequirement: { }
  StepInputExpressionRequirement: { }
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-aligner-options/4.4.0/dragen-aligner-options__4.4.0.yaml
      - $import: ../../../schemas/dragen-mapper-options/4.4.0/dragen-mapper-options__4.4.0.yaml

inputs:
  aligner_options:
    label: aligner options
    doc: |
      Input file, of varying format depending on the command run
    type: ../../../schemas/dragen-aligner-options/4.4.0/dragen-aligner-options__4.4.0.yaml#dragen-aligner-options

steps:
  parse_aligner_options:
    in:
      aligner_options_input:
        source: aligner_options
        valueFrom: |
          ${
            return self;
          }
    out:
      - id: aligner_options_output
    run: ../../../expressions/dragen-parse-aligner-schema/4.4.0/dragen-parse-aligner-schema__4.4.0.cwl

outputs:
  aligner_options_output:
    label: aligner options output
    doc: |
      Output file, of varying format depending on the command run
    outputSource: parse_aligner_options/aligner_options_output
    type: ../../../schemas/dragen-aligner-options/4.4.0/dragen-aligner-options__4.4.0.yaml#dragen-aligner-options
