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
id: bclconvert-scatter--4.0.3
label: bclconvert-scatter v(4.0.3)
doc: |
    Documentation for bclconvert-scatter v4.0.3

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  bclconvert_run_input_directory:
    label: bclconvert run input directory
    doc: |
      The input directory for BCLConvert
    type: Directory
  bclconvert_run_configurations:
    label: bclconvert run configurations
    doc: |
      The BCLConvert run configuration jsons
    type: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml#bclconvert-run-configuration[]

steps:
  # Scatter and validate samplesheets
  bcl_convert_samplesheet_check_scatter_step:
    label: bcl convert samplesheet check step
    doc: |
      Run BCLConvert with the --bcl-validate-sample-sheet-only parameter set to true
    scatter: bclconvert_run_configuration
    in:
      bclconvert_run_input_directory:
        source: bclconvert_run_input_directory
      bclconvert_run_configuration:
        source: bclconvert_run_configurations
    out:
      - samplesheet_out
      - run_info_out
    run: ../../../workflows/validate-bclconvert-samplesheet/4.0.3/validate-bclconvert-samplesheet__4.0.3.cwl

  # Parse output runInfo between workflows
  get_bcl_convert_run_configuration_object_step:
    label: get bclconvert run configuration object step
    doc: |
      Get bcl convert run configuration object step for samplesheet validation.  
      This means that the bcl_validate_sample_sheet_only is set to true and we
      have the run_info and samplesheet parameters set
    scatter: [bclconvert_run_configuration, run_info, samplesheet]
    scatterMethod: dotproduct
    in:
      bclconvert_run_configuration:
        source: bclconvert_run_configurations
      run_info:
        source: bcl_convert_samplesheet_check_scatter_step/run_info_out
      samplesheet:
        source: bcl_convert_samplesheet_check_scatter_step/samplesheet_out
    out:
      - id: bclconvert_run_configuration_out
    run: ../../../expressions/add-run-info-and-samplesheet-to-bclconvert-run-configuration/2.0.0--4.0.3/add-run-info-and-samplesheet-to-bclconvert-run-configuration__2.0.0--4.0.3.cwl

  # Scatter and run bclconvert for each run configuration
  bcl_convert_scatter_step:
    label: bcl convert samplesheet check step
    doc: |
      Run BCLConvert with the --bcl-validate-sample-sheet-only parameter set to true
    scatter: bclconvert_run_configuration
    in:
      bclconvert_run_input_directory:
        source: bclconvert_run_input_directory
      bclconvert_run_configuration:
        source: get_bcl_convert_run_configuration_object_step/bclconvert_run_configuration_out
    out:
      - id: bcl_convert_directory_output
      - id: fastq_list_rows
      - id: samplesheet_out
    run: ../../../workflows/bclconvert/4.0.3/bclconvert__4.0.3.cwl

  # Flatten the array of output fastq_list_rows.
  flatten_fastq_list_rows_array_step:
    label: flatten fastq list rows array
    doc: |
      fastq list rows is an array and bcl convert is from a directory output.
      This scatters the arrays to a single array
    in:
      array_two_dim: bcl_convert_scatter_step/fastq_list_rows
    out:
      - id: array1d
    run: ../../../expressions/flatten-array-fastq-list/1.0.0/flatten-array-fastq-list__1.0.0.cwl

outputs:
  fastq_output_directories:
    label: fastq output directories
    doc: |
      Directories to output fastq files
    type: Directory[]
    outputSource: bcl_convert_scatter_step/bcl_convert_directory_output
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Directories to fastq list rows
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
    outputSource: flatten_fastq_list_rows_array_step/array1d
  samplesheets:
    label: samplesheets
    doc: |
      List of samplesheets used to convert
    type: File[]
    outputSource: bcl_convert_scatter_step/samplesheet_out
