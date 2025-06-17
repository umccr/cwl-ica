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
id: dragen-wgts-dna-pipeline--4.4.4
label: dragen-wgts-dna-pipeline v(4.4.4)
doc: |
  Dragen dragen-wgts-dna-pipeline v4.4.4

  Performs the following steps:
    * If input is a bam file (for tumor or normal), reheader the bam file such that the rgsm value matches
      the output_prefix value. We can't do this inside the dragen container since it doesn't have the samtools binary installed.
      Instead we run a seperate step to reheader the bam file.
    * If tumor sequence data is provided and normal sequence data are provided, run the dragen-somatic tool.
    * If only the normal sequence data are provided, run the dragen-germline tool.

  Inputs:
    This pipeline differs from our previous dragen-germline and dragen-somatic pipeline by instead grouping inputs.
    This makes overall workflow cwl file much smaller, and the workflow graphs much more readable.
    It also means appending input options is much easier since it involves updating just one schema yaml file,
      rather than the workflow inputs, workflow steps and the tool inputs.
    Most of the grunt work is done in the dragen tools typescript file to convert input options into a configuration file.

  Outputs:
    The outputs are the same as the previous dragen-germline and dragen-somatic pipelines.
    The outputs are:
      * Dragen somatic output directory (if tumor sequence data are provided)
      * Dragen germline output directory (always)
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
      - $import: ../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0.yaml
      - $import: ../../../schemas/fastq-list-row/2.0.0/fastq-list-row__2.0.0.yaml
      - $import: ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml
      - $import: ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml
      - $import: ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml

      # Intermediate data outputs
      - $import: ../../../schemas/bam-output/1.0.0/bam-output__1.0.0.yaml
      - $import: ../../../schemas/cram-output/1.0.0/cram-output__1.0.0.yaml

      # Options schemas
      - $import: ../../../schemas/dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-cnv-caller-options/4.4.4/dragen-cnv-caller-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-maf-conversion-options/4.4.4/dragen-maf-conversion-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-sv-caller-options/4.4.4/dragen-sv-caller-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-nirvana-annotation-options/4.4.4/dragen-nirvana-annotation-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-targeted-caller-options/4.4.4/dragen-targeted-caller-options__4.4.4.yaml

      # Stage schemas
      - $import: ../../../schemas/dragen-wgts-options-alignment-stage/4.4.4/dragen-wgts-options-alignment-stage__4.4.4.yaml
      - $import: ../../../schemas/dragen-wgts-dna-options-variant-calling-stage/4.4.4/dragen-wgts-dna-options-variant-calling-stage__4.4.4.yaml

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
  tumor_sequence_data:
    label: tumor sequence data
    doc: |
      The sequence data to be aligned and called variants on.
      This can either be a bam file, cram file or a list of fastq list row objects
      Only specify the tumor sequence data IF you want to run the somatic variant calling pipeline.
    type:
      - "null"
      - ../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0.yaml#fastq-list-rows-input
      - ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml#bam-input
      - ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml#cram-input

  # Reference inputs
  reference:
    label: reference
    doc: |
      The reference genome to be used for alignment and variant calling.
    type: ../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0.yaml#dragen-reference
  somatic_reference:
    label: somatic reference
    doc: |
      The somatic reference genome to be used for alignment and variant calling.
      This is only used if the somatic reference is different from the normal reference.
    type:
      - "null"
      - ../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0.yaml#dragen-reference

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
  tumor_sample_name:
    label: tumor sample name
    doc: |
      The tumor sample name to be used for alignment and variant calling.
      This is used to name the output files
    type: string?

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
  somatic_alignment_options:
    label: somatic alignment options
    doc: |
      The options to be used for alignment of the tumor sample.
      This is a JSON object that contains the options to be used for alignment.
      This is passed to the Dragen alignment tool.
      For the somatic alignment, both alignment options and somatic alignment options are first merged before being provided to dragen
    type:
      - "null"
      - ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml#dragen-wgts-alignment-options

  # Variant caller configurations
  snv_variant_caller_options:
    label: variant calling options
    doc: |
      The options to be used for variant calling.
      This is a JSON object that contains the options to be used for variant calling.
      This is passed to the Dragen variant calling tool.
    type:
      - "null"
      - ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml#dragen-snv-variant-caller-options
  somatic_snv_variant_caller_options:
    label: somatic variant calling options
    doc: |
      The options to be used for alignment of the normal sample.
      This is a JSON object that contains the options to be used for alignment.
      This is passed to the Dragen alignment tool.
      For the somatic variant-caller, both variant-caller options and somatic variant-caller options are first merged before being provided to dragen
    type:
      - "null"
      - ../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4.yaml#dragen-snv-variant-caller-options

  # CNV caller configurations
  cnv_caller_options:
    label: cnv calling options
    doc: |
      The options to be used for cnv calling.
      This is a JSON object that contains the options to be used for cnv calling.
      This is passed to the variant calling pipeline, make sure to add 'enable_cnv' to the cnv caller options
      As it is not enabled by default
    type:
      - "null"
      - ../../../schemas/dragen-cnv-caller-options/4.4.4/dragen-cnv-caller-options__4.4.4.yaml#dragen-cnv-caller-options
  somatic_cnv_caller_options:
    label: somatic cnv calling options
    doc: |
      The options to be used for cnv calling in the somatic variant calling stage.
      This is a JSON object that contains the options to be used for cnv calling.
      This is passed to the variant calling pipeline, make sure to add 'enable_cnv' to the cnv caller options
      As it is not enabled by default.
      For the somatic cnv-caller, both cnv-caller options and somatic cnv-caller options are first merged before being provided to dragen
    type:
      - "null"
      - ../../../schemas/dragen-cnv-caller-options/4.4.4/dragen-cnv-caller-options__4.4.4.yaml#dragen-cnv-caller-options

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

  # Somtic MAF Conversion Options
  somatic_maf_conversion_options:
    label: somatic maf conversion options
    doc: |
      The options to be used for maf conversion in the somatic maf conversion stage.
      This is a JSON object that contains the options to be used for maf conversion.
      This is passed to the variant calling pipeline, make sure to add 'enable_maf_output' to the maf conversion options
      As it is not enabled by default.
      For the somatic maf conversion, both maf conversion options and somatic maf conversion options are first merged before being provided to dragen
    type:
      - "null"
      - ../../../schemas/dragen-maf-conversion-options/4.4.4/dragen-maf-conversion-options__4.4.4.yaml#dragen-maf-conversion-options

  # SV Caller Options
  sv_caller_options:
    label: sv calling options
    doc: |
      The options to be used for sv calling in the variant calling stage.
      This is a JSON object that contains the options to be used for sv calling.
      This is passed to the variant calling pipeline, make sure to add 'enable_sv' to the sv caller options
      As it is not enabled by default.
    type:
    - "null"
    - ../../../schemas/dragen-sv-caller-options/4.4.4/dragen-sv-caller-options__4.4.4.yaml#dragen-sv-caller-options

  # Somatic SV Caller Options
  somatic_sv_caller_options:
    label: somatic sv calling options
    doc: |
      The options to be used for sv calling in the somatic variant calling stage.
      This is a JSON object that contains the options to be used for sv calling.
      This is passed to the variant calling pipeline, make sure to add 'enable_sv' to the sv caller options
      As it is not enabled by default.
      For the somatic sv caller, both sv caller options and somatic sv caller options are first merged before being provided to dragen
    type:
      - "null"
      - ../../../schemas/dragen-sv-caller-options/4.4.4/dragen-sv-caller-options__4.4.4.yaml#dragen-sv-caller-options

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

  # Somatic Nirvana Annotation Options
  somatic_nirvana_annotation_options:
    label: somatic annotation options
    doc: |
      The options to be used for nirvana annotation.
      This is a JSON object that contains the options to be used for nirvana annotation.
      This is passed to the variant calling pipeline, make sure to add 'enable_variant_annotation' to the nirvana annotation options
      As it is not enabled by default.
    type:
      - "null"
      - ../../../schemas/dragen-nirvana-annotation-options/4.4.4/dragen-nirvana-annotation-options__4.4.4.yaml#dragen-nirvana-annotation-options

  # Targeted Caller options
  targeted_caller_options:
    label: targeted caller options
    doc: |
      The options to be used for targeted calling.
      This is a JSON object that contains the options to be used for targeted calling.
      This is passed to the variant calling pipeline, make sure to add 'enable_targeted_caller' to the targeted caller options
      As it is not enabled by default.
    type:
      - "null"
      - ../../../schemas/dragen-targeted-caller-options/4.4.4/dragen-targeted-caller-options__4.4.4.yaml#dragen-targeted-caller-options


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

  # Run the alignment stage
  run_dragen_alignment_stage:
    label: run alignment stage
    doc: |
      Run the alignment stage for the germline sequence data
      The outputs are used to call variants in the variant calling stage.
      And may be used for the somatic variant calling stage if the somatic reference is identical to the normal reference.
    in:
      dragen_options:
        source:
          # Sample names
          - sample_name
          # References
          - reference
          # ORA Reference
          - ora_reference
          # Sequence data
          - sequence_data
          # Options
          - run_get_default_alignment_options_schema_step/alignment_options_output
          # License file
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

                // Sequence data
                self[3] - sequence_data

                // Alignment options
                self[4] - alignment_options

                // License file
                self[5] - lic_instance_id_location

                // Default Dragen Configuration
                self[6] - default configuration options
            */
            return get_dragen_wgts_dna_alignment_stage_options_from_pipeline(
              {
                "sample_name": self[0],
                "reference": self[1],
                "ora_reference": self[2],
                "sequence_data": self[3],
                "alignment_options": self[4],
                "lic_instance_id_location": self[5],
                "default_configuration_options": JSON.parse(self[6])
              }
            );
          }
    out:
      - id: output_directory
      - id: output_alignment_file
    run: ../../../workflows/dragen-wgts-alignment-stage/4.4.4/dragen-wgts-alignment-stage__4.4.4.cwl

  # If tumor sequence data is provided,
  # Merge alignment options and somatic alignment options
  # Run the alignment stage for tumor sequence data
  run_dragen_alignment_stage_tumor:
    label: run dragen alignment stage tumor
    doc: |
      Run the alignment stage for the tumor sequence data
      The outputs are used to call variants in the variant calling stage.
      This is only run when the somatic reference is different from the normal reference.
      This is used to align the tumor sequence data on the somatic reference.
    when: |
      ${
        /* Only run when tumor sequence data is provided */
        return inputs.run_condition
      }
    in:
      # Only run when tumor sequence data is provided
      run_condition:
        source:
          - tumor_sequence_data
        valueFrom: |
          ${
            /* Return true if the tumor sequence data is provided */
            if (self){
              return true;
            } else {
              return false;
            };
          }
      dragen_options:
        source:
          # Sample name
          - tumor_sample_name
          # Reference
          - somatic_reference
          - reference
          - ora_reference
          # Sequence data
          - tumor_sequence_data
          # Alignment options
          - somatic_alignment_options
          - run_get_default_alignment_options_schema_step/alignment_options_output
          # License file
          - lic_instance_id_location
          # Default Dragen Configuration
          - run_get_dragen_configuration_options_step/dragen_default_configuration_options
        valueFrom: |
          ${
            /*
               // Sample Names
               self[0] - tumor_sample_name

               // References
               self[1] - somatic_reference
               self[2] - reference

               // Ora reference
               self[3] - ora_reference

               // Sequence data
               self[4] - tumor_sequence_data

               // Alignment options
               self[5] - somatic_alignment_options
               self[6] - alignment_options

               // License file
               self[7] - lic_instance_id_location

               // Default Dragen Configuration
               self[8] - default_configuration_options
            */
            return get_dragen_wgts_dna_alignment_stage_options_from_pipeline(
              {
                "sample_name": self[0],
                "reference": pick_first_non_null([self[1], self[2]]),
                "ora_reference": self[3],
                "sequence_data": self[4],
                "alignment_options": dragen_merge_options([self[6], self[5]]),
                "lic_instance_id_location": self[7],
                "default_configuration_options": JSON.parse(self[8])
              }
            );
          }
    out:
      - id: output_directory
      - id: output_alignment_file
    run: ../../../workflows/dragen-wgts-alignment-stage/4.4.4/dragen-wgts-alignment-stage__4.4.4.cwl


  # If ref and somatic ref are both specified, we also need to run the alignment stage,
  # again for the normal sequence data
  # Rerun the alignment stage for normal sequence data on the somatic reference
  run_dragen_alignment_stage_normal_somatic_reference:
    label: run alignment stage normal somatic reference
    doc: |
      This is only run when the somatic reference is different from the normal reference.
      This is used to align the normal sequence data on the somatic reference.
      The outputs are used to call somatic variants in the somatic variant calling stage.
    when: |
      ${
        /* Only run when reference_tar is provided */
        return inputs.run_condition;
      }
    in:
      # When condition
      run_condition:
        source:
          - reference
          - somatic_reference
          - somatic_alignment_options
        valueFrom: |
          ${
            /* Return true if the reference and somatic reference are different */
            if (dragen_references_match([self[0], self[1]]) === false){
              return true;
            }
            /* Or when the somatic alignment options are not null */
            if (self[2]){
              return true;
            }
            return false;
          }
      dragen_options:
        source:
          # Sample name
          - sample_name
          # Reference
          - somatic_reference
          - reference
          # ORA Reference
          - ora_reference
          # Sequence data
          - sequence_data
          # Alignment options
          # We use the somatic alignment options since this will be the normal alignment
          # For the somatic workflow
          - somatic_alignment_options
          - run_get_default_alignment_options_schema_step/alignment_options_output
          # License file
          - lic_instance_id_location
          # Default Dragen Configuration
          - run_get_dragen_configuration_options_step/dragen_default_configuration_options
        valueFrom: |
          ${
            /*
                // Sample Names
                self[0] - sample_name

                // References
                self[1] - somatic_reference
                self[2] - reference // Used for input validation only

                // ORA Reference
                self[3] - ora_reference

                // Sequence data
                self[4] - sequence_data

                // Alignment options
                self[5] - somatic_alignment_options
                self[6] - alignment_options

                // License file
                self[7] - lic_instance_id_location

                // Default Dragen Configuration
                self[8] - default_configuration_options
            */
            return get_dragen_wgts_dna_alignment_stage_options_from_pipeline(
              {
                "sample_name": self[0],
                "reference": pick_first_non_null([self[1], self[2]]),
                "ora_reference": self[3],
                "sequence_data": self[4],
                "alignment_options": dragen_merge_options([self[6], self[5]]),
                "lic_instance_id_location": self[7],
                "default_configuration_options": JSON.parse(self[8])
              }
            );
          }
    out:
      - id: output_directory
      - id: output_alignment_file
    run: ../../../workflows/dragen-wgts-alignment-stage/4.4.4/dragen-wgts-alignment-stage__4.4.4.cwl

  # Get the default alignment options input schema
  run_get_variant_calling_options_as_schemas_step:
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
      sv_caller_options:
        source: sv_caller_options
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
      - id: sv_caller_options_output
    run: ../../dragen-create-wgts-dna-variant-calling-options-object/4.4.4/dragen-create-wgts-dna-variant-calling-options-object__4.4.4.cwl


  # Run the variant calling stage
  # Use the standard alignment for input
  run_dragen_variant_calling_stage:
    label: run variant calling stage
    doc: |
      Run the variant calling stage on the germline alignment data
    in:
      # Dragen options
      dragen_options:
        source:
          # Sample Name
          - sample_name
          # Reference
          - reference
          # Input alignment files
          - run_dragen_alignment_stage/output_alignment_file
          # Variant Caller options
          - run_get_variant_calling_options_as_schemas_step/snv_variant_caller_options_output
          # CNV Caller Options
          - cnv_caller_options
          # MAF Conversion Options
          - maf_conversion_options
          # SV Caller Options
          - run_get_variant_calling_options_as_schemas_step/sv_caller_options_output
          # Nirvana Annotation Options
          - nirvana_annotation_options
          # Dragen Caller Options
          - targeted_caller_options
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

                // Input alignment file
                self[2] - output_alignment_file

                // Variant caller options
                self[3] - snv_variant_caller_options

                // CNV caller options
                self[4] - cnv_caller_options

                // MAF conversion options
                self[5] - maf_conversion_options

                // SV caller options
                self[6] - sv_caller_options

                // Nirvana annotation options
                self[7] - nirvana_annotation_options

                // Targeted caller options
                self[8] - targeted_caller_options

                // License file
                self[9] - lic_instance_id_location

                // Default Dragen Configuration
                self[10] - default_configuration_options
            */
            return get_dragen_wgts_dna_variant_calling_stage_options_from_pipeline(
              {
                "sample_name": self[0],
                "reference": self[1],
                /* Map alignment inputs to alignment outputs */
                "alignment_data": self[2],
                "snv_variant_caller_options": self[3],
                "cnv_caller_options": self[4],
                "maf_conversion_options": self[5],
                "sv_caller_options": self[6],
                "nirvana_annotation_options": self[7],
                "targeted_caller_options": self[8],
                "lic_instance_id_location": self[9],
                "default_configuration_options": JSON.parse(self[10])
              }
            );
          }
    out:
      - id: output_directory
    run: ../../../workflows/dragen-wgts-dna-variant-calling-stage/4.4.4/dragen-wgts-dna-variant-calling-stage__4.4.4.cwl

  # If tumor sequence data is provided, run the variant calling stage for tumor
  # Merge variant calling options and somatic variant calling options
  # Using the tumor alignment stage output as the tumor bam input
  # And using the normal alignment stage output as the normal bam input with the somatic ref dir if different
  # Otherwise use the normal alignment stage output
  run_dragen_variant_calling_stage_tumor:
    label: run variant calling stage tumor
    doc: |
      Run the variant calling stage on the somatic + germline alignment data
      This is only run when the somatic inputs are provided
    when: |
      ${
        /* Only run when tumor sequence data is provided */
        return inputs.run_condition;
      }
    in:
      # Run condition
      run_condition:
        source:
          - run_dragen_alignment_stage_tumor/output_alignment_file
        valueFrom: |
          ${
            /* Return true if the tumor output alignment is not null */
            if(self){
              return true;
            } else {
              return false;
            };
          }
      # Variant calling options
      dragen_options:
        source:
          # Sample names
          - sample_name
          - tumor_sample_name
          # Reference (pick first non null)
          - somatic_reference
          - reference
          # Output alignment files
          # Germline alignment (pick first non null)
          - run_dragen_alignment_stage_normal_somatic_reference/output_alignment_file
          - run_dragen_alignment_stage/output_alignment_file
          # Somatic alignment
          - run_dragen_alignment_stage_tumor/output_alignment_file
          # Options list
          # Variant caller options
          # Merge these two
          - somatic_snv_variant_caller_options
          - run_get_variant_calling_options_as_schemas_step/snv_variant_caller_options_output
          # CNV Options
          - somatic_cnv_caller_options
          - cnv_caller_options
          # MAF Conversion Options
          - somatic_maf_conversion_options
          - maf_conversion_options
          # SV Caller Options
          - somatic_sv_caller_options
          - run_get_variant_calling_options_as_schemas_step/sv_caller_options_output
          # Nirvana Annotation Options
          - somatic_nirvana_annotation_options
          - nirvana_annotation_options
          # License file
          - lic_instance_id_location
          # Default Dragen Configuration
          - run_get_dragen_configuration_options_step/dragen_default_configuration_options
        valueFrom: |
          ${
            /*
                // Sample Names
                self[0] - sample_name
                self[1] - tumor_sample_name

                // References
                self[2] - somatic_reference
                self[3] - reference

                // Input alignment files
                // Latter might exist, but we want former if it exists
                self[4] - germline alignment on somatic reference
                self[5] - germline alignment on normal reference

                // This definitely exists
                self[6] - somatic alignment

                // Variant calling options
                self[7] - somatic_snv_variant_caller_options
                self[8] - snv_variant_caller_options

                // CNV caller options
                self[9] - somatic_cnv_caller_options
                self[10] - cnv_caller_options

                // MAF conversion options
                self[11] - somatic_maf_conversion_options
                self[12] - maf_conversion_options

                // SV caller options
                self[13] - somatic_sv_caller_options
                self[14] - sv_caller_options

                // Nirvana annotation options
                self[15] - somatic_nirvana_annotation_options
                self[16] - nirvana_annotation_options

                // License file
                self[17] - lic_instance_id_location

                // Default Dragen Configuration
                self[18] - default_configuration_options
            */

            /* First confirm that the somatic alignment is set, otherwise return null */
            /* Before trying to transform objects that are null */
            if (self[6] === null) {
              return null;
            }

            return get_dragen_wgts_dna_variant_calling_stage_options_from_pipeline(
              {
                "sample_name": self[0],
                "tumor_sample_name": self[1],
                "reference": pick_first_non_null([self[2], self[3]]),
                "alignment_data": pick_first_non_null([self[4], self[5]]),
                "tumor_alignment_data": self[6],
                "snv_variant_caller_options": dragen_merge_options([self[8], self[7]]),
                "cnv_caller_options": dragen_merge_options([self[10], self[9]]),
                "maf_conversion_options": dragen_merge_options([self[12], self[11]]),
                "sv_caller_options": dragen_merge_options([self[14], self[13]]),
                "nirvana_annotation_options": dragen_merge_options([self[16], self[15]]),
                /* Targeted caller options are not available in the somatic variant calling stage */
                "targeted_caller_options": null,
                "lic_instance_id_location": self[17],
                "default_configuration_options": JSON.parse(self[18])
              }
            );
          }
    out:
      - id: output_directory
    run: ../../../workflows/dragen-wgts-dna-variant-calling-stage/4.4.4/dragen-wgts-dna-variant-calling-stage__4.4.4.cwl

  # Run Multiqc on outputs
  run_multiqc:
    label: run multiqc
    doc: |
      Run multiqc on the outputs of the alignment and variant calling stages
    in:
      input_directories:
        pickValue: all_non_null
        source:
          # Alignments
          - run_dragen_alignment_stage/output_directory
          - run_dragen_alignment_stage_tumor/output_directory
          - run_dragen_alignment_stage_normal_somatic_reference/output_directory
          # Variant calling
          - run_dragen_variant_calling_stage/output_directory
          - run_dragen_variant_calling_stage_tumor/output_directory
      output_filename:
        source:
          - sample_name
          - tumor_sample_name
        valueFrom: |
          ${
            /* Return the output filename */
            return get_wgts_dna_multiqc_output_filename(
              {
                "sample_name": self[0],
                "tumor_sample_name": self[1]
              }
            );
          }
      title:
        source:
          - sample_name
          - tumor_sample_name
        valueFrom: |
          ${
            /* Return the title */
            return get_wgts_dna_multiqc_title(
              {
                "sample_name": self[0],
                "tumor_sample_name": self[1]
              }
            );
          }
      output_directory_name:
        source:
          - sample_name
          - tumor_sample_name
        valueFrom: |
          ${
            /* Return the output directory name */
            return get_wgts_dna_multiqc_output_directory_name(
              {
                "sample_name": self[0],
                "tumor_sample_name": self[1]
              }
            );
          }
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.25.1/multiqc__1.25.1.cwl


