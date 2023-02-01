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
id: umccrise-pipeline--2.2.0--0
label: umccrise-pipeline v(2.2.0--0)
doc: |
    Documentation for umccrise-pipeline v2.2.0--0

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
  # Input folders and files
  dragen_somatic_directory:
    label: dragen somatic directory
    doc: |
      The dragen somatic directory
    type: Directory
  dragen_germline_directory:
    label: dragen germline directory
    doc: |
      The dragen germline directory
    type: Directory
  genomes_tar:
    label: genomes tar
    doc: |
      The reference umccrise tarball
    type: File
  # Input IDs
  subject_identifier:
    label: subject identifier
    doc: |
      The subject ID (used to name output files)
    type: string
  dragen_tumor_id:
    label: dragen tumor id
    doc: |
      The name of the dragen tumor sample
    type: string
  dragen_normal_id:
    label: dragen normal id
    doc: |
      The name of the dragen normal sample
    type: string
  # Output names
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string
  # Optional inputs
  threads:
    label: threads
    doc: |
      Number of threads to use
    type: int?

steps:
  run_umccrise_step:
    label: run umccrise
    doc: |
      Run the UMCCRise CommandLine Tool
    in:
      dragen_somatic_directory:
        source: dragen_somatic_directory
      dragen_germline_directory:
        source: dragen_germline_directory
      genomes_tar:
        source: genomes_tar
      subject_identifier:
        source: subject_identifier
      dragen_tumor_id:
        source: dragen_tumor_id
      dragen_normal_id:
        source: dragen_normal_id
      output_directory_name:
        source: output_directory_name
      threads:
        source: threads
    out:
      - id: output_directory
    run: ../../../tools/umccrise/2.2.0--0/umccrise__2.2.0--0.cwl

outputs:
  umccrise_output_directory:
    label: umccrise output directory
    doc: |
      The output directory containing all umccrise output files
    type: Directory
    outputSource: run_umccrise_step/output_directory
