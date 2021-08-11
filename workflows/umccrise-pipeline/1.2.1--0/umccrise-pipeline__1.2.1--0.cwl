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
id: umccrise-pipeline--1.2.1--0
label: umccrise-pipeline v(1.2.1--0)
doc: |
   Run the umccrise-pipeline v1.2.1--0

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/umccrise-input/1.2.1--0/umccrise-input__1.2.1--0.yaml
        - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml

inputs:
  # Inputs
  umccrise_tsv_rows:
    label: umccrise tsv rows
    doc: |
      The list of tsv rows schema
    type: ../../../schemas/umccrise-input/1.2.1--0/umccrise-input__1.2.1--0.yaml#umccrise-input[]

  # Umccrise specific options
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string
  genomes_dir:
    label: genomes_dir
    doc: |
      The reference data bundle for the umccrise tool
    type: Directory
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
  stage:
    label: stage
    doc: |
      Optionally, specific stage to run, e.g.: -T pcgr -T coverage -T structural -T small_variants
    type: string[]?
  skip_stage:
    label: skip stage
    doc: |
      Optionally, stages to skip, e.g.: -E oncoviruses -E cpsr
    type: string[]?
  min_af:
    label: min af
    doc: |
      AF threshold to filter small variants (unless a known hotspot)
    type: float?
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
  dryrun:
    label: dryrun
    doc: |
      Propagated to snakemake. Prints rules and commands to be run without actually executing them.
    type: boolean?
  report:
    label: report
    doc: |
      Propagated to snakemake.
      Create an HTML report with results and statistics.
      The argument has to be a file path ending with ".html"
    type: boolean?
  dag:
    label: dag
    doc: |
      Propagated to snakemake. Print the DAG of jobs in the dot language.
    type: boolean?
  resources:
    label: resources
    doc: |
      Can be used to limit the amount of memory allowed to be used
    type: string[]?

steps:
  create_mount_paths_and_umccrise_tsv_input_jsons_step:
    label: create mount paths and umccrise tsv input jsons step
    doc: |
      Expression does two main things,
      creates a list of predefined mount paths for listing in the umccrise step
      and creates a list of jsons that represent umccrise list rows for the tsv creation
    in:
      umccrise_input_rows:
        source: umccrise_tsv_rows
    out:
     - id: predefined_mount_paths
     - id: umccrise_input_rows_as_json_str
    run: ../../../expressions/create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema/1.2.1--0/create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema__1.2.1--0.cwl
  create_umccrise_tsv_step:
    label: create umccrise tsv
    doc: |
      Create the umccrise tsv from the jsonised input rows
    in:
      input_json_strs:
        source: create_mount_paths_and_umccrise_tsv_input_jsons_step/umccrise_input_rows_as_json_str
    out:
      - id: umccrise_input_tsv
    run: ../../../tools/custom-create-umccrise-tsv/1.2.1--0/custom-create-umccrise-tsv__1.2.1--0.cwl
  run_umccrise_step:
    label: run umccrise step
    doc: |
      Run the umccrise step
    in:
      umccrise_tsv:
        source: create_umccrise_tsv_step/umccrise_input_tsv
      umccrise_tsv_mount_paths:
        source: create_mount_paths_and_umccrise_tsv_input_jsons_step/predefined_mount_paths
      output_directory_name:
        source: output_directory_name
      genomes_dir:
        source: genomes_dir
      genome:
        source: genome
      stage:
        source: stage
      skip_stage:
        source: skip_stage
      min_af:
        source: min_af
      threads:
        source: threads
      debug:
        source: debug
      dryrun:
        source: dryrun
      report:
        source: report
      dag:
        source: dag
      resources:
        source: resources
    out:
      - id: output_directory
    run: ../../../tools/umccrise/1.2.1--0/umccrise__1.2.1--0.cwl


outputs:
  output_directory:
    label: output_directory
    doc: |
      The umccrise output directory
    type: Directory
    outputSource: run_umccrise_step/output_directory


