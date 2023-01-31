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
id: bclconvert-with-qc-pipeline--4.0.3
label: bclconvert-with-qc-pipeline v(4.0.3)
doc: |
    Documentation for bclconvert-with-qc-pipeline v4.0.3

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
  runfolder_name:
    label: runfolder name
    doc: |
      Name to use in multiqc outputs
    type: string

steps:
  # First step - for streaming bclconvert run input directory
  # Of interop qc and multiqc output directories
  create_dummy_file_step:
    label: create dummy file
    doc: |
      Intermediate step for letting multiqc-interop be placed in stream mode
    in: { }
    out:
      - id: dummy_file_output
    run: ../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl

  # Run interop qc on the BCLConvert directory
  interop_qc_step:
    label: interop qc step
    doc: |
      Run illumina interop on the run
    in:
      input_run_dir:
        source: bclconvert_run_input_directory
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - id: interop_outdir
    run: ../../../tools/illumina-interop/1.2.0/illumina-interop__1.2.0.cwl

  # Run bclconvert scatter over directory
  run_bclconvert_step:
    label: run bclconvert step
    doc: |
      Runs the bcl convert configurations through the validation check and then through BCLConvert
    in:
      bclconvert_run_input_directory:
        source: bclconvert_run_input_directory
      bclconvert_run_configurations:
        source: bclconvert_run_configurations
    out:
      - fastq_output_directories
      - fastq_list_rows
      - samplesheets
    run: ../../../workflows/bclconvert-scatter/4.0.3/bclconvert-scatter__4.0.3.cwl

  # Run multiqc on the outputs of the bclconvert pipeline
  # Create a bclconvert specific report
  bclconvert_qc_step:
    label: bclconvert qc step
    doc: |
      The bclconvert qc step - from scatter this takes in an array of dirs
    # This allows us to run the bclconvert multiqc module over the array of directories
    in:
      input_directories:
        source:
          - run_bclconvert_step/fastq_output_directories
          - interop_qc_step/interop_outdir
        linkMerge: merge_flattened
      output_directory_name:
        source: runfolder_name
        valueFrom: "$(self)_bclconvert_multiqc"
      output_filename:
        source: runfolder_name
        valueFrom: "$(self)_bclconvert_multiqc.html"
      title:
        source: runfolder_name
        valueFrom: "UMCCR MultiQC BCLConvert report for $(self)"
      cl_config:
        valueFrom: |
          ${
             return JSON.stringify({"bclconvert": { "genome_size": "hg38_genome" }});
           }
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.12.0/multiqc__1.12.0.cwl

outputs:
  samplesheets:
    label: samplesheets
    doc: |
      Array of file locations pointing to the samplesheets
    type: File[]
    outputSource: run_bclconvert_step/samplesheets
  fastq_directories:
    label: fastq directories
    doc: |
      Array of directories pointing to the fastq locations
    type: Directory[]
    outputSource: run_bclconvert_step/fastq_output_directories
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Array of fastq list rows
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
    outputSource: run_bclconvert_step/fastq_list_rows
  bclconvert_multiqc_out:
    label: bclconvert multiqc out
    doc: |
      bclconvert multiqc out
    type: Directory
    outputSource: bclconvert_qc_step/output_directory