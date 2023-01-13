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
id: umccrise--1.2.1--0
label: umccrise v(1.2.1--0)
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
        dockerPull: 843407916570.dkr.ecr.ap-southeast-2.amazonaws.com/umccrise:1.2.1-a8869605e8


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
  InitialWorkDirRequirement:
    listing: |
      ${
          /*
          Initialise the array of files to mount
          */

          var e = [];

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
          inputs.umccrise_tsv_mount_paths.forEach(function(mount_path_record){
            e.push({
                'entry': mount_path_record.file_obj,
                'entryname': mount_path_record.mount_path
            });
          });

          /*
          Return file paths
          */
          return e;
      }

baseCommand: [ "umccrise" ]

arguments:
  - prefix: "--threads"
    valueFrom: "$(get_num_threads())"

inputs:
  # Input / output mandatory options
  umccrise_tsv:
    label: umccrise tsv
    doc: |
      CSV file that contains the row of samples ready to process
    type: File
    inputBinding:
      prefix: "--umccrise-tsv"
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
    inputBinding:
      prefix: "-o"
  # Reference
  genomes_dir:
    label: genomes_dir
    doc: |
      The reference data bundle for the umccrise tool
    type: Directory
    inputBinding:
      prefix: "--genomes-dir"
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
