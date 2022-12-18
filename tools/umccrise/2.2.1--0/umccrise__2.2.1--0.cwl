cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: http://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Peter Diakumis
    s:email: peter.diakumis@umccr.org
    s:identifier: https://orcid.org/0000-0002-7502-7545

# ID/Docs
id: umccrise--2.2.1--0
label: umccrise v(2.2.1--0)
doc: |
    Documentation for umccrise v2.2.1--0

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:tier: standard
        ilmn-tes:resources:type: standardHiMem
        ilmn-tes:resources:size: medium
        coresMin: 16
        ramMin: 50000
    DockerRequirement:
        dockerPull: 843407916570.dkr.ecr.ap-southeast-2.amazonaws.com/umccrise:2.2.1-8f677de0b9

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_num_threads = function(){
          /*
          Use all cores unless 'threads' is set
          */
          if (inputs.threads !== null){
            return inputs.threads;
          } else {
            return runtime.cores;
          }
        }
      - var get_scratch_mount = function() {
          /*
          Get the scratch mount directory
          */
          return "/scratch";
        }
      - var get_name_root_from_tarball = function(tar_file) {
          /*
          Get the name of the reference folder
          */
          var tar_ball_regex = /(\S+)\.tar\.gz/g;
          return tar_ball_regex.exec(tar_file)[1];
        }
      - var get_genomes_parent_dir = function(){
          /*
          Get the genomes directory
          */
          return get_scratch_mount() + "/" + "genome_dir";
        }
      - var get_scratch_working_parent_dir = function(){
          /*
          Get the parent directory for the working directory
          By just on the off chance someone happens to stupidly set the output as 'genome'
          */
          return get_scratch_mount() + "/" + "working_dir";
        }
      - var get_scratch_working_dir = function(){
          /*
          Get the scratch working directory
          */
          return get_scratch_working_parent_dir() + "/" + inputs.output_directory_name;
        }
      - var get_scratch_input_dir = function(){
          /*
          Get the inputs directory in /scratch space
          */
          return get_scratch_mount() + "/" + "inputs";
        }
      - var get_genomes_dir_name = function(){
          /*
          Return the stripped basename of the genomes tarball
          */
          return get_name_root_from_tarball(inputs.genomes_tar.basename);
        }
      - var get_genomes_dir_path = function(){
          /*
          Get the genomes dir path
          */
          return get_genomes_parent_dir() + "/" + get_genomes_dir_name();
        }
      - var get_run_script_entryname = function(){
          /*
          Get the run script entry name
          */
          return "scripts/run-umccrise.sh";
        }
      - var get_eval_umccrise_line = function(){
          /*
          Get the line eval umccrise...
          */
          return "eval \"umccrise\" '\"\$@\"'\n"
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: "$(get_run_script_entryname())"
        entry: |
          #!/usr/bin/env bash

          # Set to fail
          set -euo pipefail

          # Create parent dir for genomes tmp dir
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
          mkdir -p "$(get_scratch_input_dir())/$(inputs.dragen_somatic_directory.basename)/"
          mkdir -p "$(get_scratch_input_dir())/$(inputs.dragen_germline_directory.basename)/"

          # Put inputs into scratch space
          echo "\$(date): Placing inputs into scratch space" 1>&2
          cp -r "$(inputs.dragen_somatic_directory.path)/." "$(get_scratch_input_dir())/$(inputs.dragen_somatic_directory.basename)/"
          cp -r "$(inputs.dragen_germline_directory.path)/." "$(get_scratch_input_dir())/$(inputs.dragen_germline_directory.basename)/"

          # Run umccrise
          echo "\$(date): Running UMCCrise" 1>&2
          $(get_eval_umccrise_line())

          # Copy over working directory
          echo "\$(date): UMCCRise complete, copying over outputs into output directory" 1>&2
          cp -r "$(get_scratch_working_dir())/." "$(inputs.output_directory_name)/"

          echo "\$(date): Workflow complete!" 1>&2


baseCommand: [ "bash" ]

arguments:
  # Before all other arguments
  - position: -1
    valueFrom: "$(get_run_script_entryname())"
  # Wherever
  - prefix: "--threads"
    valueFrom: "$(get_num_threads())"
  - prefix: "-o"
    valueFrom: "$(get_scratch_working_dir())"

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
          return get_scratch_input_dir() + "/" + self.basename;
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
          return get_scratch_input_dir() + "/" + self.basename;
        }
  genomes_tar:
    label: genomes tar
    doc: |
      The reference umccrise tarball
    type: File
    inputBinding:
      prefix: "--genomes-dir"
      valueFrom: "$(get_genomes_dir_path())"
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
    type: string
    inputBinding:
      prefix: "--dragen_tumor_id"
  dragen_normal_id:
    label: dragen normal id
    doc: |
      The name of the dragen normal sample
    type: string
    inputBinding:
      prefix: "--dragen_normal_id"
  # Output names
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string
  # Optional inputs
  threads:
    label: threads
    doc: |
      Number of threads to use
    type: int?

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
