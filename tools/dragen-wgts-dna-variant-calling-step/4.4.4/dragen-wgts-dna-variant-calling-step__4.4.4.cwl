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
id: dragen-variant-calling-step--4.4.4
label: dragen-variant-calling-step v(4.4.4)
doc: |
    Documentation for dragen-variant-calling-step v4.4.0

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
      ilmn-tes:resources/tier: standard
      ilmn-tes:resources/type: fpga
      ilmn-tes:resources/size: medium
      coresMin: 16
      ramMin: 240000
    DockerRequirement:
        # Dragen 4.4.4
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
      - $import: ../../../schemas/dragen-wgts-dna-options-variant-calling-stage/4.4.4/dragen-wgts-dna-options-variant-calling-stage__4.4.4.yaml
  InitialWorkDirRequirement:
    listing:
      - entryname: "$(get_dragen_config_path())"
        entry: |
          ${

            /*
              Check if theres any tumor alignment data,
              if so rename bam / cram input params to have tumor_ prefix
            */
            var tumor_alignment_data = {};
            if (inputs.dragen_options.tumor_alignment_data){
              if (inputs.dragen_options.tumor_alignment_data.bam_input){
                /* Has bam input */
                tumor_alignment_data["tumor_bam_input"] = inputs.dragen_options.tumor_alignment_data.bam_input;
              } else {
                /* Has cram input */
                tumor_alignment_data["tumor_cram_input"] = inputs.dragen_options.tumor_alignment_data.cram_input;

                /* Check for cram reference */
                if (inputs.dragen_options.tumor_alignment_data.cram_reference){
                  /* Has cram reference */
                  tumor_alignment_data["tumor_cram_reference"] = inputs.dragen_options.tumor_alignment_data.cram_reference;
                }
              }
            }

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
                   inputs.dragen_options.alignment_data,
                   tumor_alignment_data,
                   /* SNV VC Options */
                   inputs.dragen_options.snv_variant_caller_options,
                   /* CNV Options */
                   inputs.dragen_options.cnv_caller_options,
                   /* MAF Conversion Options */
                   inputs.dragen_options.maf_conversion_options,
                   /* SV Caller Options */
                   inputs.dragen_options.sv_caller_options,
                   /* Nirvana Annotation Options */
                   inputs.dragen_options.nirvana_annotation_options,
                   /* Targeted Caller Options */
                   inputs.dragen_options.targeted_caller_options,
                   /* Dragen mandatory options */
                   {
                      "output_directory": inputs.dragen_options.output_directory,
                      "output_file_prefix": inputs.dragen_options.output_file_prefix,
                      "ref_tar": inputs.dragen_options.ref_tar,
                      "lic_instance_id_location": lic_instance_id_location
                   },
                   /* VC Mandatory options */
                   {
                      /* We push this to /scratch */
                      "intermediate_results_dir": get_intermediate_results_dir(),
                      /* Force enable parameters */
                      "enable_map_align": false,
                      "enable_map_align_output": false,
                      "enable_variant_caller": true
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

          # Run dragen command and import options from cli
          "$(get_dragen_bin_path())" "\${@}"
      - |
        ${
          /* Tumor alignment data may be undefined */
          return generate_alignment_data_mount_points(
            inputs.dragen_options.alignment_data,
            inputs.dragen_options.tumor_alignment_data
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
      - ../../../schemas/dragen-wgts-dna-options-variant-calling-stage/4.4.4/dragen-wgts-dna-options-variant-calling-stage__4.4.4.yaml#dragen-wgts-dna-options-variant-calling-stage

outputs:
  - id: output_directory
    type: Directory
    outputBinding:
      glob: "$(inputs.dragen_options.output_directory)"

successCodes:
  - 0
