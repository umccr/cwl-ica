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
id: validate-bclconvert-samplesheet--4.0.3
label: validate-bclconvert-samplesheet v(4.0.3)
doc: |
    Documentation for validate-bclconvert-samplesheet v4.0.3

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/bclconvert-run-configuration-expressions/2.0.0--4.0.3/bclconvert-run-configuration-expressions__2.0.0--4.0.3.cwljs
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  bclconvert_run_input_directory:
    label: bclconvert run input directory
    doc: |
      The input directory for BCLConvert
    type: Directory
  bclconvert_run_configuration:
    label: bclconvert run configuration
    doc: |
      The BCLConvert run configuration
    type: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml#bclconvert-run-configuration

steps:
  # Get run info file from the run input directory
  get_run_info_file_from_directory_expression_step:
    label: get run info file from directory expression step
    doc: |
      Get the run info file from the bclconvert run input directory
    in:
      input_dir:
        source: bclconvert_run_input_directory
      file_basename:
        valueFrom: "RunInfo.xml"
    out:
      - id: output_file
    run: ../../../expressions/get-file-from-directory/1.0.1/get-file-from-directory__1.0.1.cwl

  # Get samplesheet from the bclconvert run input directory
  # Use this as a backup if there isn't one in the run configuration
  get_samplesheet_file_from_directory_expression_step:
    label: get samplesheet file from directory expression step
    doc: |
      Samplesheet may be left blank, in which case we need to extract it from the bclconvert directory
    in:
      input_dir:
        source: bclconvert_run_input_directory
      file_basename:
        valueFrom: "SampleSheet.csv"
    out:
      - id: output_file
    run: ../../../expressions/get-file-from-directory/1.0.1/get-file-from-directory__1.0.1.cwl

  # Get samplesheet either as an object or a file
  get_samplesheet_step:
    label: get samplesheet step
    doc: |
      Get samplesheet based on priority. If defined in bclconvert run configuration take that,
      otherwise take the output from the previous step
    in:
      samplesheet:
        source: [ bclconvert_run_configuration, get_samplesheet_file_from_directory_expression_step/output_file ]
        valueFrom: |
          ${
            var samplesheet = get_attribute_from_bclconvert_run_configuration(self[0], "samplesheet");
            if ( samplesheet !== undefined && samplesheet !== null ){
              return samplesheet;
            }
            return self[1];
          }
    out:
      - id: samplesheet_out
    run: ../../../expressions/parse-samplesheet/2.0.0--4.0.3/parse-samplesheet__2.0.0--4.0.3.cwl

  # Get the bclconvert run configuration
  get_bcl_convert_run_configuration_object_step:
    label: get bclconvert run configuration object step
    doc: |
      Get bcl convert run configuration object step for samplesheet validation.  
      This means that the bcl_validate_sample_sheet_only is set to true and we
      have the run_info and samplesheet parameters set
    in:
      bclconvert_run_configuration:
        source: [bclconvert_run_configuration, get_samplesheet_step/samplesheet_out, get_run_info_file_from_directory_expression_step/output_file]
        valueFrom: |
          ${
            return create_bcl_configuration_object_for_samplesheet_validation(self[0], self[1], self[2]);
          }
    out:
      - id: bclconvert_run_configuration_out
    run: ../../../expressions/parse-bclconvert-run-configuration-object/2.0.0--4.0.3/parse-bclconvert-run-configuration-object__2.0.0--4.0.3.cwl

  # Create fake directory for bclconvert tests bcl-input-directory is a required parameter
  create_dummy_directory_step:
    label: create dummy directory step
    doc: |
      Create a fake directory for the bclconvert run input directory
    in: {}
    out:
      - id: output_directory
    run: ../../../tools/create-dummy-directory/1.0.0/create-dummy-directory__1.0.0.cwl

  # Configuration checks

  # Validate samplesheets
  bcl_convert_samplesheet_check_step:
    label: bcl convert samplesheet check step
    doc: |
      Run BCLConvert with the --bcl-validate-sample-sheet-only parameter set to true
    in:
      # Mandatory options
      bclconvert_run_input_directory:
        source: create_dummy_directory_step/output_directory
      bclconvert_run_configuration:
        source: get_bcl_convert_run_configuration_object_step/bclconvert_run_configuration_out
    out:
      - id: bcl_convert_directory_output
      # - id: fastq_list_rows  # Fastq list csv will be empty since this is only a validation run
      - id: samplesheet_out
      - id: run_info_out
    run: ../../../workflows/bclconvert/4.0.3/bclconvert__4.0.3.cwl

outputs:
  run_info_out:
    label: run info out
    doc: |
      Output runinfo file that's been validated
    type: File
    outputSource: bcl_convert_samplesheet_check_step/run_info_out
  samplesheet_out:
    label: samplesheet out
    doc: |
      Output samplesheet that's been validated
    type: File
    outputSource: bcl_convert_samplesheet_check_step/samplesheet_out
