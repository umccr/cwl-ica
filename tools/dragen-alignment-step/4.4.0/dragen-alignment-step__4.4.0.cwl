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
id: dragen-alignment-step--4.4
label: dragen-alignment-step v(4.4.0)
doc: |
    Documentation for dragen-alignment-step v4.4.0

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
      - $import: ../../../schemas/dragen-wgts-dna-options-alignment-stage/4.4.0/dragen-wgts-dna-options-alignment-stage__4.4.0.yaml
      - $import: ../../../schemas/bam-output/1.0.0/bam-output__1.0.0.yaml
      - $import: ../../../schemas/cram-output/1.0.0/cram-output__1.0.0.yaml
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
                   /* Alignment options */
                   inputs.dragen_options.alignment_options,
                   /* Mandatory dragen options */
                   {
                      "output_directory": inputs.dragen_options.output_directory,
                      "output_file_prefix": inputs.dragen_options.output_file_prefix,
                      "ref_tar": inputs.dragen_options.ref_tar,
                      "ora_reference": inputs.dragen_options.ora_reference,
                      "lic_instance_id_location": lic_instance_id_location
                   },
                   /* Stage specific mandatory parameters */
                   {
                      "intermediate_results_dir": get_intermediate_results_dir(),
                      "enable_map_align": true,
                      "enable_map_align_output": true,
                      "enable_variant_caller": false
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
              tar \\
              --directory "$(get_ref_mount())" \\
              --extract \\
              --file "$(get_attribute_from_optional_input(inputs.dragen_options.ora_reference, "path"))"
          fi

          # Run dragen command and import options from cli
          "$(get_dragen_bin_path())" "\${@}"
      - |
        ${
          return generate_sequence_data_mount_points(inputs.dragen_options.sequence_data);
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
      - ../../../schemas/dragen-wgts-dna-options-alignment-stage/4.4.0/dragen-wgts-dna-options-alignment-stage__4.4.0.yaml#dragen-wgts-dna-options-alignment-stage

outputs:
  output_directory:
    label: output-directory
    doc: |
      The output directory of the DRAGEN pipeline
    type: Directory
    outputBinding:
      glob: "$(inputs.dragen_options.output_directory)"
  output_alignment_file:
    label: output alignment file
    doc: |
      The output alignment file of the DRAGEN pipeline
    type:
      - ../../../schemas/bam-output/1.0.0/bam-output__1.0.0.yaml#bam-output
      - ../../../schemas/cram-output/1.0.0/cram-output__1.0.0.yaml#cram-output
    outputBinding:
      glob: "$(inputs.dragen_options.output_directory)/$(inputs.dragen_options.output_file_prefix).*"
      outputEval: |
        ${
          var file_obj = {};
          var secondary_file_obj = {};

          if (!inputs.dragen_options.output_format){
            /* Default to BAM */
            var output_format = "BAM";
          } else {
            var output_format = inputs.dragen_options.output_format;
          }

          /* Use the suffix to determine the output type, since output_format can be null */
          self.forEach(function(file_iter_) {
            if (file_iter_.nameext == ".bam") {
              file_obj = file_iter_;
            } else if (file_iter_.nameext == ".bai") {
              secondary_file_obj = file_iter_;
            } else if (file_iter_.nameext == ".cram") {
              file_obj = file_iter_;
            } else if (file_iter_.nameext == ".crai") {
              secondary_file_obj = file_iter_;
            }
          });

          /* Append the secondary file to the output */
          file_obj.secondaryFiles = [secondary_file_obj];

          if (output_format === "BAM") {
            return {
              "bam_output": file_obj
            };
          } else if (output_format === "CRAM") {
            return {
              "cram_output": file_obj
            };
          } else {
            throw new Error("Unsupported output format: " + output_format);
          }
        }


successCodes:
  - 0
