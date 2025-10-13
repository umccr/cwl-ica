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
id: dragen-parse-fastq-list-row--2.0.0
label: dragen-parse-fastq-list-row v(2.0.0)
doc: |
    Documentation for dragen-parse-fastq-list-row v2.0.0


# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/2.0.0/fastq-list-row__2.0.0.yaml

# Inputs/Outputs
inputs:
  fastq_list_row:
    label: fastq list row
    doc: |
      fastq list row
    type:
      - "null"
      - ../../../schemas/fastq-list-row/2.0.0/fastq-list-row__2.0.0.yaml#fastq-list-row

outputs:
  fastq_list_row_output:
    label: fastq list row output
    doc: |
      fastq list row output
    type:
      - "null"
      - ../../../schemas/fastq-list-row/2.0.0/fastq-list-row__2.0.0.yaml#fastq-list-row

expression: |
  ${
    return {
      "fastq_list_row_output": inputs.fastq_list_row
    };
  }