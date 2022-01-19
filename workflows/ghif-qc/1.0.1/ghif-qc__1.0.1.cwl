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
id: ghif-qc--1.0.1
label: ghif-qc v(1.0.1)
doc: |
    Documentation for ghif-qc v1.0.1

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
  #samtools stats
  output_filename:
    label: output filename
    doc: |
      Redirects stdout
    type: string
  input_bam:
    label: input BAM 
    doc: |
      The BAM file to gather statistics from
    type: File
    secondaryFiles:
      - pattern: ".bai"
        required: false
  coverage:
    label: coverage
    doc: |
      Set coverage distribution to the specified range (MIN, MAX, STEP all given as integers) [1,1000,1]
    type: int[]?
  remove_dups:
    label: remove dups
    doc: |
      Exclude from statistics reads marked as duplicates
    type: boolean?
  required_flag:
    label: required flag
    doc: |
      Required flag, 0 for unset. See also `samtools flags` [0]
    type: int?
  filtering_flag:
    label: filtering flag
    doc: |
      iltering flag, 0 for unset. See also `samtools flags` [0]
    type: int?
  GC_depth:
    label: GC depth 
    doc: |
      the size of GC-depth bins (decreasing bin size increases memory requirement) [2e4]
    type: float?
  insert_size:
    label: insert size 
    doc: |
      Maximum insert size [8000]
    type: int?
  id:
    label: id
    doc: |
      Include only listed read group or sample name []
    type: string?
  read_length:
    label: read length 
    doc: |
      Include in the statistics only reads with the given read length [-1]
    type: int?
  most_inserts:
    label: most inserts
    doc: |
      Report only the main part of inserts [0.99]
    type: float?
  split_prefix:
    label: split prefix
    doc: |
      A path or string prefix to prepend to filenames output when creating categorised 
      statistics files with -S/--split. [input filename]
    type: string?
  trim_quality:
    label: trim quality
    doc: |
      The BWA trimming parameter [0]
    type: int?
  ref_seq:
    label: ref seq
    doc: |
      Reference sequence (required for GC-depth and mismatches-per-cycle calculation). []
    type: File?
    secondaryFiles:
      - pattern: ".fai"
        required: true
  split:
    label: split
    doc: |
      In addition to the complete statistics, also output categorised statistics based on the tagged field TAG 
      (e.g., use --split RG to split into read groups).
    type: string?
  target_regions:
    label: target regions
    doc: |
      Do stats in these regions only. Tab-delimited file chr,from,to, 1-based, inclusive. []
    type: File?
  sparse:
    label: sparse
    doc: |
      Suppress outputting IS rows where there are no insertions.
    type: boolean?
  remove_overlaps:
    label: remove overlaps
    doc: |
      Remove overlaps of paired-end reads from coverage and base count computations.
    type: boolean?
  cov_threshold:
    label: cov threshold
    doc: |
      Only bases with coverage above this value will be included in the target percentage computation [0]
    type: int?
  threads:
    label: threads
    doc: |
      Number of input/output compression threads to use in addition to main thread [0].
    type: int?
  # custom-qc
  output_json_filename:
    label: output filename
    doc: |
      output file
    type: string
steps:
  # samtools stats
  samtools_stats_step:
    label: samtools stats step
    doc: samtools stats collects statistics from BAM files and outputs in a text format. 
         The output can be visualized graphically using plot-bamstats.
    in:
      output_filename:
        source: output_filename
      input_bam:
        source: input_bam
      coverage:
        source: coverage
      remove_dups:
        source: remove_dups
      required_flag:
        source: required_flag
      filtering_flag:
        source: filtering_flag
      GC_depth:
        source: GC_depth
      insert_size:
        source: insert_size
      read_length:
        source: read_length
      most_inserts:
        source: most_inserts
      split_prefix:
        source: split_prefix
      trim_quality:
        source: trim_quality
      ref_seq:
        source: ref_seq
      split:
        source: split
      target_regions:
        source: target_regions
      sparse:
        source: sparse
      remove_overlaps:
        source: remove_overlaps
      cov_threshold:
        source: cov_threshold
      threads:
        source: threads
    out:
      - id: output_file
    run: ../../../tools/samtools-stats/1.13.0/samtools-stats__1.13.0.cwl
    # custom QC
  custom_stats_qc_step:
    label: custom stats qc step
    doc:
      A tool to extract custom QC metrics from samtools stats output and convert to json format.
    in:
      output_samtools_stats:
        source: samtools_stats_step/output_file
      output_json_filename:
        source: output_json_filename
    out:
      - id: output_json
    run: ../../../tools/custom-stats-qc/1.0.1/custom-stats-qc__1.0.1.cwl
         
outputs:
  samtools_stats_output_txt:
    label: samtools stats output txt
    doc: |
      Output file, of varying format depending on the command run
    type: File
    outputSource: samtools_stats_step/output_file
  custom_stats_qc_output_json:
    label: custom stats qc output json
    doc: |
      JSON output file containing custom metrics
    type: File
    outputSource: custom_stats_qc_step/output_json
