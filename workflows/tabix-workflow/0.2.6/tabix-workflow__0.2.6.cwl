cwlVersion: v1.1
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
id: tabix-workflow--0.2.6
label: tabix-workflow v(0.2.6)
doc: |
    Just run the tabix tool

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
  vcf_file:
    label: vcf file
    doc: |
      The input vcf file to be indexed
    type: File

steps:
  run_tabix_step:
    label: run tabix step
    doc: |
      Run tabix workflow
    in:
      vcf_file:
        source: vcf_file
    out:
      - id: vcf_file_indexed
    run: ../../../tools/tabix/0.2.6/tabix__0.2.6.cwl

outputs:
  vcf_file_indexed:
    label: vcf file indexed
    doc: |
      The indexed vcf file
    type: File
    outputSource: run_tabix_step/vcf_file_indexed
