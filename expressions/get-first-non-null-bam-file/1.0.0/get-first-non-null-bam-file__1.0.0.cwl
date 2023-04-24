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
id: get-first-non-null-bam-file--1.0.0
label: get-first-non-null-bam-file v(1.0.0)
doc: |
    Documentation for get-first-non-null-bam-file v1.0.0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/utils/1.0.0/utils__1.0.0.cwljs

inputs:
  input_bams:
    label: input bams
    doc: |
      Array of input bams
    type:
      - type: array
        items:
          - "null"
          - File

outputs:
  output_bam_file:
    label: output_bam_file
    doc: |
      First non null bam file in the array
    type: File?
    secondaryFiles:
      - pattern: ".bai"
        required: false

expression: |
  ${
    return {"output_bam_file": get_first_non_null_input(inputs.input_bams)};
  }
