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
      # Data inputs
      - $import: ../../../schemas/fastq-list-row/2.0.0/fastq-list-row__2.0.0.yaml
      - $import: ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml
      - $import: ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml
      - $import: ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml
      - $import: ../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0.yaml

      # Nested schemas
      - $import: ../../../schemas/dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4.yaml

      # Options schemas
      - $import: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-rna-gene-fusion-detection-options/4.4.4/dragen-rna-gene-fusion-detection-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.4/dragen-rna-gene-expression-quantification-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-rna-splice-variant-caller-options/4.4.4/dragen-rna-splice-variant-caller-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-maf-conversion-options/4.4.4/dragen-maf-conversion-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-nirvana-annotation-options/4.4.4/dragen-nirvana-annotation-options__4.4.4.yaml

      # Stage schemas
      - $import: ../../../schemas/dragen-wgts-options-alignment-stage/4.4.4/dragen-wgts-options-alignment-stage__4.4.4.yaml
      - $import: ../../../schemas/dragen-wgts-rna-options-variant-calling-stage/4.4.4/dragen-wgts-rna-options-variant-calling-stage__4.4.4.yaml

inputs:
  dragen_options:
    type:
      - ../../../schemas/dragen-wgts-rna-options-variant-calling-stage/4.4.4/dragen-wgts-rna-options-variant-calling-stage__4.4.4.yaml#dragen-wgts-rna-options-variant-calling-stage


steps:
  # Run dragen variant-calling pipeline
  run_dragen_variant_calling_step:
    in:
      dragen_options:
        source: dragen_options
    out:
      - id: output_directory
    run: ../../../tools/dragen-wgts-rna-variant-calling-step/4.4.4/dragen-wgts-rna-variant-calling-step__4.4.4.cwl


outputs:
  output_directory:
    type: Directory
    outputSource: run_dragen_variant_calling_step/output_directory
    doc: |
      The output directory of the DRAGEN variant calling pipeline.
