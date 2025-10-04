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
        - $import: ../../../schemas/dragen-qc-coverage/1.0.0/dragen-qc-coverage__1.0.0.yaml

        # Sub-import schema support
        - $import: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-cnv-caller-options/4.4.4/dragen-cnv-caller-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-maf-conversion-options/4.4.4/dragen-maf-conversion-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-sv-caller-options/4.4.4/dragen-sv-caller-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-nirvana-annotation-options/4.4.4/dragen-nirvana-annotation-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-targeted-caller-options/4.4.4/dragen-targeted-caller-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-mrjd-options/4.4.4/dragen-mrjd-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-msi-options/4.4.4/dragen-msi-options__4.4.4.yaml
        - $import: ../../../schemas/dragen-tmb-options/4.4.4/dragen-tmb-options__4.4.4.yaml

        # Dragen options
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
