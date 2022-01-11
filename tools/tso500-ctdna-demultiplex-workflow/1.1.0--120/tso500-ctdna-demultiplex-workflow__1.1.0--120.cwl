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
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: tso500-ctdna-demultiplex-workflow--1.1.0.120
label: tso500-ctdna-demultiplex-workflow v(1.1.0.120)
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

hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: fpga
            size: small
        coresMin: 8
        ramMin: 120000
    DockerRequirement:
        dockerPull: "239164580033.dkr.ecr.us-east-1.amazonaws.com/acadia-500-liquid-workflow-aws:ruo-1.1.0.120"
        #dockerPull: ubuntu:latest

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      # Standard
      - var abs_path = function(rel_path) {
          /*
          Return the absolute path of a relative path
          */
          return runtime.outdir + "/" + rel_path;
        }
      # Paths to inbuilt files
      - var get_cromwell_path = function() {
          return "/opt/cromwell/cromwell.jar";
        }
      - var get_demux_wdl_path = function() {
          return "/opt/illumina/wdl/DemultiplexWorkflow.wdl";
        }
      - var get_run_dir_path = function() {
          return "run";
        }
      # Paths to inline directories
      - var get_analysis_dir = function() {
          return "demux_workflow";
        }
      - var get_logs_intermediates_dir = function() {
          return get_analysis_dir() + "/" + "demux_outputs";
        }
      - var get_dragen_license_instance_folder = function() {
          /*
          Not required since we're not actually demuxing anything
          */
          return "";
        }
      - var get_fastq_dir_path = function() {
          return "fastqs";
        }
      - var get_fastq_list_file_mounts = function(sample_id, sample_number, input_fastq_list_rows){
          /*
          Return a list of entry/entryname dicts to be mounted for a given sample
          */

          /*
          Initialise an array of dicts
          */
          var e_ext = [];

          /*
          Iterate through each fastq list row
          Mount each read1 file with the following nomenclature

          Note key-values are squished together otherwise yaml has a hissy-fit
          */

          for (var i = 0; i < input_fastq_list_rows.length; i++){
            /*
            Get the file objects
            */
            var read_1_file_obj = input_fastq_list_rows[i].read_1;
            var read_2_file_obj = input_fastq_list_rows[i].read_2;
            var lane = input_fastq_list_rows[i].lane;

            /*
            Set the basenames for each file
            */
            var read_1_base_name = sample_id + "_S" + String(sample_number) + "_L" + String(lane).padStart(3, '0') + "_R1_" + "001.fastq.gz";
            var read_2_base_name = sample_id + "_S" + String(sample_number) + "_L" + String(lane).padStart(3, '0') + "_R2_" + "001.fastq.gz";

            /*
            Set the mount points for each file
            */
            var read_1_mount_point = get_fastq_dir_path() + "/" + sample_id + "/" + read_1_base_name;
            var read_2_mount_point = get_fastq_dir_path() + "/" + sample_id + "/" + read_2_base_name;

            /*
            Extend list with read 1 and read 2 fastq file objects at the set mountpoints
            */
            e_ext = e_ext.concat([
              {
                "entryname":read_1_mount_point,
                "entry":read_1_file_obj
              },
              {
                "entryname":read_2_mount_point,
                "entry":read_2_file_obj
              }
            ]);
          }

          /*
          Return the list of mount points for this sample
          */
          return e_ext;
        }
      # Paths to inline files
      - var get_input_json_path = function() {
          return "input.json";
        }
      - var get_run_cromwell_script_path = function() {
          return "run_cromwell.sh";
        }
      # Paths to outputs
      - var get_dsdm_json_path = function() {
          return get_logs_intermediates_dir() + "/" + "FastqValidation" + "/" + "dsdm.json"
        }
      - var get_samplesheet_csv_path = function() {
          return get_logs_intermediates_dir() + "/" + "SamplesheetValidation" + "/" + "SampleSheet_Intermediate.csv";
        }
      # Miscell
      - var get_sample_ids = function() {
          /*
          Iterate through each item in the tso500_samples input and return the sample_id attribute
          */

          /*
          Initialise sample ids list
          */
          var sample_ids = []

          /*
          Iterate through inputs
          */
          for (var i=0; i < inputs.tso500_samples.length; i++){
            sample_ids.push(inputs.tso500_samples[i].sample_id);
          }

          /*
          Return joined as comma separated values
          */
          return sample_ids.join(",");

        }
      # Path contents
      - var get_input_json_content = function(){
          /*
          Create a json file based on inputs and then stringify
          */
          return JSON.stringify({
                   "DemultiplexWorkflow.runFolder":abs_path(get_run_dir_path()),
                   "DemultiplexWorkflow.fastqFolder":abs_path(get_fastq_dir_path()),
                   "DemultiplexWorkflow.analysisFolder":abs_path(get_analysis_dir()),
                   "DemultiplexWorkflow.logsIntermediatesFolder":abs_path(get_logs_intermediates_dir()),
                   "DemultiplexWorkflow.resourceFolder":inputs.resources_dir.path,
                   "DemultiplexWorkflow.sampleSheet":inputs.samplesheet.path,
                   "DemultiplexWorkflow.sampleIdentifiers":get_sample_ids(),
                   "DemultiplexWorkflow.sampleSheetPrefix":inputs.samplesheet_prefix,
                   "DemultiplexWorkflow.dragenLicenseKeyFolder":abs_path(get_analysis_dir()),
                   "DemultiplexWorkflow.dragenLicenseInstanceFolder":get_dragen_license_instance_folder()
                 });
        }
  InitialWorkDirRequirement:
    listing:
      - |
        ${
          /*
          Initialise listing with input jsons and cromwell script and run folder files
          */
          var e = [
                    /*
                    Input json
                    */
                    {
                     "entryname": get_input_json_path(),
                     "entry": get_input_json_content()
                    },
                    /*
                    RunInfo.xml
                    */
                    {
                     "entryname": get_run_dir_path() + "/" + "RunInfo.xml",
                     "entry": inputs.run_info_xml
                    },
                    /*
                    RunParameters.xml
                    */
                    {
                     "entryname": get_run_dir_path() + "/" + "RunParameters.xml",
                     "entry": inputs.run_parameters_xml
                    }
                  ];
  
          /*
          Iterate through each tso500 sample and place fastq files under the sample_id folder
          */
          for (var i = 0; i < inputs.tso500_samples.length; i++){
            /*
            Extend the listing for each sample present
            First we must get matching fastq list rows as inputs
            */
            var sample_id = inputs.tso500_samples[i].sample_id;
            var sample_name = inputs.tso500_samples[i].sample_name;
            var sample_number = i + 1;
  
            /*
            Iterate over the input fastq list rows and match rgsm values to the sample_name of the tso500 sample
            */
            var input_fastq_list_rows = [];
            for (var j = 0; j < inputs.fastq_list_rows.length; j++){
              /*
              Append fastq list rows items with matching rgsm values
              */
              if (inputs.fastq_list_rows[j].rgsm === sample_name){
                /*
                Append fastq list row
                */
                input_fastq_list_rows.push(inputs.fastq_list_rows[j]);
              }
            }
            /*
            Now mount according to the sample id
            */
            e = e.concat(get_fastq_list_file_mounts(sample_id, sample_number, input_fastq_list_rows));
          }
  
          /*
          Return entries
          */
          return e;
        }
      -  entryname: "$(get_run_cromwell_script_path())"
         entry: |
           #!/usr/bin/env bash
           # Set up to fail
           set -euo pipefail
           
           echo "create analysis dirs" 1>&2
           mkdir --parents \\
             "$(get_analysis_dir())"
           
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
    type: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml#tso500-sample[]
  fastq_list_rows:
    label: fastq list rows
    doc: |
      A list of fastq list rows where each element has the following attributes
      * rgid  # Not used
      * rgsm
      * rglb  # Not used
      * read_1
      * read_2
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
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
      glob: "$(get_logs_intermediates_dir())"
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
      glob: "$(get_dsdm_json_path())"
  # Intermediate output dirs
  fastq_validation_dir:
    label: fastq_validation_dir
    doc: |
      Intermediate output dir for fastq_validation_dir
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_dir())/FastqValidation"
  resource_verification_dir:
    label: resource_verification_dir
    doc: |
      Intermediate output dir for resource_verification_dir
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_dir())/ResourceVerification"
  samplesheet_validation_dir:
    label: samplesheet_validation_dir
    doc: |
      Intermediate output dir for samplesheet_validation_dir
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_dir())/SamplesheetValidation"

successCodes:
  - 0