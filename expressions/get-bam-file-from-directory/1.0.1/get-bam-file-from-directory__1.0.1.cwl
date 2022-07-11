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
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: get-bam-file-from-directory--1.0.1
label: get-bam-file-from-directory v(1.0.1)
doc: |
    Documentation for get-bam-file-from-directory v1.0.1

requirements:
  LoadListingRequirement:
    loadListing: deep_listing
  InlineJavascriptRequirement:
    expressionLib:
      - $import: ./typescript-expressions/get_bam_file_from_directory.cwljs

inputs:
  input_dir:
    label: input dir
    doc: |
      Input directory with the bam file present
    type: Directory
  bam_nameroot:
    label: bam nameroot
    doc: |
      nameroot of the bam file
    type: string


outputs:
  bam_file:
    label: bam file
    doc: |
      The bam file output with the .bai attribute
    type: File
    secondaryFiles:
      - pattern: ".bai"
        required: true


expression: >-
  ${
    return {"bam_file": get_bam_file_from_directory(inputs.input_dir, inputs.bam_nameroot, true)};
  }
