cwlVersion: v1.1
class: ExpressionTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: http://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: flatten-array-fastq-list-schema--1.0.0
label: flatten-array-fastq-list-schema v(1.0.0)
doc: |
    Documentation for flatten-array-fastq-list-schema v1.0.0

requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
inputs:
  arrayTwoDim:
    label: two dim array
    doc: |
      two dimensional array with fastq list row
    type:
      type: array
      items:
        type: array
        items: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row
    inputBinding:
      loadContents: true

outputs:
  array1d:
    label: one dim array
    doc: |
      one dimensional array
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]

expression: >
  ${
    var newArray= [];
    for (var i = 0; i < inputs.arrayTwoDim.length; i++) {
      for (var k = 0; k < inputs.arrayTwoDim[i].length; k++) {
        newArray.push((inputs.arrayTwoDim[i])[k]);
      }
    }
    return { 'array1d' : newArray }
  }
