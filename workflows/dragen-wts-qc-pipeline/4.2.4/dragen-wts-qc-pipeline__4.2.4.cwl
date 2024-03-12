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
id: dragen-wts-qc-pipeline--4.2.4
label: dragen-wts-qc-pipeline v(4.2.4)
doc: |
    Documentation for dragen-wts-qc-pipeline v4.2.4

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml

inputs:
  # Option 1
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process. read_1 and read_2 components in the CSV file must be presigned urls.
    type: File?
  # Option 2
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
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
  # Option 3
  bam_input:
    label: bam input
    doc: |
      Input a BAM file for WTS analysis
    type: File?
    secondaryFiles:
      - pattern: ".bai"
        required: true
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
  # Transcript annotation file
  annotation_file:
    label: annotation file
    doc: |
      Path to annotation transcript file.
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
  # Alignment options
  enable_map_align:
    label: enable map align
    doc: |
      Enabled by default.
      Set this value to false if using bam_input AND tumor_bam_input
    type: boolean?
  enable_map_align_output:
    label: enable map align output
    doc: |
      Do you wish to have the output bam files present
    type: boolean
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Mark identical alignments as duplicates
    type: boolean
  enable_sort:
    label: enable sort
    doc: |
      True by default, only set this to false if using --bam-input as input parameter
    type: boolean?
  # Quantification options
  enable_rna_quantification:
    label: enable rna quantification
    type: boolean?
    doc: |
      Optional - Enable the quantification module - defaults to true
  # Fusion calling options
  enable_rna_gene_fusion:
    label: enable rna gene fusion
    type: boolean?
    doc: |
      Optional - Enable the DRAGEN Gene Fusion module - defaults to true
  # qualimap inputs
  java_mem:
    label: java mem
    type: string?
    doc: |
      Set desired Java heap memory size
    default: "96G"
  algorithm:
    label: algorithm
    type: string?
    doc: |
      Counting algorithm:
      uniquely-mapped-reads(default) or proportional.
    default: "proportional"
  tmp_dir:
    label: tmp dir
    type: string?
    doc: |
      Qualimap creates temporary bam files when sorting by name, which takes up space in the system tmp dir (usually /tmp). 
      This can be avoided by sorting the bam file by name before running Qualimap.
    default: "/scratch"
  # Location of license
  lic_instance_id_location:
    label: license instance id location
    doc: |
      You may wish to place your own in.
      Optional value, default set to /opt/instance-identity
      which is a path inside the dragen container
    type:
      - File?
      - string?

steps:
  # Step-1: Run Dragen transcriptome workflow
  run_dragen_transcriptome_step:
    label: run dragen transcriptome step
    doc: |
      Runs the dragen transcriptome workflow on the FPGA.
      Takes in a fastq list and corresponding mount paths from the predefined_mount_paths.
      All other options avaiable at the top of the workflow
    in:
      # Input fastq files to dragen
      # Option 1
      fastq_list:
        source: fastq_list
      # Option 2
      fastq_list_rows:
        source: fastq_list_rows
      # Option 3
      bam_input:
        source: bam_input
      reference_tar:
        source: reference_tar
      output_file_prefix:
        source: output_file_prefix
      output_directory:
        source: output_directory
      enable_map_align:
        source: enable_map_align
      enable_map_align_output:
        source: enable_map_align_output
      enable_duplicate_marking:
        source: enable_duplicate_marking
      enable_sort:
        source: enable_sort
      annotation_file:
        source: annotation_file
      enable_rna_quantification:
        source: enable_rna_quantification
      enable_rna_gene_fusion:
        source: enable_rna_gene_fusion
      lic_instance_id_location:
        source: lic_instance_id_location
    out:
      - id: dragen_transcriptome_directory
      - id: dragen_bam_out
    run: ../../../tools/dragen-transcriptome/4.2.4/dragen-transcriptome__4.2.4.cwl
  # Step-2: Run qualimap
  run_qualimap_step:
    label: run qualimap step
    doc: |
      Run qualimap step to generate additional QC metrics
    in: 
      tmp_dir:
        source: tmp_dir
      java_mem:
        source: java_mem
      algorithm:
        source: algorithm
      out_dir:
        source: output_directory
        valueFrom: "$(self)_qualimap"
      gtf:
        source: annotation_file
      input_bam:
        source: run_dragen_transcriptome_step/dragen_bam_out
    out:
      - id: qualimap_qc
    run: ../../../tools/qualimap/2.2.2/qualimap__2.2.2.cwl
outputs:
  # The dragen output directory
  dragen_transcriptome_output_directory:
    label: dragen transcriptome output directory
    doc: |
      The output directory containing all transcriptome output files
    type: Directory
    outputSource: run_dragen_transcriptome_step/dragen_transcriptome_directory
  # The qualimap output directory
  qualimap_output_directory:
    label: dragen transcriptome output directory
    doc: |
      The output directory containing all transcriptome output files
    type: Directory
    outputSource: run_qualimap_step/qualimap_qc
