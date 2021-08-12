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
id: tso500-ctdna-with-post-processing-pipeline--1.1.0--1.0.0
label: tso500-ctdna-with-post-processing-pipeline v(1.1.0--1.0.0)
doc: |
    Runs the tso500-ctdna pipeline then runs the post-processing pipeline over each sample
    Only intermediate step is collecting the tso500 bed file from the resources directory

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SubworkflowFeatureRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml
        - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
        - $import: ../../../schemas/tso500-outputs-by-sample/1.0.0/tso500-outputs-by-sample__1.0.0.yaml

inputs:
  # All of the inputs to the standadrd tso500 ctdna post processing pipeline
  tso500_samples:
    label: tso500 samples
    doc: |
      A list of tso500 samples each element has the following attributes:
      * sample_id
      * sample_type
      * pair_id
    type: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml#tso500-sample[]
  fastq_list_rows:
    label: fastq list rows
    doc: |
      A list of fastq list rows where each element has the following attributes
      * rgid  # Not used
      * rgsm
      * rglb  # Not used
      * read_1
      * read_2
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
  samplesheet:
    # No input binding required, samplesheet is placed in input.json
    label: sample sheet
    doc: |
      The sample sheet file, expects a V2 samplesheet.
      Even though we don't demultiplex, we still need the information on Sample_Type and Pair_ID to determine which
      workflow (DNA / RNA) to run through, we gather this through the tso500_samples input schema and then append to the
      samplesheet. Please make sure that the sample_id in the tso500 sample schema match the Sample_ID in the
      "<samplesheet_prefix>_Data" column.
    type: File
  samplesheet_prefix:
    label: samplesheet prefix
    doc: |
      Points to the TSO500 section of the samplesheet.  If you are using a samplesheet from BCLConvert,
      please set this to "BCLConvert"
    type: string?
    default: "TSO500L"
  # Run Info file
  run_info_xml:
    # Bound in listing expression
    label: run info xml
    doc: |
      The run info xml file found inside the run folder
    type: File
  # Run Parameters File
  run_parameters_xml:
    # Bound in listing expression
    label: run parameters xml
    doc: |
      The run parameters xml file found inside the run folder
    type: File
  # Reference inputs
  resources_dir:
    # No input binding required, directory path is placed in input.json
    label: resources dir
    doc: |
      The directory of resources
    type: Directory
  dragen_license_key:
    label: dragen license key
    doc: |
      File containing the dragen license
    type: File?


steps:
  ####################
  # Intermediate steps
  ####################
  get_tso_manifest_bed_from_resources_dir:
    label: get tso bed file from resources dir
    doc: |
      Given the resources directory collect the following file:
        * TST500C_manifest.bed
    in:
      input_dir:
        source: resources_dir
      file_basename_list:
        valueFrom: |
          ${
            return [
                     "TST500C_manifest.bed";
                   ];
          }
    out:
      - id: output_files
    run: ../../../expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.cwl
  parse_tso_manifest_file:
    label: parse tso manifest file
    doc: |
      Scatter used below, easier to parse file in here than use a valueFrom expression from within the scatter
    in:
      input_file:
        source: get_tso_manifest_bed_from_resources_dir/output_files
        valueFrom: |
          ${
            return self[0]
          }
    out:
      - id: output_file
    run: ../../../expressions/parse-file/1.0.0/parse-file__1.0.0.cwl

  ############################
  # Run the tso ctdna pipeline
  ############################
  run_tso_ctdna_workflow_step:
    label: run tso ctdna workflow step
    doc: |
      Run the CWL version of the tso500 ctDNA WDL / ISL workflow
    in:
      tso500_samples:
        source: tso500_samples
      fastq_list_rows:
        source: fastq_list_rows
      samplesheet:
        source: samplesheet
      samplesheet_prefix:
        source: samplesheet_prefix
      run_info_xml:
        source: run_info_xml
      run_parameters_xml:
        source: run_parameters_xml
      resources_dir:
        source: resources_dir
      dragen_license_key:
        source: dragen_license_key
    out:
      - outputs_by_sample
    run: ../../../workflows/tso500-ctdna/1.1.0--120/tso500-ctdna__1.1.0--120.cwl

  ############################################
  # Run the tso ctdna post processing pipeline
  ############################################
  run_tso_ctdna_post_processing_workflow_step:
    label: run tso ctdna post processing workflow step
    doc: |
      Run the very customised ctdna post processing workflow step for each sample
    # Scatter over each sample
    scatter: tso500_outputs_by_sample
    in:
      tso500_outputs_by_sample:
        source: run_tso_ctdna_workflow_step/outputs_by_sample
      tso_manifest_bed:
        source: parse_tso_manifest_file/output_file
    out:
      - id: post_processing_output_directory
    run: ../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.cwl

outputs:
  post_processing_output_dirs_by_sample:
    label: post processing output dirs by sample
    doc: |
      Each of the post processing output directories for each sample in the workflow
    type: Directory[]
    outputSource: run_tso_ctdna_post_processing_workflow_step/post_processing_output_directory
