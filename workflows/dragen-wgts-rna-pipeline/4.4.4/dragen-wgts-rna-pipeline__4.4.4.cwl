cwlVersion: v1.2
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
id: dragen-wgts-rna-pipeline--4.4.4
label: dragen-wgts-rna-pipeline v(4.4.4)
doc: |
  Dragen dragen-wgts-rna-pipeline v4.4.4

  Performs the following steps:
    * If input is a bam file, reheader the bam file such that the rgsm value matches
      the output_prefix value. We can't do this inside the dragen container since it doesn't have the samtools binary installed.
      Instead we run a seperate step to reheader the bam file.
    * Run the dragen rna pipeline
    * Run multiqc on the outputs of the dragen rna pipeline
  
  Inputs:
    This pipeline differs from our previous rna pipeline by instead grouping inputs.
    This makes overall workflow cwl file much smaller, and the workflow graphs much more readable.
    It also means appending input options is much easier since it involves updating just one schema yaml file,
      rather than the workflow inputs, workflow steps and the tool inputs.
    Most of the grunt work is done in the dragen tools typescript file to convert input options into a configuration file.

  Outputs:
    The outputs are the same as the previous dragen-rna pipelines
    The outputs are:
      * Dragen rna output directory (always)
      * Multiqc output directory (always)

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs
  ScatterFeatureRequirement: { }
  MultipleInputFeatureRequirement: { }
  StepInputExpressionRequirement: { }
  SubworkflowFeatureRequirement: { }
  SchemaDefRequirement:
    types:
      # Data inputs
      - $import: ../../../schemas/fastq-list-row/2.0.0/fastq-list-row__2.0.0.yaml
      - $import: ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml
      - $import: ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml
      - $import: ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml
      - $import: ../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0.yaml

      # Nested schemas
      - $import: ../../../schemas/dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4.yaml

      # Options schemas
      - $import: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-rna-gene-fusion-detection-options/4.4.4/dragen-rna-gene-fusion-detection-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.4/dragen-rna-gene-expression-quantification-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-rna-splice-variant-caller-options/4.4.4/dragen-rna-splice-variant-caller-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-maf-conversion-options/4.4.4/dragen-maf-conversion-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-nirvana-annotation-options/4.4.4/dragen-nirvana-annotation-options__4.4.4.yaml

      # Stage schemas
      - $import: ../../../schemas/dragen-wgts-options-alignment-stage/4.4.4/dragen-wgts-options-alignment-stage__4.4.4.yaml
      - $import: ../../../schemas/dragen-wgts-rna-options-variant-calling-stage/4.4.4/dragen-wgts-rna-options-variant-calling-stage__4.4.4.yaml

