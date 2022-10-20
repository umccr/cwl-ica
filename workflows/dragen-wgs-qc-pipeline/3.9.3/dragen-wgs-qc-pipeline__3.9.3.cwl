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
id: dragen-wgs-qc-pipeline--3.9.3
label: dragen-wgs-qc-pipeline v(3.9.3)
doc: |
    Documentation for dragen-wgs-qc-pipeline v3.9.3

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SubworkflowFeatureRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml

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
  # Dragen alignment options
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Mark identical alignments as duplicates
    type: boolean
  enable_map_align_output:
    label: enable map align output
    doc: |
      Do you wish to have the output bam files present
    type: boolean
  enable_sort:
    label: enable sort
    doc: |
      The map/align system produces a BAM file sorted by 
      reference sequence and position by default.
    type: boolean
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
  # Step-1: run subworkflow that mainly calls Dragen and multiQC
  run_dragen_step:
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
      enable_map_align_output:
        source: enable_map_align_output
      enable_duplicate_marking:
        source: enable_duplicate_marking
      enable_sort:
        source: enable_sort
    out:
      - id: dragen_alignment_output_directory
      - id: dragen_bam_out
      - id: multiqc_output_directory
    run: ../../../workflows/dragen-alignment-pipeline/3.9.3/dragen-alignment-pipeline__3.9.3.cwl

outputs:
  # All output files will be under the output directory
  dragen_alignment_output_directory:
    label: dragen alignment output directory
    doc: |
      The output directory containing all alignment output files and qc metrics
    type: Directory
    outputSource: run_dragen_step/dragen_alignment_output_directory
  # Whilst these files reside inside the output directory, specifying them here as outputs
  # provides easier access and reference
  dragen_bam_out:
    label: dragen bam out
    doc: |
      The output alignment file
    type: File
    outputSource: run_dragen_step/dragen_bam_out
  # multiQC output
  multiqc_output_directory:
    label: dragen QC report out
    doc: |
      The dragen multiQC output
    type: Directory
    outputSource: run_dragen_step/multiqc_output_directory

