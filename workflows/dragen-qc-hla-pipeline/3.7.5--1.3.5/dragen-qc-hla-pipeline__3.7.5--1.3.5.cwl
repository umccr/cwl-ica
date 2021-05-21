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
id: dragen-qc-hla-pipeline--3.7.5--1.3.5
label: dragen-qc-hla-pipeline v(3.7.5--1.3.5)
doc: |
  Workflow definition for germline analysis through dragen.
  Also, includes QC report and HLA calls summary.
  Uses fastq_list_row objects to files as inputs.


requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SubworkflowFeatureRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml

# Declare inputs
inputs:
  # Sample Name
  sample_name:
    label: sample name
    doc: |
      What is the name of the sample?
      Used to pre-fill out many other inputs.
    type: string
  fastq_list_rows:
    label: fastq list rows
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
  # Ref data
  reference_tar_dragen:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
  reference_fasta:
    label: reference fasta
    doc: |
      The reference fasta file with a .fai index.
      Required for somalier and optitype steps
    type: File
    secondaryFiles:
      - pattern: ".fai"
        required: true
  hla_reference_fasta:
    label: hla reference fasta
    doc: |
      Reference to align / filter large output bam to before running through optitype tool
    type: File
    secondaryFiles:
      - pattern: ".fai"
        required: true
  # Optitype Options
  genome_version:
    label: genome version
    doc: |
      Either hg38 (default) or GRCh37?
      Used to set chromosome regions to filter down bam file for optitype workflow
    type:
      - type: enum
        symbols:
          - hg38
          - GRCh37
    default: "hg38"
  # Somalier Options
  sites_somalier:
    label: sites somalier
    doc: |
      gzipped vcf file. Required for somalier sites
    type: File
    secondaryFiles:
      - pattern: ".tbi"
        required: true


steps:
  # Step-1: Call dragen workflow
  dragen_germline_step:
    label: dragen germline step
    doc: |
      Runs the dragen germline 3.7.5 workflow
    in:
      # Input fastq files to dragen
      # fastqlist also contains the metadata
      fastq_list_rows:
        source: fastq_list_rows
      reference_tar:
        source: reference_tar_dragen
      output_file_prefix:
        source: sample_name
      output_directory:
        source: sample_name
        valueFrom: "$(self)_dragen"
      # Output configurations
      enable_map_align_output:
        valueFrom: ${ return true; }
      enable_duplicate_marking:
        valueFrom: ${ return true; }
    out:
      - dragen_germline_output_directory
      - dragen_bam_out
      - dragen_vcf_out
    run: ../../../workflows/dragen-germline-pipeline/3.7.5/dragen-germline-pipeline__3.7.5.cwl
  # Step-2a: Create dummy file
  create_dummy_file_step:
    label: Create dummy file
    doc: |
      Intermediate step for letting multiqc-interop be placed in stream mode
    in: {}
    out:
      - dummy_file_output
    run: ../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl
  # Step-2: Generate QC report
  qc_step:
    label: qc step
    doc: |
      Runs multiqc on the run folder
      Uses a dummy file so that the folder can be placed in 'stream' mode.
    in:
      input_directory:
        source: dragen_germline_step/dragen_germline_output_directory
      output_directory_name:
        source: sample_name
        valueFrom: "$(self)_germline_multiqc"
      output_filename:
        source: sample_name
        valueFrom: "$(self)_germline_multiqc.html"
      title:
        source: sample_name
        valueFrom: "Dragen Germline v3.7.5 Multiqc for $(self)"
      module:
        valueFrom: "dragen"
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - output_directory
      - output_file
    run: ../../../tools/multiqc/1.10.1/multiqc__1.10.1.cwl
  # Step-3ai: Get secondary faidx file
  get_faidx_file_step:
    label: get faidx file step
    doc: |
      Get the index of the reference fasta as its own file.
      Used by the get-regions-bed workflow
    # Run an expression to collect the secondaryFile object
    in:
      reference_fasta:
        source: reference_fasta
    out:
      - faidx_file
    run: ../../../expressions/get-faidx-file-from-reference-file/1.0.0/get-faidx-file-from-reference-file__1.0.0.cwl
  # Step-3aii: Get regions bed for optitype
  get_hla_regions_bed_step:
    label: get hla regions bed
    doc: |
      Get the hla regions for input into the optitype workflow
    in:
      faidx_file:
        source: get_faidx_file_step/faidx_file
      genome_version:
        source: genome_version
      regions_bed_file:
        valueFrom: "hla-regions.bed"
    out:
      - regions_bed
    run: ../../../workflows/get-hla-regions-bed/1.0.0/get-hla-regions-bed__1.0.0.cwl
  # Step-3: OptiTypePipeline step
  optitype_step:
    label: optitype
    doc: |
      Run the optitype pipeline
    in:
      regions_bed:
        source: get_hla_regions_bed_step/regions_bed
      bam_sorted:
        source: dragen_germline_step/dragen_bam_out
      sample_name:
        source: sample_name
      hla_reference_fasta:
        source: hla_reference_fasta
    out:
      - output_directory
      - result_matrix
      - coverage_plot
    run: ../../../workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.cwl
  # Step-4: run somalier
  somalier_step:
    label: somalier
    doc: |
      Runs the somalier extract function to call the fingerprint on the germline bam file
    in:
      bam_sorted:
        # The bam from the dragen germline workflow
        source: dragen_germline_step/dragen_bam_out
      sites:
        # The VCF output file from the dragen command
        source: sites_somalier
      reference:
        # The reference fasta for the genome somalier
        source: reference_fasta
      sample_prefix:
        source: sample_name
        # The output-prefix, if not specified just the sample name
      output_directory_name:
        source: sample_name
        valueFrom: "$(self)_somalier"
    out:
      - output_directory
    run: ../../../tools/somalier-extract/0.2.13/somalier-extract__0.2.13.cwl


outputs:
  # Dragen outputs
  dragen_output_directory:
    label: dragen output directory
    doc: |
      Output directory for dragen
    type: Directory
    outputSource: dragen_germline_step/dragen_germline_output_directory
  dragen_bam_output:
    label: Output alignment file
    doc: |
      Output alignment file for dragen germline run
    type: File
    secondaryFiles:
      - ".bai"
    outputSource: dragen_germline_step/dragen_bam_out
  dragen_vcf_output:
    label: Output variant calling file
    doc: |
      Output vcf file for dragen germline run
    type: File
    secondaryFiles:
      - ".tbi"
    outputSource: dragen_germline_step/dragen_vcf_out
  # Multi qc outputs
  multiqc_output_directory:
    label: multiqc output directory
    doc: |
      Output directory with multiqc data and html
    type: Directory
    outputSource: qc_step/output_directory
  multiqc_output_file:
    label: multiqc output file
    doc: |
      Output html for multiqc
    type: File
    outputSource: qc_step/output_file
  # Optitype outputs
  optitype_output_directory:
    label: optitype output directory
    doc: |
      Output directory for optitype files
    type: Directory
    outputSource: optitype_step/output_directory
  optitype_result_matrix:
    label: optitype result matrix
    doc: |
      Output matrix file from optitype step
    type: File
    outputSource: optitype_step/result_matrix
  optitype_coverage_plot:
    label: optitype coverage plot
    doc: |
      Output coverage pdf from optitype step
    type: File
    outputSource: optitype_step/coverage_plot
  # Somalier outputs
  somalier_output_directory:
    label: somalier output directory
    doc: |
      Output directory from somalier step
    type: Directory
    outputSource: somalier_step/output_directory