inputs:
  # Data inputs
  sequence_data:
    label: sequence data
    doc: |
      The sequence data to be aligned and called variants on.
      This can either be a bam file, cram file or a list of fastq list row objects
    type:
      - ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml#fastq-list-rows-input
      - ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml#bam-input
      - ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml#cram-input

  # Reference inputs
  reference:
    label: reference
    doc: |
      The reference genome to be used for alignment and variant calling.
    type: ../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0.yaml#dragen-reference

  # ORA Reference
  ora_reference:
    label: reference
    doc: |
      The ora reference used to decompress the input fastq files,
      required if any of the fastqs are ora-compressed
    type:
      - "null"
      - File

  # Sample name
  sample_name:
    label: sample name
    doc: |
      The sample name to be used for alignment and variant calling.
      This is used to name the output files
    type: string

  # Annotation file
  annotation_file:
    label: annotation file
    doc: |
      The annotation file to be used for
      gene expression quantification, splice variant calling, and gene fusion calling
    type:
      - "null"
      - File

  # Alignment step configurations
  alignment_options:
    label: alignment options
    doc: |
      The options to be used for alignment.
      This is a JSON object that contains the options to be used for alignment.
      This is passed to the Dragen alignment tool.
    type:
      - "null"
      - ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml#dragen-wgts-alignment-options

  # Variant caller configurations
  snv_variant_caller_options:
    label: snv variant calling options
    doc: |
      The options to be used for rna variant calling.
      This is a JSON object that contains the options to be used for variant calling.
      This is passed to the Dragen variant calling tool.
    type:
      - "null"
      - ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml#dragen-snv-variant-caller-options

  # Gene Fusion Detection
  gene_fusion_detection_options:
    label: gene fusion detection options
    doc: |
      The Gene Fusion Detection options for the rna gene fusion detection
    type:
      - "null"
      - ../../../schemas/dragen-rna-gene-fusion-detection-options/4.4.4/dragen-rna-gene-fusion-detection-options__4.4.4.yaml#dragen-rna-gene-fusion-detection-options

  # Gene Expression Quantification Options
  gene_expression_quantification_options:
    label: gene expression quantification options
    doc: |
      The Gene Expression Quantification options for the rna gene expression quantification
    type:
      - "null"
      - ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.4/dragen-rna-gene-expression-quantification-options__4.4.4.yaml#dragen-rna-gene-expression-quantification-options

  # Splice Variant Detection Options
  splice_variant_caller_options:
    label: splice variant caller options
    doc: |
      The Splice Variant Caller options for the rna splice variant caller
    type:
      - "null"
      - ../../../schemas/dragen-rna-splice-variant-caller-options/4.4.4/dragen-rna-splice-variant-caller-options__4.4.4.yaml#dragen-rna-splice-variant-caller-options

  # MAF Conversion Options
  maf_conversion_options:
    label: maf conversion options
    doc: |
      The options to be used for maf conversion.
      This is a JSON object that contains the options to be used for maf conversion.
      This is passed to the variant calling pipeline, make sure to add 'enable_maf_output' to the maf conversion options
      As it is not enabled by default.
    type:
      - "null"
      - ../../../schemas/dragen-maf-conversion-options/4.4.4/dragen-maf-conversion-options__4.4.4.yaml#dragen-maf-conversion-options

  # Nirvana Annotation Options
  nirvana_annotation_options:
    label: nirvana annotation options
    doc: |
      The options to be used for nirvana annotation.
      This is a JSON object that contains the options to be used for nirvana annotation.
      This is passed to the variant calling pipeline, make sure to add 'enable_variant_annotation' to the nirvana annotation options
      As it is not enabled by default.
    type:
      - "null"
      - ../../../schemas/dragen-nirvana-annotation-options/4.4.4/dragen-nirvana-annotation-options__4.4.4.yaml#dragen-nirvana-annotation-options

  # License file
  lic_instance_id_location:
    label: license instance id location
    doc: |
      Path to the lic instance id location,
      default is '/opt/instance-identity',
      but user can either provide an alternative location
      in the docker image or provide their own file.
    type:
      - "null"
      - File
      - string
    default: "/opt/instance-identity"


