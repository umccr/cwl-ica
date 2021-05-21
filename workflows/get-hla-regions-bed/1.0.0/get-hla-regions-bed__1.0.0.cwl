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
id: get-hla-regions-bed--1.0.0
label: get-hla-regions-bed v(1.0.0)
doc: |
  Takes input of genome version and a reference file.
  Returns a regions bed file from a list of contig objects
  Step 1 -> Creates a contig object for hla region in chr6
  Step 2 -> Creates a bed file from the contig object in step 1
  Step 3 -> Uses the faidx file to create a bed file from the hla contigs
  Step 4 -> Merges the list from step 2 and step 3 and creates a regions bed file


requirements:
    InlineJavascriptRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/contig/1.0.0/contig__1.0.0.yaml
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
  # Faidx input file
  faidx_file:
    label: A reference faidx file
    doc: |
      May be extracted from a secondary files reference file if this is a subworkflow
    type: File
  # genome type
  genome_version:
    label: name of the genome
    doc: |
      The name of the genome determines the chr6 contig we create
    type:
      - type: enum
        symbols:
          - hg38
          - GRCh37
  # Output naming options
  regions_bed_file:
    label: output regions bed file name
    doc: |
      Name of the output regions bed file we create
    type: string?

steps:
  # Create contig obj for chr6
  create_contig_obj_for_chr6_step:
    label: create contig obj for chr 6 step
    doc: |
      Creates a contig object for the hla region
      in chr6 based on the reference type.
    in:
      genome_version:
        source: genome_version
    out:
      - contig
    run: ../../../expressions/create-contig-obj-for-hla-chr6-region/1.0.0/create-contig-obj-for-hla-chr6-region__1.0.0.cwl
  # Create regions bed from hla-regions
  create_regions_bed_for_hla_contigs_step:
    label: create contig obj for hla contigs step
    doc: |
      Creates a contig object for the hla regions.
      Uses the faidx file in the input to search for HLA contigs
    in:
      faidx_file:
        source: faidx_file
    out:
      - hla_regions_bed
    run: ../../../tools/custom-hla-bed-from-faidx/1.0.0/custom-hla-bed-from-faidx__1.0.0.cwl
  # Create regions bed from contig objects
  create_regions_bed_for_chr_6_hla_region_step:
    label: create regions bed from contigs
    doc: |
      Merge the list of contigs from each the chr6 region and the hla_contigs
    in:
      contig_list:
        source:
          - create_contig_obj_for_chr6_step/contig
        linkMerge: merge_nested
      regions_bed:
        source: regions_bed_file
    out:
      - regions_bed_out
    run: ../../../tools/custom-create-regions-bed-from-contigs-list/1.0.0/custom-create-regions-bed-from-contigs-list__1.0.0.cwl
  # Merge bed files with bedops merge
  bedops_merge_step:
    label: bedops merge step
    doc: |
      Merge the chromosome 6 and hla bed files
    in:
      input_files:
        source:
          - create_regions_bed_for_chr_6_hla_region_step/regions_bed_out
          - create_regions_bed_for_hla_contigs_step/hla_regions_bed
      everything:
        valueFrom: ${ return true; }
      output_filename:
        source: regions_bed_file
    out:
      - output_file
    run: ../../../tools/bedops/2.4.39/bedops__2.4.39.cwl

outputs:
  regions_bed:
    label: output regions bed
    doc: |
      The output regions bed file
    type: File
    outputSource: bedops_merge_step/output_file
