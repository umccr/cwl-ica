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
id: tso500-ctdna-demultiplex-workflow--1.2.0.1
label: tso500-ctdna-demultiplex-workflow v(1.2.0.1)
doc: |
    Runs the ctDNA demultiplex workflow from fastq stage (just the fastq validation task)
    Techinally the following steps are run:
    * FindDragenLicenseTask
    * FindDragenLicenstInstanceLocationTask
    * ResetFPGATask
    * SampleSheetValidationTask
    * ResourceVerificationTask
    * RunQcTask  # Skipped since fastqs present
    * FastqGenerationTask  # Skipped since fastqs present
    * FastqValidationTask
    This tool does NOT require the tso500 data to have the fastq files in a per 'folder' level like the ISL workflow.
    You instead use the tso500-sample schema and the fastq-list-row schema to mount the gds paths into the container
    as the WDL workflow expects them (mimicking the ISL workflow task inputs).

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: fpga
        ilmn-tes:resources/size: small
        coresMin: 8
        ramMin: 120000
    DockerRequirement:
        dockerPull: "239164580033.dkr.ecr.us-east-1.amazonaws.com/tso500-liquid-ica-wrapper:1.2.0.1"
        #dockerPull: ubuntu:latest

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/tso500-ctdna/1.2.0--1/tso500-ctdna__1.2.0--1.cwljs
  InitialWorkDirRequirement:
    listing:
      - |
        ${
          return get_demultiplex_workflow_run_mounts(inputs);
        }
      - entryname: "$(get_run_cromwell_script_path())"
        entry: |
          #!/usr/bin/env bash
          # Set up to fail
          set -euo pipefail

          echo "create analysis dirs" 1>&2
          mkdir --parents \\
            "$(get_demux_step_analysis_dir())" \\
            "$(get_fastq_dir_path())"

          # Link over the fastq files into the designated fastq folder
          echo "start linking of fastq files to fastq directory" 1>&2
          fastq_src_paths_array=( \\
              $(string_bash_array_contents(get_fastq_src_paths_array(inputs.tso500_samples))) \\
          )
          fastq_dest_paths_array=( \\
              $(string_bash_array_contents(get_fastq_dest_paths_array(inputs.tso500_samples))) \\
          )
          fastq_files_iter_range="\$(expr \${#fastq_src_paths_array[@]} - 1)"

          for i in \$(seq 0 \${fastq_files_iter_range}); do
            # First create the directory needed
            mkdir -p "\$(dirname "\${fastq_dest_paths_array[$i]}")"
            ln -s "\${fastq_src_paths_array[$i]}" "\${fastq_dest_paths_array[$i]}"
          done

          echo "completed linking of fastq files to fastq directory" 1>&2

          echo "start demultiplex workflow" 1>&2
          java \\
            -DLOG_MODE=pretty \\
            -DLOG_LEVEL=INFO \\
            -jar "$(get_cromwell_path())" \\
            run \\
              --inputs "input.json" \\
              "$(get_demux_wdl_path())"
          echo "end demultiplex workflow" 1>&2

          echo "tarring up cromwell files" 1>&2
          tar \\
            --remove-files \\
            --create \\
            --gzip \\
            --file "cromwell-executions.tar.gz" \\
            "cromwell-executions"/
          echo "completed tarring of cromwell files" 1>&2

          # Unlink all fastq files from the fastq directory
          echo "unlinking all fastq files from fastq directory" 1>&2
          for i in \$(seq 0 \${fastq_files_iter_range}); do
            unlink "\${fastq_dest_paths_array[$i]}"
          done
          echo "completed unlinking of all fastq files from fastq directory" 1>&2


baseCommand: [ "bash" ]


arguments:
  # Run the cromwell script
  - valueFrom: "$(get_run_cromwell_script_path())"
    position: 1

inputs:
  tso500_samples:
    label: tso500 samples
    doc: |
      A list of tso500 samples each element has the following attributes:
      * sample_id
      * sample_type
      * pair_id
    type: ../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0.yaml#tso500-sample[]
  samplesheet:
    # No input binding required, samplesheet is placed in input.json
    label: sample sheet
    doc: |
      The sample sheet file. Special samplesheet type, must have the Sample_Type and Pair_ID columns in the [Data] section.
      Even though we don't demultiplex, we still need the information on Sample_Type and Pair_ID to determine which
      workflow (DNA / RNA) to run through.
    type: File
  samplesheet_prefix:
    label: samplesheet prefix
    doc: |
      If using a v2 samplesheet, this points to the TSO500 section of the samplesheet.
      Leave blank for v1 samples.
    type: string?
    default: "TSO500L"
  # Run Info file
  run_info_xml:
    # Bound in listing expression
    label: run info xml
    doc: |
      The run info xml file found inside the run folder
    type: File
  # Run Parameters File
  run_parameters_xml:
    # Bound in listing expression
    label: run parameters xml
    doc: |
      The run parameters xml file found inside the run folder
    type: File
  # Reference inputs
  resources_dir:
    # No input binding required, directory path is placed in input.json
    label: resources dir
    doc: |
      The directory of resources
    type: Directory


outputs:
  output_dir:
    label: output dir
    doc: |
      The output directory of all of the files
    type: Directory
    outputBinding:
      glob: "$(get_demux_logs_intermediates_dir())"
  output_samplesheet:
    label: output samplesheet
    doc: |
      AnalysisWorkflow ready sample sheet
    type: File
    outputBinding:
      glob: "$(get_samplesheet_csv_path())"
  fastq_validation_dsdm:
    label: fastq validation dsdm
    doc: |
      The fastq validation dsdm
    type: File
    outputBinding:
      glob: "$(get_demux_dsdm_json_path())"
  # Intermediate output dirs
  fastq_validation_dir:
    label: fastq_validation_dir
    doc: |
      Intermediate output dir for fastq_validation_dir
    type: Directory?
    outputBinding:
      glob: "$(get_demux_logs_intermediates_dir())/FastqValidation"
  resource_verification_dir:
    label: resource_verification_dir
    doc: |
      Intermediate output dir for resource_verification_dir
    type: Directory?
    outputBinding:
      glob: "$(get_demux_logs_intermediates_dir())/ResourceVerification"
  samplesheet_validation_dir:
    label: samplesheet_validation_dir
    doc: |
      Intermediate output dir for samplesheet_validation_dir
    type: Directory?
    outputBinding:
      glob: "$(get_demux_logs_intermediates_dir())/SamplesheetValidation"


successCodes:
  - 0