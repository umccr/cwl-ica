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
id: dragen-parse-sequence-data--1.0.0
label: dragen-parse-sequence-data v(1.0.0)
doc: |
    Documentation for dragen-parse-sequence-data v1.0.0

requirements:
  SubworkflowFeatureRequirement: { }
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  SchemaDefRequirement:
    types:
      # Input schemas
      - $import: ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml
      - $import: ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml
      - $import: ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml

inputs:
  sequence_data:
    label: sequence data
    doc: |
      Sequence data object
    type:
      - ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml#fastq-list-rows-input
      - ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml#bam-input
      - ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml#cram-input

steps:
  parse_fastq_list_rows_step:
    # Purely for the purposes of packing cwl correctly, we also need to manually parse every sub-schema that is imported
    # This step does not actually run anything
    # Never
    when: |
      ${
        return false;
      }
    in:
      fastq_list_rows:
        source: sequence_data
        valueFrom: |
          ${
            if (self.fastq_list_rows) {
              return self.fastq_list_rows;
            } else {
              return null
            };
          }
    out: [ ]
    run: ../../dragen-parse-fastq-list-rows-input/2.0.0/dragen-parse-fastq-list-rows-input__2.0.0.cwl

  parse_bam_input_step:
    # Purely for the purposes of packing cwl correctly, we also need to manually parse every sub-schema that is imported
    # This step does not actually run anything
    # Never
    when: |
      ${
        return false;
      }
    in:
      bam_input:
        source: sequence_data
        valueFrom: |
          ${
            if (self.bam_input) {
              return self.bam_input;
            } else {
              return null
            };
          }
    out: [ ]
    run: ../../../expressions/dragen-parse-bam-input/1.0.0/dragen-parse-bam-input__1.0.0.cwl

  parse_cram_input_step:
    # Purely for the purposes of packing cwl correctly, we also need to manually parse every sub-schema that is imported
    # This step does not actually run anything
    # Never
    when: |
      ${
        return false;
      }
    in:
      cram_input:
        source: sequence_data
        valueFrom: |
          ${
            if (self.cram_input) {
              return self.cram_input;
            } else {
              return null
            };
          }
    out: [ ]
    run: ../../../expressions/dragen-parse-cram-input/1.0.0/dragen-parse-cram-input__1.0.0.cwl

outputs: []
