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
id: dragen-parse-fastq-list-rows-input--2.0.0
label: dragen-parse-fastq-list-rows-input v(2.0.0)
doc: |
    Documentation for dragen-parse-fastq-list-rows-input v2.0.0

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
      - $import: ../../../schemas/fastq-list-row/2.0.0/fastq-list-row__2.0.0.yaml
      - $import: ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml

inputs:
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Fastq list rows
    type:
      - "null"
      - ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml#fastq-list-rows-input

steps:
  # This step doesn't actually run
  # Run Singular fastq-list-row
  parse_fastq_list_row:
    # Never
    when: |
      ${
        return false;
      }
    in:
      fastq_list_row:
        source: fastq_list_rows
        valueFrom: |
          ${
            if (self) {
              return self[0];
            } else {
              return null;
            };
          }
    out:
      - fastq_list_row_output
    run: ../../../expressions/dragen-parse-fastq-list-row/2.0.0/dragen-parse-fastq-list-row__2.0.0.cwl
  # Run Multiple fastq-list-rows
  parse_fastq_list_rows:
    # Never
    when: |
      ${
        return false;
      }
    in:
      fastq_list_rows:
        source: fastq_list_rows
        valueFrom: |
          ${
            if (self) {
              return self;
            } else {
              return null;
            };
          }
    out:
      - fastq_list_rows_output
    run: ../../../expressions/dragen-parse-fastq-list-rows/2.0.0/dragen-parse-fastq-list-rows__2.0.0.cwl

# Nothing was ever run, so we never have any outputs
outputs: []

