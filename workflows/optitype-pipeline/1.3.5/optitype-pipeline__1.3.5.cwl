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
id: optitype-pipeline--1.3.5
label: optitype-pipeline v(1.3.5)
doc: |
    This is the Optitype QC workflow.
    We take in a regions bed file that contains our HLA regions
    We use sambamba slice to take these to a region specific hla bam
    We use the unmapped reads, take a subset of no more than 1 million reads, and merge these to the region specific hla bam
    The resulting bam file is converted to paired-end fastq reads
    We then convert this bam file back to fastq and run through optitype v1.3.5 (with paired end data)

# Standard workflow requirements
requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

# Inputs
inputs:
  regions_bed:
    label: regions bed file
    doc: |
      The bed file used to slice the bam file
      This should contain the HLA region on chrom 6 and any extra HLA contigs (for hg38)
    type: File
  bam_sorted:
    label: bam sorted
    doc: The path to the aligned bam file
    type: File
    secondaryFiles:
      - pattern: .bai
        required: true
  sample_name:
    label: sample name
    doc: |
      Used for file naming throughout workflow
    type: string
  hla_reference_fasta:
    label: hla reference fasta
    doc: |
      The fasta file to align the hla reads to through razers3
    type: File
    secondaryFiles:
      - pattern: ".fai"
        required: true


# Steps
steps:
  # Take the section of bam in the regions file extracted in the step above.
  get_bam_slice_from_bed_step:
    label: get bam slice from bed
    doc: |
      Takes in the sorted full bam and hla regions bed and returns
      a subsetted bam by hla region
    in:
      bam_sorted:
        source: bam_sorted
      regions_bed:
        source: regions_bed
      output_filename:
        source: sample_name
        valueFrom: "$(self)_hla_sorted.bam"
    out:
      - id: bam_indexed
    run: ../../../tools/sambamba-slice-and-index/0.8.0/sambamba-slice-and-index__0.8.0.cwl
  # Get unmapped reads from the bam file
  get_unmapped_file_from_sorted_bam_step:
    label: get unmapped file from sorted bam
    doc: |
      Takes in a sorted unmapped file and returns a sorted bam
    in:
      bam_sorted:
        source: bam_sorted
      output_format:
        valueFrom: "bam"
      filter:
        valueFrom: "unmapped or mate_is_unmapped"
      output_filename:
        source: sample_name
        valueFrom: "$(self)_unmapped_sorted.bam"
    out:
      - id: bam_indexed
    run: ../../../tools/sambamba-view-and-index/0.8.0/sambamba-view-and-index__0.8.0.cwl
  # Take a random subset of reads from the bam file.
  subset_unmapped_bam:
    label: set unmapped file from sorted bam
    doc: |
      Takes in a list of n reads and randomly reduces the bam to that number of reads
    in:
      bam_sorted:
        source: get_unmapped_file_from_sorted_bam_step/bam_indexed
      n_lines:
        # 2 million reads is more than enough -> but limits file size to about 2-3 Gbs
        valueFrom: ${ return parseInt("2000000"); }
    out:
      - id: bam_indexed
    run: ../../../tools/custom-subset-bam/1.12.0/custom-subset-bam__1.12.0.cwl
  # Merge hla and unmapped bam files
  merge_hla_and_unmapped_bam_files_step:
    label: merge hla and unmapped bam files
    doc: |
      Merge the hla and unmapped files into one sorted bam
    in:
      bams_sorted:
        source:
          - get_bam_slice_from_bed_step/bam_indexed
          - subset_unmapped_bam/bam_indexed
      output_filename:
        source: sample_name
        valueFrom: "$(self)_unmapped_and_hla_merged_sorted.bam"
    out:
      - id: bam_indexed
    run: ../../../tools/sambamba-merge-and-index/0.8.0/sambamba-merge-and-index__0.8.0.cwl
  # Sort file by name first
  sort_merged_bam_by_name_step:
    label: Sort merged bam by name
    doc: |
      Use sambamba sort to sort indexed bam by readname
      This is a prerequisite for samtools-fastq when using paired data
    in:
      bam_unsorted:
        source: merge_hla_and_unmapped_bam_files_step/bam_indexed
      sort_by_name:
        valueFrom: ${ return true; }
      output_filename:
        source: sample_name
        valueFrom: "$(self)_umapped_and_hla_merged_sorted_by_readname.bam"
    out:
      - id: bam_sorted
    run: ../../../tools/sambamba-sort-and-index/0.8.0/sambamba-sort-and-index__0.8.0.cwl
  # Convert to fastq to align through razers
  unmapped_and_hla_bam_to_fastq_step:
    label: unmapped and hla bam to fastq
    doc: |
      Convert our truncated bam file to paired fastq files
    in:
      bam_sorted:
        source: sort_merged_bam_by_name_step/bam_sorted
      read_one:
        source: sample_name
        valueFrom: "$(self)_unmapped_and_hla_R1.fastq.gz"
      read_two:
        source: sample_name
        valueFrom: "$(self)_unmapped_and_hla_R2.fastq.gz"
      singleton:
        valueFrom: "singletons.fastq.gz"
      read_other:
        valueFrom: "reads_other.fastq.gz"
      append_read_number:
        valueFrom: ${ return true; }
    out:
      - id: read_one_out
      - id: read_two_out
    run: ../../../tools/samtools-fastq/1.12.0/samtools-fastq__1.12.0.cwl
  # Run output fastq through optitype step
  optitype_step:
    label: optitype step
    doc: |
      Run the optitype pipeline on our smaller fastq files
    in:
      input_fastqs:
        source:
          - unmapped_and_hla_bam_to_fastq_step/read_one_out
          - unmapped_and_hla_bam_to_fastq_step/read_two_out
      output_directory_name:
        source: sample_name
        valueFrom: "$(self)_optitype"
      output_prefix:
        source: sample_name
      seq_datatype:
        valueFrom: "dna"
      enumerate:
        valueFrom: ${ return parseInt("3"); }
    out:
      - id: result_matrix
      - id: coverage_plot
      - id: output_directory
    run: ../../../tools/optitype/1.3.5/optitype__1.3.5.cwl

# Outputs
outputs:
  output_directory:
    label: output directory
    doc: |
      The output directory of the optitype step
    type: Directory
    outputSource: optitype_step/output_directory
  result_matrix:
    label: result matrix
    doc: |
      Subattribute of the optitype directory, contains the likelihood information for each HLA allele
    type: File
    outputSource: optitype_step/result_matrix
  coverage_plot:
    label: coverage plot
    doc: |
      The coverage plot output from the optitype directory. Can be used as a QC method for determining
      how certain the allele prediction was.
    type: File
    outputSource: optitype_step/coverage_plot