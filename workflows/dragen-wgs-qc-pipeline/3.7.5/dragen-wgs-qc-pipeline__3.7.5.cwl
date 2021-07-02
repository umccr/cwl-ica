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
id: dragen-wgs-qc-pipeline--3.7.5
label: dragen-wgs-qc-pipeline v(3.7.5)
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
  # Somalier Options
  sites_somalier:
    label: sites somalier
    doc: |
      gzipped vcf file. Required for somalier sites
    type: File
    secondaryFiles:
      - pattern: ".tbi"
        required: true
  reference_fasta:
    label: reference fasta
    type: File
    doc: |
      FastA file with genome sequence
    secondaryFiles:
      - pattern: ".fai"
        required: true

steps:
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
      enable_map_align:
        valueFrom: ${ return true; }
      enable_duplicate_marking:
        valueFrom: ${ return true; }
    out:
      - id: dragen_alignment_output_directory
      - id: dragen_bam_out
      - id: multiqc_output_directory
    run: ../../../workflows/dragen-alignment-pipeline/3.7.5/dragen-alignment-pipeline__3.7.5.cwl

  # Step-4: run somalier
  run_somalier_step:
    label: somalier
    doc: |
      Runs the somalier extract function to call the fingerprint on the germline bam file
    in:
      bam_sorted:
        # The bam from the dragen germline workflow
        source: run_dragen_step/dragen_bam_out
      sites:
        # The VCF output file from the dragen command
        source: sites_somalier
      reference:
        # The reference fasta for the genome somalier
        source: reference_fasta
      sample_prefix:
        source: output_file_prefix
        # The output-prefix, if not specified just the sample name
      output_directory_name:
        source: output_directory
        valueFrom: "$(self)_somalier"
    out:
      - id: output_directory
    run: ../../../tools/somalier-extract/0.2.13/somalier-extract__0.2.13.cwl

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
  # Somalier outputs
  somalier_output_directory:
    label: somalier output directory
    doc: |
      Output directory from somalier step
    type: Directory
    outputSource: run_somalier_step/output_directory

