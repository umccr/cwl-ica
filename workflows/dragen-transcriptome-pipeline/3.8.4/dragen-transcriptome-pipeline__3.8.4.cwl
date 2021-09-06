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
id: dragen-transcriptome-pipeline--3.8.4
label: dragen-transcriptome-pipeline v(3.8.4)
doc: |
  Workflow takes in dragen param along with object store version of a fastq_list.csv equivalent.
  See the fastq_list_row schema definitions for more information.
  More information on the documentation can be found [here](https://sapac.support.illumina.com/content/dam/illumina-support/help/Illumina_DRAGEN_Bio_IT_Platform_v3_7_1000000141465/Content/SW/Informatics/Dragen/GPipelineVarCal_fDG.htm)

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
        - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml

inputs:
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
  enable_map_align_output:
    label: enable map align output
    doc: |
      Do you wish to have the output bam files present
    type: boolean?
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Mark identical alignments as duplicates
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
  # Arriba fusion calling options
  contigs:
    label: contigs
    type: string?
    doc: |
      Optional - List of interesting contigs
      If not specified, defaults to 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y
  blacklist:
    label: blacklist
    type: File
    doc: |
      File with blacklist range
  reference_fasta:
    label: reference Fasta
    type: File
    doc: |
      FastA file with genome sequence
  # Arriba drawing options
  cytobands:
    label: cytobands
    type: File
    doc: |
      Coordinates of the Giemsa staining bands.
  protein_domains:
    label: protein domains
    type: File
    doc: |
      GFF3 file containing the genomic coordinates of protein domains

steps:
   # Step-1: Create fastq_list.csv
  create_fastq_list_csv_step:
    label: create fastq list csv step
    doc: |
      Create the fastq list csv to then run the germline tool.
      Takes in an array of fastq_list_row schema.
      Returns a csv file along with predefined_mount_path schema
    in:
      fastq_list_rows:
        source: fastq_list_rows
    out:
      - id: fastq_list_csv_out
      - id: predefined_mount_paths_out
    run: ../../../tools/custom-create-csv-from-fastq-list-rows/1.0.0/custom-create-csv-from-fastq-list-rows__1.0.0.cwl
  # Step-2: Run dragen transcriptome workflow
  run_dragen_transcriptome_step:
    label: run dragen transcriptome step
    doc: |
      Runs the dragen transcriptome workflow on the FPGA.
      Takes in a fastq list and corresponding mount paths from the predefined_mount_paths.
      All other options avaiable at the top of the workflow
    in:
      # Input fastq files to dragen
      # fastqlist also contains the metadata
      fastq_list:
        source: create_fastq_list_csv_step/fastq_list_csv_out
      fastq_list_mount_paths:
        source: create_fastq_list_csv_step/predefined_mount_paths_out
      reference_tar:
        source: reference_tar
      output_file_prefix:
        source: output_file_prefix
      output_directory:
        source: output_directory
      enable_map_align_output:
        source: enable_map_align_output
      enable_duplicate_marking:
        source: enable_duplicate_marking
      annotation_file:
        source: annotation_file
      enable_rna_quantification:
        source: enable_rna_quantification
      enable_rna_gene_fusion:
        source: enable_rna_gene_fusion
    out:
      - id: dragen_transcriptome_directory
      - id: dragen_bam_out
    run: ../../../tools/dragen-transcriptome/3.8.4/dragen-transcriptome__3.8.4.cwl
  # Step-3: Call Arriba fusion calling step
  arriba_fusion_step:
    label: arriba fusion step
    doc: |
      Runs Arriba fusion calling on the bam file produced by Dragen.
    in: 
      bam_file:
        source: run_dragen_transcriptome_step/dragen_bam_out
      annotation:
        source: annotation_file
      reference: 
        source: reference_fasta
      contigs:
        source: contigs
      blacklist: 
        source: blacklist
    out:
      - id: fusions
      - id: discarded_fusions
    run: ../../../tools/arriba-fusion-calling/2.0.0/arriba-fusion-calling__2.0.0.cwl
  # Step-4: Call Arriba drawing script
  arriba_drawing_step:
    label: arriba drawing step
    doc: |
      Run Arriba drawing script for fusions predicted by previous step.
    in:
      annotation:
        source: annotation_file
      fusions: 
        source: arriba_fusion_step/fusions
      bam_file:
        source: run_dragen_transcriptome_step/dragen_bam_out
      cytobands:
        source: cytobands
      protein_domains:
        source: protein_domains
    out: 
      - id: output_pdf
    run:  ../../../tools/arriba-drawing/2.0.0/arriba-drawing__2.0.0.cwl
  # Step-5: Create Arriba output directory
  create_arriba_output_directory:
    label: create arriba output directory
    doc: |
      Create an output directory to contain the arriba files
    in:
      input_files:
        source:
          - arriba_fusion_step/fusions
          - arriba_fusion_step/discarded_fusions
          - arriba_drawing_step/output_pdf
      output_directory_name:
        valueFrom: "arriba_outputs"
    out:
      - output_directory
    run: ../../../tools/custom-create-directory/1.0.0/custom-create-directory__1.0.0.cwl
  # Step-6: Create dummy file for the qc step
  create_dummy_file_step:
    label: Create dummy file
    doc: |
      Intermediate step for letting multiqc-interop be placed in stream mode
    in: { }
    out:
      - id: dummy_file_output
    run: ../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl
  # Step-7: Create multiQC report
  dragen_qc_step:
    label: dragen qc step
    doc: |
      The dragen qc step - this takes in an array of dirs
    in:
      input_directories:
        source: run_dragen_transcriptome_step/dragen_transcriptome_directory
        valueFrom: |
          ${
            return [self];
          }
      output_directory_name:
        source: output_file_prefix
        valueFrom: "$(self)_dragen_transcriptome_multiqc"
      output_filename:
        source: output_file_prefix
        valueFrom: "$(self)_dragen_transcriptome_multiqc.html"
      title:
        source: output_file_prefix
        valueFrom: "UMCCR MultiQC Dragen Transcriptome Report for $(self)"
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.11.0/multiqc__1.11.0.cwl

outputs:
  # The dragen output directory
  dragen_transcriptome_output_directory:
    label: dragen transcriptome output directory
    doc: |
      The output directory containing all transcriptome output files
    type: Directory
    outputSource: run_dragen_transcriptome_step/dragen_transcriptome_directory
  # The arriba output directory
  arriba_output_directory:
    label: arriba output directory
    doc: |
      The directory containing output files from arriba
    type: Directory
    outputSource: create_arriba_output_directory/output_directory
  # The multiqc output directory
  multiqc_output_directory:
    label: multiqc output directory
    doc: |
      The output directory for multiqc
    type: Directory
    outputSource: dragen_qc_step/output_directory
