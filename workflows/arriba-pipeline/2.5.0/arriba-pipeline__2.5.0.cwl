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
id: arriba-pipeline--2.5.0
label: arriba-pipeline v(2.5.0)
doc: |
  Arriba fusion calling and drawing pipeline (v 2.5.0)


# Requirements
requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml#bam-input
      - $import: ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml#cram-input
  InlineJavascriptRequirement: { }
  ScatterFeatureRequirement: { }
  MultipleInputFeatureRequirement: { }
  StepInputExpressionRequirement: { }


# Inputs
inputs:
  # Metadata inputs
  sample_name:
    label: Sample name
    type: string
    doc: |
      Used for naming the output files.
  # Alignment file
  alignment_data:
    label: Alignment Data
    doc: |
      BAM / CRAM file with aligned reads.
    type:
      - ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml#bam-input
      - ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml#cram-input
  # Reference files
  reference_fasta:
    label: reference Fasta
    type: File
    doc: |
      FastA file with genome sequence
    secondaryFiles:
      - pattern: ".fai"
        required: true
  blacklist_tsv:
    label: blacklist tsv
    type: File
    doc: |
      File with blacklist range
  annotation_gtf:
    label: annotation gtf
    type: File
    doc: |
      GTF file with gene annotation. The file may be gzip-compressed
  # Arriba fusion calling options
  contigs:
    label: contigs
    type: string[]?
    doc: |
      Optional - List of interesting contigs
      If not specified, defaults to 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y
  # Arriba drawing options
  cytobands_tsv:
    label: cytobands
    type: File
    doc: |
      Coordinates of the Giemsa staining bands.
  protein_domains_gff3:
    label: protein domains gff3
    type: File
    doc: |
      GFF3 file containing the genomic coordinates of protein domains.


# Steps
steps:
  # Arriba fusion calling pipeline
  arriba_fusion_calling_step:
    label: Arriba fusion calling step
    doc: |
      The arriba fusion calling step
    in:
      # Inputs
      alignment_data:
        source: alignment_data
      # Reference files
      annotation_gtf:
        source: annotation_gtf
      reference_fasta:
        source: reference_fasta
      blacklist_tsv:
        source: blacklist_tsv
      # Output file name options
      fusions_filename:
        source: sample_name
        valueFrom: "$(self)_fusions.tsv"
      discarded_fusions_filename:
        source: sample_name
        valueFrom: "$(self)_discarded_fusions.tsv"
      # Optional parameters
      contigs:
        source: contigs
    out:
      - id: fusions
      - id: discarded_fusions
    run: ../../../tools/arriba-fusion-calling/2.5.0/arriba-fusion-calling__2.5.0.cwl

  # Arriba drawing step
  arriba_drawing_step:
    label: Arriba drawing step
    doc: |
      Run the arriba drawing tool to create a PDF with the fusion visualisation
    in:
      # Bam input
      alignment_data: alignment_data
      # Fusions
      fusions_tsv:
        source: arriba_fusion_calling_step/fusions
      # Reference options
      annotation_gtf:
        source: annotation_gtf
      cytobands_tsv:
        source: cytobands_tsv
      protein_domains_gff3:
        source: protein_domains_gff3
      # Output file name options
      output_pdf_filename:
        source: sample_name
        valueFrom: "$(self)_fusions.pdf"
    out:
      - id: output_pdf
    run: ../../../tools/arriba-drawing/2.5.0/arriba-drawing__2.5.0.cwl

  # Build the final output directory
  create_arriba_output_directory_step:
    label: create arriba output directory
    doc: |
      Create an output directory to contain the arriba files
    in:
      input_files:
        source:
          - arriba_fusion_calling_step/fusions
          - arriba_fusion_calling_step/discarded_fusions
          - arriba_drawing_step/output_pdf
      output_directory_name:
        source: sample_name
        valueFrom: "$(self)_arriba"
    out:
      - output_directory
    run: ../../../expressions/create-directory/1.0.0/create-directory__1.0.0.cwl


# Workflow Outputs
outputs:
  output_directory:
    label: Arriba output directory
    type: Directory
    doc: |
      Output directory containing the arriba files.
    outputSource: create_arriba_output_directory_step/output_directory
