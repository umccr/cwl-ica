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
id: dragen-parse-fastq-list-rows--2.0.0
label: dragen-parse-fastq-list-rows v(2.0.0)
doc: |
    Documentation for dragen-parse-fastq-list-rows v2.0.0

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      # Nested schemas
      - $import: ../../../schemas/fastq-list-row/2.0.0/fastq-list-row__2.0.0.yaml
      # Input schema
      - $import: ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml

# Inputs/Outputs
inputs:
  fastq_list_rows:
    label: fastq list rows
    doc: |
      fastq list rows
    type:
      - "null"
      - ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml#fastq-list-rows-input

outputs:
  fastq_list_rows_output:
    label: fastq list rows output
    doc: |
      fastq list rows output
    type:
      - "null"
      - ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml#fastq-list-rows-input

expression: |
  ${
    return {
      "fastq_list_rows_output": inputs.fastq_list_rows
    };
  }