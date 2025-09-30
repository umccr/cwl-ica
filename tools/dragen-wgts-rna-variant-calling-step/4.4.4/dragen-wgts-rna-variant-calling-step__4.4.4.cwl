cwlVersion: v1.2
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: https://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-wgts-rna-variant-calling-step--4.4.4
label: dragen-wgts-rna-variant-calling-step v(4.4.4)
doc: |
  Run one or more of:
    * RNA Gene Fusion
    * RNA Quantification
    * RNA Variant Calling
    * RNA Splice Variant
  with the dragen 4.4.4 toolkit

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources:tier: standard
    ilmn-tes:resources:type: fpga
    ilmn-tes:resources:size: medium
    coresMin: 16
    ramMin: 240000
  DockerRequirement:
    dockerPull: "079623148045.dkr.ecr.us-east-1.amazonaws.com/cp-prod/b35eb8ce-3035-4796-896b-1b33b6a02c44:latest"

requirements:
  ResourceRequirement:
    tmpdirMin: |
      ${
        /* 1 Tb */
        return Math.pow(2, 20);
      }
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs
  SchemaDefRequirement:
    types:
      # Imports
      - $import: ../../../schemas/dragen-wgts-rna-options-variant-calling-stage/4.4.4/dragen-wgts-rna-options-variant-calling-stage__4.4.4.yaml
  InitialWorkDirRequirement:
    listing:
      - entryname: "$(get_dragen_config_path())"
        entry: |
          ${

            /*
            Check lic-instance-id-location is not undefined
            */
            if (!inputs.dragen_options.lic_instance_id_location){
              /* Use the global lic-instance-id-location default value */
              var lic_instance_id_location = DEFAULT_LIC_INSTANCE_ID_LOCATION_PATH;
            } else {
              /* Use the user defined lic-instance-id-location */
              var lic_instance_id_location = inputs.dragen_options.lic_instance_id_location;
            }

            return dragen_to_config_toml(
              dragen_merge_options(
                [
                   /* Input data */
                   inputs.dragen_options.sequence_data,
                   /* RNA Alignment Options */
                   inputs.dragen_options.alignment_options,
                   /* RNA VC Options */
                   inputs.dragen_options.snv_variant_caller_options,
                   /* RNA Gene Fusion Options */
                   inputs.dragen_options.gene_fusion_detection_options,
                   /* RNA Gene Expression Quantification */
                   inputs.dragen_options.gene_expression_quantification_options,
                   /* RNA Variant Splicing Options */
                   inputs.dragen_options.splice_variant_caller_options,
                   /* Maf conversion options */
                   inputs.dragen_options.maf_conversion_options,
                   /* Nirvana Annotation Options */
                   inputs.dragen_options.nirvana_annotation_options,
                   /* Dragen mandatory options */
                   {
                      "output_directory": inputs.dragen_options.output_directory,
                      "output_file_prefix": inputs.dragen_options.output_file_prefix,
                      "ref_tar": inputs.dragen_options.ref_tar,
                      "lic_instance_id_location": lic_instance_id_location,
                      "ora_reference": inputs.dragen_options.ora_reference,
                      "annotation_file": inputs.dragen_options.annotation_file
                   },
                   /* VC / RNA Mandatory options */
                   {
                      /* We push this to /scratch */
                      "intermediate_results_dir": get_intermediate_results_dir(),
                      /* Force enable parameters to true - required for rna pipeline */
                      "enable_map_align": true,
                      "enable_map_align_output": true,
                      "enable_variant_caller": true,
                      "enable_rna": true
                   }
                ]
              )
            );
          }
      - entryname: "run_dragen.sh"
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Reset dragen
          /opt/edico/bin/dragen_reset

          # Create directories
          mkdir --parents \\
            "$(get_ref_mount())" \\
            "$(get_intermediate_results_dir())" \\
            "$(inputs.dragen_options.output_directory)"

          # untar ref data into scratch space
          tar \\
            --directory "$(get_ref_mount())" \\
            --extract \\
            --file "$(inputs.dragen_options.ref_tar.path)"

          # Check if ora reference is set
          if [[ "$(is_not_null(inputs.dragen_options.ora_reference))" == "true" ]]; then
            mkdir --parents \\
              "$(get_ora_ref_mount())"
              tar \\
                --directory "$(get_ora_ref_mount())" \\
                --extract \\
                --file "$(get_attribute_from_optional_input(inputs.dragen_options.ora_reference, "path"))"
          fi
          
          # Copy over the config.toml file to the output directory too
          cp "$(get_dragen_config_path())" "$(inputs.dragen_options.output_directory)/$(inputs.dragen_options.output_file_prefix).config.toml"

          # Run dragen command and import options from cli
          "$(get_dragen_bin_path())" "\${@}"          

      - |
        ${
          /* Tumor alignment data may be undefined */
          return generate_sequence_data_mount_points(
            inputs.dragen_options.sequence_data,
            null
          );
        }

baseCommand: [ "bash", "run_dragen.sh" ]

arguments:
  - prefix: "--config-file="
    position: 1
    separate: false
    valueFrom: "$(get_dragen_config_path())"

inputs:
  dragen_options:
    label: dragen-options
    type:
      - "null"
      - ../../../schemas/dragen-wgts-rna-options-variant-calling-stage/4.4.4/dragen-wgts-rna-options-variant-calling-stage__4.4.4.yaml#dragen-wgts-rna-options-variant-calling-stage

outputs:
  - id: output_directory
    type: Directory
    outputBinding:
      glob: "$(inputs.dragen_options.output_directory)"

successCodes:
  - 0