outputs:
  # Alignment outputs
  dragen_alignment_output_directory:
    type: Directory
    outputSource: run_dragen_alignment_stage/output_directory
    label: dragen alignment output directory
    doc: |
      The outputs of the alignment stage.
  dragen_alignment_output_directory_normal_somatic_reference:
    type: Directory?
    outputSource: run_dragen_alignment_stage_normal_somatic_reference/output_directory
    label: dragen alignment output directory normal somatic reference
    doc: |
      The outputs of the alignment stage for the normal sample on the somatic reference.
  dragen_alignment_output_directory_tumor:
    type: Directory?
    outputSource: run_dragen_alignment_stage_tumor/output_directory
    label: dragen alignment output directory
    doc: |
      The outputs of the alignment stage for the tumor sample.

  # Variant calling outputs
  dragen_variant_calling_output_directory:
    type: Directory
    outputSource: run_dragen_variant_calling_stage/output_directory
    label: dragen variant calling output directory
    doc: |
      The outputs of the variant calling stage.
  dragen_variant_calling_output_directory_tumor:
    type: Directory?
    outputSource: run_dragen_variant_calling_stage_tumor/output_directory
    label: dragen variant calling output directory
    doc: |
      The outputs of the variant calling stage for the tumor sample.

  # Multiqc output
  multiqc_output_directory:
    type: Directory
    outputSource: run_multiqc/output_directory
    label: multiqc output directory
    doc: |
      The outputs of the multiqc stage.
      This contains the multiqc report and the multiqc config file.
