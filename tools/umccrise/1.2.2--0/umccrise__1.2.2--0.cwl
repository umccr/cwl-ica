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
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: umccrise--1.2.2--0
label: umccrise v(1.2.2--0)
doc: |

  Run the umccrise workflow
  
# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standardHiCpu
        ilmn-tes:resources/size: large
        coresMin: 71
        ramMin: 140000
    DockerRequirement:
        dockerPull: 843407916570.dkr.ecr.ap-southeast-2.amazonaws.com/umccrise:1.2.2-7d6a20398f


requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml
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
          return "run-umccrise.sh";
        }
      - var get_run_script_entry = function(){
          /*
          Get the contents of the shell script
          */
          return "#!/usr/bin/env bash\n" +
                 "\n" +
                 "# Set to fail\n" +
                 "set -euo pipefail\n" +
                 "\n" +
                 "# Create parent dir for genomes tmp dir\n" +
                 "echo \"\$(date):\ Creating parent dir for workspace in scratch\" 1>&2\n" +
                 "mkdir -p" + " " + "\"" + get_scratch_working_parent_dir() + "\"\n" +
                 "\n" +
                 "# Create parent dir for genomes tmp dir\n" +
                 "echo \"\$(date):\ Creating parent dir for genomes\" 1>&2\n" +
                 "mkdir -p" + " " + "\"" + get_genomes_parent_dir() + "\"\n" +
                 "\n" +
                 "# Untar umccrise genomes\n" +
                 "echo \"\$(date):\ Extracting genomes directory into scratch space\" 1>&2\n" +
                 "tar -C" + " " + "\"" + get_genomes_parent_dir() + "\"" + " " + "-xf" + " " + "\"" + inputs.genomes_tar.path + "\"" + "\n" +
                 "\n" +
                 "# Put inputs into scratch space\n" +
                 "echo \"\$(date):\ Placing inputs into scratch space\" 1>&2\n" +
                 "cp -r \"inputs/.\"" + " " + "\"" + get_scratch_input_dir() + "/\"" + "\n" +
                 "\n" +
                 "# Copy over modified umccrise tsv to run time directory\n" +
                 "echo \"\$(date):\ Editing umccrise tsv file to turn relative paths to absolute paths in scratch space\" 1>&2\n" +
                 "sed \"s%__WORK_DIR__%" + get_scratch_mount() + "%g\"" + " " + "\"" + inputs.umccrise_tsv.path + "\"" + " > " + "\"" + inputs.umccrise_tsv.basename + "\"\n" +
                 "\n" +
                 "# Run umccrise\n" +
                 "echo \"\$(date):\ Running umccrise in scratch space\" 1>&2 \n" +
                 "eval umccrise '\"\${@}\"'\n" +
                 "\n" +
                 "# Copy over working directory\n" +
                 "echo \"\$(date):\ UMCCRise complete, copying over outputs into output directory\" 1>&2\n" +
                 "cp -r" + " " + "\"" + get_scratch_working_dir() + "/.\"" + " " + "\"" + inputs.output_directory_name + "/\"" + "\n" +
                 "\n" +
                 "echo \"\$(date):\ Workflow complete!\" 1>&2\n";
        }
  InitialWorkDirRequirement:
    listing: |
      ${
          /*
          Initialise the array of files to mount - need to place the script in the runtime directory
          */
          var e = [
                    {
                      "entryname": get_run_script_entryname(),
                      "entry": get_run_script_entry()
                    }
                  ];

          /*
          Check if input_mounts record is defined
          The umccrise_tsv_mount_paths could be using presigned urls instead
          */
          if (inputs.umccrise_tsv_mount_paths === null){
              return e;
          }

          /*
          Iterate through each file to mount
          Mount that object at the same reference to the mount point index.
          */
          for (var mount_record_iter=0; mount_record_iter < inputs.umccrise_tsv_mount_paths.length; mount_record_iter++){
            /*
            Assign object first
            */
            var mount_path_record = inputs.umccrise_tsv_mount_paths[mount_record_iter];

            /*
            Add mount path record to listing
            */
            e.push(
                     {
                        "entryname": mount_path_record.mount_path,
                        "entry": mount_path_record.file_obj
                     }
                   );

          }

          /*
          Return file paths
          */
          return e;
      }

baseCommand: [ "bash" ]

arguments:
  # Before all other commands
  - valueFrom: "$(get_run_script_entryname())"
    position: -1
  # Wherever
  - prefix: "--threads"
    valueFrom: "$(get_num_threads())"
  - prefix: "--genomes-dir"
    valueFrom: "$(get_genomes_dir_path())"
  - prefix: "-o"
    valueFrom: "$(get_scratch_working_dir())"
  # After all other parameters
  - valueFrom: "$(inputs.umccrise_tsv.basename)"
    position: 100

inputs:
  # Input / output mandatory options
  umccrise_tsv:
    label: umccrise tsv
    doc: |
      CSV file that contains the row of samples ready to process
    type: File
  umccrise_tsv_mount_paths:
    label: umccrise tsv mount paths
    doc: |
      Path to umccrise tsv mount path
    type: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml#predefined-mount-path[]?
  output_directory_name:
    label: output directory
    doc: |
      The name of the output directory
    type: string
  # Reference
  genomes_tar:
    label: genomes tar
    doc: |
      The reference data bundle for the umccrise tool
    type: File
  sample:
    label: sample
    doc: |
      Optionally, specific sample or batch to process
    type: string?
    inputBinding:
      prefix: "--sample"
  exclude:
    label: exclude
    doc: |
      Optionally, samples or batches to ignore
    type: string?
    inputBinding:
      prefix: "--exclude"
  genome:
    label: genome
    doc: |
      genome
    type:
      - "null"
      - type: enum
        symbols:
          - "GRCh37"
          - "hg38"
    inputBinding:
      prefix: "--genome"
  stage:
    label: stage
    doc: |
      Optionally, specific stage to run, e.g.: -T pcgr -T coverage -T structural -T small_variants
    type:
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: "--stage"
  skip_stage:
    label: skip stage
    doc: |
      Optionally, stages to skip, e.g.: -E oncoviruses -E cpsr
    type:
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: "--skip-stage"
  min_af:
    label: min af
    doc: |
      AF threshold to filter small variants (unless a known hotspot)
    type: float?
    inputBinding:
      prefix: "--min-af"
  threads:
    label: threads
    doc: |
      Maximum number of cores to use at single time.
      Defaults to runtime.cores
    type: int?
  debug:
    label: debug
    doc: |
      More verbose messages
    type: boolean?
    inputBinding:
      prefix: "--debug"
  dryrun:
    label: dryrun
    doc: |
      Propagated to snakemake. Prints rules and commands to be run without actually executing them.
    type: boolean?
    inputBinding:
      prefix: "--dryrun"
  report:
    label: report
    doc: |
      Propagated to snakemake.
      Create an HTML report with results and statistics.
      The argument has to be a file path ending with ".html"
    type: boolean?
    inputBinding:
      prefix: "--report"
  dag:
    label: dag
    doc: |
      Propagated to snakemake. Print the DAG of jobs in the dot language.
    type: boolean?
    inputBinding:
      prefix: "--dag"
  resources:
    label: resources
    doc: |
      Can be used to limit the amount of memory allowed to be used
    type:
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: "--resources"
  restarts:
    label: restarts
    doc: |
      Number of attempts to complete a job
    type: int?
    inputBinding:
      prefix: "--restart-times"

outputs:
  output_directory:
    label: output directory
    doc: |
      The output directory
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory_name)"

successCodes:
  - 0
