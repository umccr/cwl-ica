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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: dragen-WGS-QC-pipeline--3.7.5
label: dragen-WGS-QC-pipeline v(3.7.5)
doc: |
    Documentation for dragen-alignment-pipeline v3.7.5

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SubworkflowFeatureRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
        - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml

inputs:
  # File inputs
  fastq_list_rows:
    label: Row of fastq lists
    doc: |
      The row of fastq lists.
      Each row has the following attributes:
        * RGID
        * RGLB
        * RGSM
        * Lane
        * Read1File
        * Read2File (optional)
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
  # Output naming options
  output_file_prefix:
    label: output file prefix
    doc: |
      The prefix given to all output files
    type: string
  output_directory:
    label: output directory
    doc: |
      The directory where all output files are placed
    type: string

steps:
  run_dragen_alignment_step:
    label: run dragen alignment step
    doc: |
      Runs the alignment step on a dragen fpga
      Takes in a fastq list and corresponding mount paths from the predefined mount paths
      All other options available at the top of the workflow
    in:
      fastq_list_rows:
        source: fastq_list_rows
      reference_tar:
        source: reference_tar
      output_file_prefix:
        source: output_file_prefix
      output_directory:
        source: output_directory
      # Output configurations
      enable_map_align:
        valueFrom: ${ return true; }
      enable_duplicate_marking:
        valueFrom: ${ return true; }
    out:
      - dragen_alignment_output_directory
      - dragen_bam_out
    run: ../../../workflows/dragen-alignment-pipeline/3.7.5/dragen-alignment-pipeline__3.7.5.cwl

  # Create dummy file
  create_dummy_file_step:
    label: Create dummy file
    doc: |
      Intermediate step for letting multiqc-interop be placed in stream mode
    in: {}
    out:
      - dummy_file_output
    run: ../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl

   # Create a Dragen specific report
  dragen_qc_step:
    label: dragen qc step
    doc: |
      The dragen qc step - this takes in an array of dirs
    requirements:
      DockerRequirement:
        dockerPull: umccr/multiqc-dragen:1.9
    in:
      input_directories:
        source: run_dragen_alignment_step/dragen_alignment_output_directory
        valueFrom: |
          ${
            return [self];
          }
      output_directory_name:
        source: output_file_prefix
        valueFrom: "$(self)_dragen_multiqc"
      output_filename:
        source: output_file_prefix
        valueFrom: "$(self)_dragen_multiqc.html"
      title:
        source: output_file_prefix
        valueFrom: "UMCCR MultiQC Dragen report for $(self)"
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - output_directory
    run: ../../../tools/multiqc/1.10.1/multiqc__1.10.1.cwl

outputs:
  # All output files will be under the output directory
  dragen_alignment_output_directory:
    label: dragen alignment output directory
    doc: |
      The output directory containing all alignment output files and qc metrics
    type: Directory
    outputSource: run_dragen_alignment_step/dragen_alignment_output_directory
  # Whilst these files reside inside the output directory, specifying them here as outputs
  # provides easier access and reference
  dragen_bam_out:
    label: dragen bam out
    doc: |
      The output alignment file
    type: File
    outputSource: run_dragen_alignment_step/dragen_bam_out
  #multiQC output
  output_directory:
    label: dragen QC report out
    doc: |
      The dragen multiQC output
    type: Directory
    outputSource: dragen_qc_step/output_directory
