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
id: tso500-ctdna-with-post-processing-pipeline--1.2.0--1.0.0
label: tso500-ctdna-with-post-processing-pipeline v(1.2.0--1.0.0)
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
        - $import: ../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0.yaml
        - $import: ../../../schemas/tso500-outputs-by-sample/1.0.0/tso500-outputs-by-sample__1.0.0.yaml
        - $import: ../../../schemas/custom-output-dir-entry/2.0.1/custom-output-dir-entry__2.0.1.yaml

inputs:
  # All of the inputs to the standard tso500 ctdna post processing pipeline
  tso500_samples:
    label: tso500 samples
    doc: |
      A list of tso500 samples each element has the following attributes:
      * sample_id
      * sample_type
      * pair_id
      * fastq list rows
    type: ../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0.yaml#tso500-sample[]
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
  # Workarounds
  coerce_valid_index:
    label: coerce valid index
    doc: |
      Coerce the valid index
    type: boolean?
    default: false


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
      file_basename:
        valueFrom: "TST500C_manifest.bed"
    out:
      - id: output_file
    run: ../../../expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.cwl

  get_sample_ids_from_tso500_sample_object:
    label: get sample ids from tso500 sample objects
    doc: |
      Generate a list of sample ids from the tso500 sample objects
    scatter: tso500_sample_object
    in:
      tso500_sample_object:
        source: tso500_samples
      attribute_name:
        valueFrom: "sample_id"
    out:
      - id: attribute_value
    run: ../../../expressions/get-attr-from-tso500-sample-object/1.2.0/get-attr-from-tso500-sample-object__1.2.0.cwl

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
      coerce_valid_index:
        source: coerce_valid_index
    out:
      - results
      - outputs_by_sample
      - samplesheet_validation_demux_dir
    run: ../../../workflows/tso500-ctdna/1.2.0--1/tso500-ctdna__1.2.0--1.cwl

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
        source: get_tso_manifest_bed_from_resources_dir/output_file
    out:
      - id: post_processing_output_directory
    run: ../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.cwl

  ##########################################
  # Get intermediate samplesheet from folder
  ##########################################
  get_intermediate_samplesheet_from_validation_step:
    label: get intermediate samplesheet from validation step
    doc: |
      Get the intermediate samplesheet from the validation step.
      Returns a V1 samplesheet
    in:
      input_dir:
        source: run_tso_ctdna_workflow_step/samplesheet_validation_demux_dir
      file_basename:
        valueFrom: "SampleSheet_Intermediate.csv"
    out:
      - id: output_file
    run: ../../../expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.cwl

  ######################################
  # Create the final directory structure
  ######################################

  # First create an expression to create the final directory structure schema
  get_final_directory_output_for_tso500_pipeline:
    label: create output directory
    doc: |
      Create the output directory containing all the files and directories listed in the previous step.
    in:
      per_sample_post_processing_output_dirs:
        source: run_tso_ctdna_post_processing_workflow_step/post_processing_output_directory
      results_dir:
        source: run_tso_ctdna_workflow_step/results
      samplesheet_csv:
        source: get_intermediate_samplesheet_from_validation_step/output_file
    out:
      - id: tso500_output_dir_entry_list
    run: ../../../expressions/get-custom-output-dir-entry-for-tso500-with-post-processing/2.0.1/get-custom-output-dir-entry-for-tso500-with-post-processing__2.0.1.cwl

  # Then create the final directory structure
  create_final_output_directory:
    label: create output directory
    doc: |
      Create the output directory containing all the files listed in the previous step.
    in:
      output_directory_name:
        valueFrom: "Results"
      custom_output_dir_entry_list:
        source: get_final_directory_output_for_tso500_pipeline/tso500_output_dir_entry_list
    out:
      - id: output_directory
    run: ../../../tools/custom-create-directory/2.0.1/custom-create-directory__2.0.1.cwl

  # Collect the sample directory as an output
  get_sample_output_directory:
    label: sample output directory
    doc: |
      The sample output directory containing all of the samples post-processing files
    scatter: sub_directory_basename
    in:
      input_dir:
        source: create_final_output_directory/output_directory
      sub_directory_basename:
        source: get_sample_ids_from_tso500_sample_object/attribute_value
    out:
      - output_directory
    run: ../../../expressions/get-subdirectory-from-directory/1.0.0/get-subdirectory-from-directory__1.0.0.cwl

outputs:
  output_results_dir:
    label: output results dir
    doc: |
      The output directory
    type: Directory
    outputSource: create_final_output_directory/output_directory
  output_results_dir_by_sample:
    label: output results dir by sample
    doc: |
      The sample subdirectory of the results
    type: Directory[]
    outputSource: get_sample_output_directory/output_directory
