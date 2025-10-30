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
id: dragen-create-mapper-options-object--4.4.0
label: dragen-create-mapper-options-object v(4.4.0)
doc: |
  Documentation for dragen-create-mapper-options-object
  v4.4.0

requirements:
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-mapper-options/4.4.0/dragen-mapper-options__4.4.0.yaml
      - $import: ../../../schemas/dragen-aligner-options/4.4.0/dragen-aligner-options__4.4.0.yaml

inputs:
  mapper_options:
    label: mapper options
    doc: |
      Mapping options
    type: ../../../schemas/dragen-mapper-options/4.4.0/dragen-mapper-options__4.4.0.yaml#dragen-mapper-options

steps:
  parse_mapper_options:
    in:
      mapper_options_input:
        source: mapper_options
        valueFrom: |
          ${
            return self;
          }
    out:
      - id: mapper_options_output
    run: ../../../expressions/dragen-parse-mapper-schema/4.4.0/dragen-parse-mapper-schema__4.4.0.cwl

outputs:
  mapper_options_output:
    label: mapper options output
    doc: |
      Output file, of varying format depending on the command run
    outputSource: parse_mapper_options/mapper_options_output
    type: ../../../schemas/dragen-mapper-options/4.4.0/dragen-mapper-options__4.4.0.yaml#dragen-mapper-options