steps:
  # Prestep - get the existing dragen configuration options
  run_get_dragen_configuration_options_step:
    label: get dragen configuration options
    doc: |
      We first need to get the existing dragen configuration options under
      /opt/edico/config/dragen-user-defaults.cfg (in toml format), and parse this in as JSON format.
      We can then use this in all our dragen tools to 'merge'
    in: { }
    out:
      - id: dragen_default_configuration_options
    run: ../../../tools/get-dragen-default-configuration-json/4.4.4/get-dragen-default-configuration-json__4.4.4.cwl

  # Get the default alignment options input schema
  run_get_default_alignment_options_schema_step:
    label: get default alignment options schema
    doc: |
      Get the default alignment options schema if the input is null
      We need this before we accidentally filter out any relevant keys from the default configuration options
    in:
      alignment_options:
        source: alignment_options
        valueFrom: |
          ${
            if(!self){
              return {};
            } else {
              return self;
            }
          }
    out:
      - id: alignment_options_output
    run: ../../dragen-create-wgts-alignment-options-object/4.4.4/dragen-create-wgts-alignment-options-object__4.4.4.cwl

  # Run the get the variant calling options step
  # Get the default alignment options input schema
  run_get_default_variant_calling_options_schema_step:
    label: get default dna-variant-calling options schema
    doc: |
      Get the default dna-variant-calling options schema if the input is null
      We need this before we accidentally filter out any relevant keys from the default configuration options
    in:
      snv_variant_caller_options:
        source: snv_variant_caller_options
        valueFrom: |
          ${
            if(!self){
              return {};
            } else {
              return self;
            }
          }
      rna_gene_expression_quantification_options:
        source: gene_expression_quantification_options
        valueFrom: |
          ${
            if(!self){
              return {};
            } else {
              return self;
            }
          }
    out:
      - id: snv_variant_caller_options_output
      - id: rna_gene_expression_quantification_options_output
    run: ../../dragen-create-wgts-rna-variant-calling-options-object/4.4.4/dragen-create-wgts-rna-variant-calling-options-object__4.4.4.cwl

  # Run the variant calling stage
  # Use the standard alignment for input
  run_dragen_rna_pipeline_stage:
    label: run variant calling stage
    doc: |
      Run the variant calling stage on the RNA alignment data
    in:
      # Dragen options
      dragen_options:
        source:
          # Sample Name
          - sample_name
          # Reference
          - reference
          # Ora reference
          - ora_reference
          # Annotation File
          - annotation_file
          # Input sequence files
          - sequence_data
          # Alignment options
          - run_get_default_alignment_options_schema_step/alignment_options_output
          # SNV Variant Caller options
          - run_get_default_variant_calling_options_schema_step/snv_variant_caller_options_output
          # Gene Fusion Detection options
          - gene_fusion_detection_options
          # Gene Expression Quantification options
          - run_get_default_variant_calling_options_schema_step/rna_gene_expression_quantification_options_output
          # Splice Variant Caller options
          - splice_variant_caller_options
          # MAF Conversion Options
          - maf_conversion_options
          # Nirvana Annotation Options
          - nirvana_annotation_options
          # License location
          - lic_instance_id_location
          # Default Dragen Configuration
          - run_get_dragen_configuration_options_step/dragen_default_configuration_options
        valueFrom: |
          ${
            /*
                // Sample Names
                self[0] - sample_name

                // References
                self[1] - reference

                // ORA Reference
                self[2] - ora_reference

                // Annotation file
                self[3] - annotation_file

                // Input sequence data
                self[4] - sequence_data

                // Alignment options
                self[5] - alignment_options

                # SNV Variant Caller options
                self[6] - snv_variant_caller_options

                # Gene Fusion Detection options
                self[7] - gene_fusion_detection_options

                # Gene Expression Quantification options
                self[8] - gene_expression_quantification_options

                # Splice Variant Caller options
                self[9] - splice_variant_caller_options

                // MAF conversion options
                self[10] - maf_conversion_options

                // Nirvana annotation options
                self[11] - nirvana_annotation_options

                // License file
                self[12] - lic_instance_id_location

                // Default Dragen Configuration
                self[13] - default_configuration_options
            */
            return get_dragen_wgts_rna_variant_calling_stage_options_from_pipeline(
              {
                "sample_name": self[0],
                "reference": self[1],
                "ora_reference": self[2],
                "annotation_file": self[3],
                /* Sequence data */
                "sequence_data": self[4],
                /* Alignment options */
                "alignment_options": self[5],
                /* VC Options */
                "snv_variant_caller_options": self[6],
                /* Map gene fusion detection options to gene fusion detection options */
                "gene_fusion_detection_options": self[7],
                "gene_expression_quantification_options": self[8],
                "splice_variant_caller_options": self[9],
                "maf_conversion_options": self[10],
                "nirvana_annotation_options": self[11],
                "lic_instance_id_location": self[12],
                "default_configuration_options": JSON.parse(self[13])
              }
            );
          }
    out:
      - id: output_directory
    run: ../../../workflows/dragen-wgts-rna-variant-calling-stage/4.4.4/dragen-wgts-rna-variant-calling-stage__4.4.4.cwl

  # Run Multiqc on outputs
  run_multiqc:
    label: run multiqc
    doc: |
      Run multiqc on the outputs of the alignment and variant calling stages
    in:
      input_directories:
        pickValue: all_non_null
        source:
          # RNA Pipeline
          - run_dragen_rna_pipeline_stage/output_directory
        linkMerge: merge_nested
      output_filename:
        source:
          - sample_name
        valueFrom: |
          ${
            /* Return the output filename */
            return get_wgts_rna_multiqc_output_filename(
              {
                "sample_name": self[0],
              }
            );
          }
      title:
        source:
          - sample_name
        valueFrom: |
          ${
            /* Return the title */
            return get_wgts_rna_multiqc_title(
              {
                "sample_name": self[0],
              }
            );
          }
      output_directory_name:
        source:
          - sample_name
        valueFrom: |
          ${
            /* Return the output directory name */
            return get_wgts_rna_multiqc_output_directory_name(
              {
                "sample_name": self[0],
              }
            );
          }
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.25.1/multiqc__1.25.1.cwl


outputs:
  # Variant calling outputs
  dragen_rna_pipeline_output_directory:
    type: Directory
    outputSource: run_dragen_rna_pipeline_stage/output_directory
    label: dragen variant calling output directory
    doc: |
      The outputs of the variant calling stage.


  # Multiqc output
  multiqc_output_directory:
    type: Directory
    outputSource: run_multiqc/output_directory
    label: multiqc output directory
    doc: |
      The outputs of the multiqc stage.
      This contains the multiqc report and the multiqc config file.
