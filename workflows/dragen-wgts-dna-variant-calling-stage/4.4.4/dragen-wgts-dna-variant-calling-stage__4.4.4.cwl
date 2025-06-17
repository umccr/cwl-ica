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
id: dragen-variant-calling-stage--4.4.4
label: dragen-variant-calling-stage v(4.4.4)
doc: |
    Documentation for dragen-variant-calling-stage v4.4.0

requirements:
    InlineJavascriptRequirement:
      expressionLib:
        - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SubworkflowFeatureRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/dragen-wgts-dna-options-variant-calling-stage/4.4.4/dragen-wgts-dna-options-variant-calling-stage__4.4.4.yaml

inputs:
  dragen_options:
    type:
      - ../../../schemas/dragen-wgts-dna-options-variant-calling-stage/4.4.4/dragen-wgts-dna-options-variant-calling-stage__4.4.4.yaml#dragen-wgts-dna-options-variant-calling-stage


steps:
  # Run dragen variant-calling pipeline
  run_dragen_variant_calling_step:
    in:
      dragen_options:
        source: dragen_options
    out:
      - id: output_directory
    run: ../../../tools/dragen-wgts-dna-variant-calling-step/4.4.4/dragen-wgts-dna-variant-calling-step__4.4.4.cwl


outputs:
  output_directory:
    type: Directory
    outputSource: run_dragen_variant_calling_step/output_directory
    doc: |
      The output directory of the DRAGEN variant calling pipeline.
