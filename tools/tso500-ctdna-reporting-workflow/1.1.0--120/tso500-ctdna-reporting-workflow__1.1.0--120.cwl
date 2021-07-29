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
id: tso500-ctdna-reporting-workflow--1.1.0.120
label: tso500-ctdna-reporting-workflow v(1.1.0.120)
doc: |
    Documentation for tso500-ctdna-reporting-workflow v1.1.0.120

hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: fpga
            size: small
        coresMin: 8
        ramMin: 120000
    DockerRequirement:
        #dockerPull: ubuntu:latest
        dockerPull: "239164580033.dkr.ecr.us-east-1.amazonaws.com/acadia-500-liquid-workflow-aws:ruo-1.1.0.120"

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      # Standard
      - var abs_path = function(rel_path) {
          /*
          Return the absolute path of a relative path
          */
          return runtime.outdir + "/" + rel_path;
        }
      # Paths to inbuilt files / directories
      - var get_cromwell_path = function() {
          return "/opt/cromwell/cromwell.jar";
        }
      - var get_reporting_wdl_path = function() {
          return "/opt/illumina/wdl/ReportingWorkflow.wdl";
        }
      # Paths to inline directories
      - var get_analysis_dir = function() {
          return "reporting_workflow";
        }
      - var get_scratch_mount = function() {
          return "/scratch";
        }
      - var get_logs_intermediates_dir = function() {
          return get_analysis_dir() + "/" + "reporting_outputs";
        }
      - var get_writable_input_dir = function() {
          return get_scratch_mount() + "/" + "analysis_workflow_outputs";
        }
      - var get_results_dir = function() {
          return "results";
        }
      - var get_run_dir_path = function() {
          return "run";
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
          return get_logs_intermediates_dir() + "/" + "Cleanup" + "/" + "dsdm.json";
        }
      # Path contents
      - var get_input_json_content = function(){
          /*
          Create a json file based on inputs and then stringify
          */
          return JSON.stringify({
                   "ReportingWorkflow.dsdmFile":inputs.contamination_dsdm.path,
                   "ReportingWorkflow.runFolder":abs_path(get_run_dir_path()),
                   "ReportingWorkflow.analysisFolder":abs_path(get_analysis_dir()),
                   "ReportingWorkflow.logsIntermediatesFolder":abs_path(get_logs_intermediates_dir()),
                   "ReportingWorkflow.inputFolder":get_writable_input_dir(),
                   "ReportingWorkflow.resourceFolder":inputs.resources_dir.path,
                   "ReportingWorkflow.resultsFolder":abs_path(get_results_dir()),
                   "ReportingWorkflow.startFromFastq":true,
                   "ReportingWorkflow.sampleSheetPath":inputs.samplesheet.path,
                   "ReportingWorkflow.sampleSheetPrefix":inputs.samplesheet_prefix
                 });
        }
      - var get_run_cromwell_script_content = function() {
          return "#!/usr/bin/env bash\n" +
                 "# Set up to fail\n" +
                 "set -euo pipefail\n\n" +
                 "echo \"create analysis dirs\" 1>&2\n" +
                 "mkdir --parents \\\n" +
                 "  \"" + get_results_dir() + "\" \\\n" +
                 "  \"" + get_writable_input_dir() + "\" \\\n" +
                 "  \"" + get_analysis_dir() + "\"\n\n" +
                 "echo \"copy outputs from analysis workflow to local writable dir\" 1>&2\n" +
                 "cp -r \"" + inputs.analysis_folder.path +  "/.\" \"" + get_writable_input_dir() + "/\"\n" +
                 "echo \"start reporting workflow task\" 1>&2\n" +
                 "java \\\n" +
                 "  -DLOG_MODE=pretty \\\n" +
                 "  -DLOG_LEVEL=INFO \\\n" +
                 "  -jar \"" + get_cromwell_path() + "\" \\\n" +
                 "  run \\\n" +
                 "    --inputs \"" + get_input_json_path() + "\" \\\n" +
                 "    \"" + get_reporting_wdl_path() + "\"\n" +
                 "echo \"end reporting workflow task\" 1>&2\n\n" +
                 "echo \"tarring up cromwell files\" 1>&2\n" +
                 "tar \\\n" +
                 "  --remove-files \\\n" +
                 "  --create \\\n" +
                 "  --gzip \\\n" +
                 "  --file \"cromwell-executions.tar.gz\" \\\n" +
                 "  \"cromwell-executions/\"\n" +
                 "echo \"completed tarring of cromwell files\" 1>&2\n";
        }
  InitialWorkDirRequirement:
    listing: |
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
                  Cromwell script
                  */
                  {
                   "entryname": get_run_cromwell_script_path(),
                   "entry": get_run_cromwell_script_content()
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
        return e;
      }

baseCommand: [ "bash" ]

arguments:
  # Run the cromwell script
  - valueFrom: "$(get_run_cromwell_script_path())"
    position: 1

inputs:
  analysis_folder:
    label: analysis folder
    doc: |
      Output from the analysis workflow
    type: Directory
  run_parameters_xml:
    label: run parameters xml
    doc: |
      The run parameters xml file
    type: File
  run_info_xml:
    label: run info xml
    doc: |
      The run info xml file
    type: File
  resources_dir:
    label: resources
    doc: |
      The resources directory
    type: Directory
  contamination_dsdm:
    label: contamination dsdm
    doc: |
      The contamination dsdm file from the analysis workflow
    type: File
  samplesheet:
    label: samplesheet csv
    doc: |
      The intermediate samplesheet generated by the demux workflow
    type: File
  samplesheet_prefix:
    label: samplesheet prefix
    doc: |
      The v2 prefix of the data and setting section for the TSO500 workflow
      Updates the existing V1 values of the SampleSheet
    type: string?
    default: "TSO500L"


outputs:
  output_dir:
    label: output dir
    doc: |
      The output files of the reporting workflow
    type: Directory
    outputBinding:
      glob: "$(get_logs_intermediates_dir())"
  results_dir:
    label: results dir
    doc: |
      The results directory containing all of the collated items of the TSO500 ctDNA workflow
    type: Directory
    outputBinding:
      glob: "$(get_results_dir())"
  cleanup_dsdm:
    label: cleanup dsdm
    doc: |
      The cleanup task dsdm json file
    type: File
    outputBinding:
      glob: "$(get_dsdm_json_path())"
  # Intermediate outputs dir
  cleanup_dir:
    label: cleanup_dir
    doc: |
      Intermediate output dir for cleanup_dir
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_dir())/Cleanup"
  combined_variant_output_dir:
    label: combined_variant_output_dir
    doc: |
      Intermediate output dir for combined_variant_output_dir
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_dir())/CombinedVariantOutput"
  metrics_output_dir:
    label: metrics_output_dir
    doc: |
      Intermediate output dir for metrics_output_dir
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_dir())/MetricsOutput"
  sample_analysis_results_dir:
    label: sample_analysis_results_dir
    doc: |
      Intermediate output dir for sample analysis results
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_dir())/SampleAnalysisResults"

successCodes:
  - 0
