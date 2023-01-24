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
id: illumina-interop-qc--1.2.0--1.14.0
label: illumina-interop-qc v(1.2.0--1.14.0)
doc: |
    Documentation for illumina-interop-qc v1.2.0--1.14.0

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
  # Directory inputs
  input_run_dir:
    label: input run directory
    doc: |
      The bcl directory
    type: Directory
  # Multiqc Configurations
  multiqc_output_directory_name:
    label: multiqc output directory name
    doc: |
      Name of the output directory for multiqc
    type: string
  multiqc_output_filename:
    label: multiqc output filename
    doc: |
      The name of the multiqc output file
    type: string
  multiqc_title:
    label: multiqc title
    doc: |
      The name of the title for multiqc
    type: string
  multiqc_comment:
    label: multiqc comment
    doc: |
      Any commentary to place in the multiqc report
    type: string?
  multiqc_config:
    label: multiqc config
    doc: |
      Configuration file for multiqc
    type: File?
  multiqc_cl_config:
    label: multiqc cl config
    doc: |
      Configuration via the cli for multiqc
    type: string?


steps:
  # Create dummy file for streaming on icav1
  create_dummy_file_step:
    label: Create dummy file
    doc: |
      Intermediate step for letting interop be placed in stream mode
    in: {}
    out:
      - id: dummy_file_output
    run: ../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl
  # Run illumina interop
  illumina_interop_step:
    label: illumina interop step
    doc: |
      Call illumina interop step
    in:
      input_run_dir: input_run_dir
      dummy_file: create_dummy_file_step/dummy_file_output
    out:
      - id: interop_outdir
    run: ../../../tools/illumina-interop/1.2.0/illumina-interop__1.2.0.cwl
  # Run multiqc step
  multiqc_step:
    label: multiqc step
    doc: |
      Run multiqc on interop summary files
    in:
      # Directory inputs
      input_directories:
        source: illumina_interop_step/interop_outdir
        valueFrom: |
          ${
            return [ self ];
          }
      # Multiqc Configurations
      output_directory_name: multiqc_output_directory_name
      output_filename: multiqc_output_filename
      title: multiqc_title
      comment: multiqc_comment
      config: multiqc_config
      cl_config: multiqc_cl_config
    out:
      - id: output_directory
      - id: output_file
    run: ../../../tools/multiqc/1.14.0/multiqc__1.14.0.cwl

outputs:
  multiqc_output_dir:
    label: multiqc output directory
    doc: |
      The multiqc output directory
    type: Directory
    outputSource: multiqc_step/output_directory
  multiqc_output_file:
    label: multiqc output file
    doc: |
      HTML output file
    type: File
    outputSource: multiqc_step/output_file
  illumina_interop_dir:
    label: illumina interop directory
    doc: |
      The illumina interop output directory
    type: Directory
    outputSource: illumina_interop_step/interop_outdir
