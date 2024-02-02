cwlVersion: v1.1
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
    s:name: Peter Diakumis
    s:email: peter.diakumis@umccr.org
    s:identifier: https://orcid.org/0000-0002-7502-7545

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: umccrise--2.3.1--1
label: umccrise v(2.3.1--1)
doc: |
    Documentation for umccrise v2.3.1--1

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standardHiMem
        ilmn-tes:resources/size: medium
        coresMin: 16
        ramMin: 128000
        tmpdirMin: |
          ${
            /* 1 Tb */
            return 2 ** 20; 
          }
    DockerRequirement:
        dockerPull: 843407916570.dkr.ecr.ap-southeast-2.amazonaws.com/umccrise:2.3.1-dbedb31757

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/utils/1.0.0/utils__1.0.0.cwljs
      - $include: ../../../typescript-expressions/umccrise/2.0.0/umccrise__2.0.0.cwljs
  InitialWorkDirRequirement:
    listing:
      - entryname: "$(get_run_script_entryname())"
        entry: |
          #!/usr/bin/env bash

          # Set to fail
          set -euo pipefail

          # Create a cleanup function for the trap command
          cleanup(){
            if [[ "$(get_bool_value_as_str(inputs.debug))" == "true" ]]; then
              echo "\$(date): UMCCRise failed but debug set to true, copying over workspace into output directory" 1>&2
              cp -r "$(get_scratch_working_dir(inputs.output_directory_name))/." "$(inputs.output_directory_name)/"
            fi
            exit 1
          }

          # Create parent dir for working tmp dir
          echo "\$(date): Creating parent dir for workspace in scratch" 1>&2
          mkdir -p "$(get_scratch_working_parent_dir())"

          # Create parent dir for genomes tmp dir
          echo "\$(date): Creating parent dir for genomes" 1>&2
          # Create genomes parent directory
          mkdir -p "$(get_genomes_parent_dir())"

          # Untar umccrise genomes
          echo "\$(date): Extracting genomes directory into scratch space" 1>&2
          tar --directory "$(get_genomes_parent_dir())" \\
            --extract \\
            --file "$(inputs.genomes_tar.path)"

          # Create input directories
          mkdir -p "$(get_somatic_input_dir(inputs.dragen_somatic_directory.basename))"
          mkdir -p "$(get_germline_input_dir(inputs.dragen_germline_directory.basename))"

          # Put inputs into scratch space
          echo "\$(date): Placing inputs into scratch space" 1>&2
          cp -r "$(inputs.dragen_somatic_directory.path)/." "$(get_somatic_input_dir(inputs.dragen_somatic_directory.basename))/"
          cp -r "$(inputs.dragen_germline_directory.path)/." "$(get_germline_input_dir(inputs.dragen_germline_directory.basename))/"

          # Check if a bam file is in the inputs dragen germline directory path
          if [[ "\$(find "$(get_germline_input_dir(inputs.dragen_germline_directory.basename))/" -name '*.bam' | wc -l)" == "0" ]]; then
            echo "\$(date): No bam file in the germline directory, copying normal bam over from the tumor directory" 1>&2
            normal_bam_somatic_src="\$( \\
              find "$(get_somatic_input_dir(inputs.dragen_somatic_directory.basename))/" \\
                -maxdepth 1 \\
                -name '*_normal.bam' \\
            )"
            if [[ -z "\${normal_bam_somatic_src-}" ]]; then
              echo "\$(date): Could not get normal bam file from dragen somatic directory" 1>&2
              exit 1
            fi
            germline_replay_json_file="\$( \\
              find "$(get_germline_input_dir(inputs.dragen_germline_directory.basename))/" \\
                -maxdepth 1 \\
                -name '*-replay.json' \\
            )"
            if [[ -z "\${germline_replay_json_file-}" ]]; then
              echo "\$(date): Could not get replay json file. Could not determine germline basename" 1>&2
              exit 1
            fi
            germline_basename="\$( \\
              basename "\${germline_replay_json_file%-replay.json}" \\
            )"
            ln "\${normal_bam_somatic_src}" "$(get_germline_input_dir(inputs.dragen_germline_directory.basename))/\$(basename "\${germline_basename}.bam")"
            ln "\${normal_bam_somatic_src}.bai" "$(get_germline_input_dir(inputs.dragen_germline_directory.basename))/\$(basename "\${germline_basename}.bam.bai")"
          fi

          # Run umccrise copies over inputs if umccrise failed but debug set to true
          trap 'cleanup' EXIT

          echo "\$(date): Running UMCCRise" 1>&2
          umccrise "\${@}"

          # Exit trap, exit cleanly
          trap - EXIT

          # Copy over working directory
          echo "\$(date): UMCCRise complete, copying over outputs into output directory" 1>&2
          cp -r "$(get_scratch_working_dir(inputs.output_directory_name))/." "$(inputs.output_directory_name)/"

          echo "\$(date): Workflow complete!" 1>&2


baseCommand: [ "bash" ]

arguments:
  # Before all other arguments
  - position: -1
    valueFrom: "$(get_run_script_entryname())"

inputs:
  # Input folders and files
  dragen_somatic_directory:
    label: dragen somatic directory
    doc: |
      The dragen somatic directory
    type: Directory
    inputBinding:
      prefix: "--dragen_somatic_dir"
      valueFrom: |
        ${
          return get_somatic_input_dir(self.basename);
        }
  dragen_germline_directory:
    label: dragen germline directory
    doc: |
      The dragen germline directory
    type: Directory
    inputBinding:
      prefix: "--dragen_germline_dir"
      valueFrom: |
        ${
          return get_germline_input_dir(self.basename);
        }
  genomes_tar:
    label: genomes tar
    doc: |
      The reference umccrise tarball
    type: File
    inputBinding:
      prefix: "--genomes-dir"
      valueFrom: "$(get_genomes_dir_path(self.basename))"
  # Input IDs
  subject_identifier:
    label: subject identifier
    doc: |
      The subject ID (used to name output files)
    type: string
    inputBinding:
      prefix: "--dragen_subject_id"
  dragen_tumor_id:
    label: dragen tumor id
    doc: |
      The name of the dragen tumor sample
    type: string?
    inputBinding:
      prefix: "--dragen_tumor_id"
  dragen_normal_id:
    label: dragen normal id
    doc: |
      The name of the dragen normal sample
    type: string?
    inputBinding:
      prefix: "--dragen_normal_id"
  # Output names
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string
    inputBinding:
      prefix: "-o"
      valueFrom: |
        ${
         return get_scratch_working_dir(self);
        }
  # Optional inputs
  threads:
    label: threads
    doc: |
      Number of threads to use
    type: int?
    inputBinding:
      prefix: "--threads"
      valueFrom: |
        ${
          return get_num_threads(self, runtime.cores);
        }
  skip_stage:
    label: skip stage
    doc: |
      Runs all default stage(s) excluding the one selected
    type:
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: "--skip-stage"
    inputBinding:
      position: 99
  dry_run:
    label: dry run
    doc: |
      Prints rules and commands to be run without actually executing them
    type: boolean?
    inputBinding:
      prefix: "--dryrun"
  include_stage:
    label: include stage
    doc: |
      Optionally, specify stage(s) to run
    type:
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: "--stage"
    inputBinding:
      position: 100
  # Debugger
  debug:
    label: debug
    doc: |
      Copy workspace to output directory if workflow fails
    type: boolean?


outputs:
  output_directory:
    label: output directory
    doc: |
      The output directory containing the umccrise data
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory_name)"

successCodes:
  - 0
