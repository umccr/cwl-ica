"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_reporting_workflow_run_mounts = exports.get_analysis_workflow_run_mounts = exports.get_demultiplex_workflow_run_mounts = exports.get_fastq_dest_paths_array = exports.get_fastq_src_paths_array = exports.get_array_of_fastq_paths = exports.string_bash_array_contents = exports.get_reporting_workflow_json_content = exports.get_analysis_workflow_input_json_content = exports.get_demultiplex_workflow_input_json_content = exports.get_dest_fastq_paths = exports.get_sample_ids = exports.get_samplesheet_csv_path = exports.get_analysis_logs_intermediates_output_dir = exports.get_reporting_dsdm_json_path = exports.get_analysis_dsdm_json_path = exports.get_demux_dsdm_json_path = exports.get_run_cromwell_script_path = exports.get_input_json_path = exports.get_dragen_license_path = exports.get_dragen_license_instance_folder = exports.get_dragen_license_key_folder = exports.get_results_dir = exports.get_writable_input_dir = exports.get_reporting_logs_intermediates_dir = exports.get_analysis_logs_intermediates_dir = exports.get_demux_logs_intermediates_dir = exports.get_output_dir = exports.get_reporting_step_analysis_dir = exports.get_analysis_step_analysis_dir = exports.get_demux_step_analysis_dir = exports.get_fastq_dir_path = exports.get_run_dir_path = exports.get_scratch_resources_dir = exports.get_scratch_mount = exports.get_reporting_wdl_path = exports.get_analysis_wdl_path = exports.get_demux_wdl_path = exports.get_cromwell_path = exports.abs_path = void 0;
// Functions
// Get path functions
function abs_path(rel_path) {
    /*
    Return the absolute path of a relative path
    */
    // Ignore runtime not existing
    // @ts-ignore
    return runtime.outdir + "/" + rel_path;
}
exports.abs_path = abs_path;
function get_cromwell_path() {
    /*
    Return the hard-coded cromwell path in the directory
    */
    return "/opt/cromwell/cromwell.jar";
}
exports.get_cromwell_path = get_cromwell_path;
function get_demux_wdl_path() {
    /*
    Get the demux workflow wdl path
    */
    return "/opt/illumina/wdl/DemultiplexWorkflow.wdl";
}
exports.get_demux_wdl_path = get_demux_wdl_path;
function get_analysis_wdl_path() {
    return "/opt/illumina/wdl/AnalysisWorkflow.wdl";
}
exports.get_analysis_wdl_path = get_analysis_wdl_path;
function get_reporting_wdl_path() {
    return "/opt/illumina/wdl/ReportingWorkflow.wdl";
}
exports.get_reporting_wdl_path = get_reporting_wdl_path;
function get_scratch_mount() {
    return "/scratch";
}
exports.get_scratch_mount = get_scratch_mount;
function get_scratch_resources_dir() {
    return get_scratch_mount() + "/" + "resources";
}
exports.get_scratch_resources_dir = get_scratch_resources_dir;
function get_run_dir_path() {
    return "run";
}
exports.get_run_dir_path = get_run_dir_path;
function get_fastq_dir_path() {
    return "fastqs";
}
exports.get_fastq_dir_path = get_fastq_dir_path;
function get_demux_step_analysis_dir() {
    return "demux_workflow";
}
exports.get_demux_step_analysis_dir = get_demux_step_analysis_dir;
function get_analysis_step_analysis_dir() {
    return get_scratch_mount() + "/" + "analysis_workflow";
}
exports.get_analysis_step_analysis_dir = get_analysis_step_analysis_dir;
function get_reporting_step_analysis_dir() {
    return "reporting_workflow";
}
exports.get_reporting_step_analysis_dir = get_reporting_step_analysis_dir;
function get_output_dir() {
    // @ts-ignore
    return inputs.output_dirname;
}
exports.get_output_dir = get_output_dir;
function get_demux_logs_intermediates_dir() {
    return get_demux_step_analysis_dir() + "/" + "demux_outputs";
}
exports.get_demux_logs_intermediates_dir = get_demux_logs_intermediates_dir;
function get_analysis_logs_intermediates_dir() {
    return get_analysis_step_analysis_dir() + "/" + "analysis_outputs";
}
exports.get_analysis_logs_intermediates_dir = get_analysis_logs_intermediates_dir;
function get_reporting_logs_intermediates_dir() {
    return get_reporting_step_analysis_dir() + "/" + "reporting_outputs";
}
exports.get_reporting_logs_intermediates_dir = get_reporting_logs_intermediates_dir;
function get_writable_input_dir() {
    return get_scratch_mount() + "/" + "analysis_workflow_outputs";
}
exports.get_writable_input_dir = get_writable_input_dir;
function get_results_dir() {
    return "results";
}
exports.get_results_dir = get_results_dir;
function get_dragen_license_key_folder() {
    /*
    Returns the analysis folder
    */
    return "license";
}
exports.get_dragen_license_key_folder = get_dragen_license_key_folder;
function get_dragen_license_instance_folder() {
    /*
    Not required since we're not actually demuxing anything
    */
    return "/opt/instance-identity";
}
exports.get_dragen_license_instance_folder = get_dragen_license_instance_folder;
function get_dragen_license_path() {
    /*
    Returns the file to the dragen license
    */
    return get_dragen_license_key_folder() + "/" + "dragen_license.txt";
}
exports.get_dragen_license_path = get_dragen_license_path;
function get_input_json_path() {
    return "input.json";
}
exports.get_input_json_path = get_input_json_path;
function get_run_cromwell_script_path() {
    return "run_cromwell.sh";
}
exports.get_run_cromwell_script_path = get_run_cromwell_script_path;
function get_demux_dsdm_json_path() {
    return get_demux_logs_intermediates_dir() + "/" + "FastqValidation" + "/" + "dsdm.json";
}
exports.get_demux_dsdm_json_path = get_demux_dsdm_json_path;
function get_analysis_dsdm_json_path() {
    return get_analysis_logs_intermediates_dir() + "/" + "Contamination" + "/" + "dsdm.json";
}
exports.get_analysis_dsdm_json_path = get_analysis_dsdm_json_path;
function get_reporting_dsdm_json_path() {
    return get_reporting_logs_intermediates_dir() + "/" + "Cleanup" + "/" + "dsdm.json";
}
exports.get_reporting_dsdm_json_path = get_reporting_dsdm_json_path;
function get_analysis_logs_intermediates_output_dir() {
    return get_output_dir() + "/" + "analysis_outputs";
}
exports.get_analysis_logs_intermediates_output_dir = get_analysis_logs_intermediates_output_dir;
function get_samplesheet_csv_path() {
    return get_demux_logs_intermediates_dir() + "/" + "SamplesheetValidation" + "/" + "SampleSheet_Intermediate.csv";
}
exports.get_samplesheet_csv_path = get_samplesheet_csv_path;
// Collect sample ids from tso
function get_sample_ids(tso500_samples) {
    /*
    Iterate through each item in the tso500_samples input and return the sample_id attribute
    */
    /*
    Initialise sample ids list
    */
    var sample_ids = [];
    /*
    Iterate through inputs
    */
    for (var i = 0; i < tso500_samples.length; i++) {
        sample_ids.push(tso500_samples[i].sample_id);
    }
    /*
    Return joined as comma separated values
    */
    return sample_ids.join(",");
}
exports.get_sample_ids = get_sample_ids;
// Mount logic
function get_dest_fastq_paths(sample_id, sample_number, input_fastq_list_rows) {
    /*
    Return a list of entry/entryname dicts to be mounted for a given sample
    */
    /*
    Initialise an array of dicts
    */
    var dest_fastq_paths = [];
    /*
    Iterate through each fastq list row
    Mount each read1 file with the following nomenclature

    Note key-values are squished together otherwise yaml has a hissy-fit
    */
    for (var i = 0; i < input_fastq_list_rows.length; i++) {
        /*
        Get the lane id
        */
        var lane = input_fastq_list_rows[i].lane;
        /*
        Set the basenames for each file
        */
        var read_1_base_name = sample_id + "_S" + String(sample_number) + "_L" + String(lane).padStart(3, '0') + "_R1_" + "001.fastq.gz";
        var read_2_base_name = sample_id + "_S" + String(sample_number) + "_L" + String(lane).padStart(3, '0') + "_R2_" + "001.fastq.gz";
        /*
        Set the mount points for each file
        */
        var read_1_dest_path = get_fastq_dir_path() + "/" + sample_id + "/" + read_1_base_name;
        var read_2_dest_path = get_fastq_dir_path() + "/" + sample_id + "/" + read_2_base_name;
        /*
        Extend list with read 1 and read 2 fastq file objects at the set mountpoints
        */
        dest_fastq_paths = dest_fastq_paths.concat([
            read_1_dest_path,
            read_2_dest_path
        ]);
    }
    /*
    Return the list of links for this sample
    */
    return dest_fastq_paths;
}
exports.get_dest_fastq_paths = get_dest_fastq_paths;
// Input Jsons
function get_demultiplex_workflow_input_json_content(resources_dir, samplesheet, samplesheet_prefix, tso500_samples) {
    /*
    Create a json file based on inputs and then stringify
    */
    return JSON.stringify({
        "DemultiplexWorkflow.runFolder": abs_path(get_run_dir_path()),
        "DemultiplexWorkflow.fastqFolder": abs_path(get_fastq_dir_path()),
        "DemultiplexWorkflow.analysisFolder": abs_path(get_demux_step_analysis_dir()),
        "DemultiplexWorkflow.logsIntermediatesFolder": abs_path(get_demux_logs_intermediates_dir()),
        "DemultiplexWorkflow.resourceFolder": resources_dir,
        "DemultiplexWorkflow.sampleSheet": samplesheet,
        "DemultiplexWorkflow.sampleIdentifiers": get_sample_ids(tso500_samples),
        "DemultiplexWorkflow.sampleSheetPrefix": samplesheet_prefix,
        "DemultiplexWorkflow.dragenLicenseKeyFolder": abs_path(get_demux_step_analysis_dir()),
        "DemultiplexWorkflow.dragenLicenseInstanceFolder": get_dragen_license_instance_folder()
    });
}
exports.get_demultiplex_workflow_input_json_content = get_demultiplex_workflow_input_json_content;
function get_analysis_workflow_input_json_content(resources_dir, tso500_samples, fastq_validation_dsdm_path) {
    /*
    Create a json file based on inputs and then stringify
    */
    return JSON.stringify({
        "AnalysisWorkflow.sampleIdentifiers": get_sample_ids(tso500_samples),
        "AnalysisWorkflow.fastqFolder": abs_path(get_fastq_dir_path()),
        "AnalysisWorkflow.dsdmFile": fastq_validation_dsdm_path,
        "AnalysisWorkflow.analysisFolder": get_analysis_step_analysis_dir(),
        "AnalysisWorkflow.logsIntermediatesFolder": get_analysis_logs_intermediates_dir(),
        "AnalysisWorkflow.resourceFolder": get_scratch_resources_dir(),
        "AnalysisWorkflow.dragenLicenseKeyFolder": abs_path(get_dragen_license_key_folder()),
        "AnalysisWorkflow.dragenLicenseInstanceFolder": get_dragen_license_instance_folder()
    });
}
exports.get_analysis_workflow_input_json_content = get_analysis_workflow_input_json_content;
function get_reporting_workflow_json_content(resources_dir, samplesheet_path, samplesheet_prefix, tso500_samples, contamination_dsdm_path) {
    /*
    Create a json file based on inputs and then stringify
    */
    return JSON.stringify({
        "ReportingWorkflow.dsdmFile": contamination_dsdm_path,
        "ReportingWorkflow.runFolder": abs_path(get_run_dir_path()),
        "ReportingWorkflow.analysisFolder": abs_path(get_reporting_step_analysis_dir()),
        "ReportingWorkflow.logsIntermediatesFolder": abs_path(get_reporting_logs_intermediates_dir()),
        "ReportingWorkflow.inputFolder": get_writable_input_dir(),
        "ReportingWorkflow.resourceFolder": resources_dir,
        "ReportingWorkflow.resultsFolder": abs_path(get_results_dir()),
        "ReportingWorkflow.startFromFastq": true,
        "ReportingWorkflow.sampleSheetPath": samplesheet_path,
        "ReportingWorkflow.sampleSheetPrefix": samplesheet_prefix
    });
}
exports.get_reporting_workflow_json_content = get_reporting_workflow_json_content;
function string_bash_array_contents(string_array) {
    /*
    String together elements inside a bash array
    */
    return string_array.join(" \\\n    ");
}
exports.string_bash_array_contents = string_bash_array_contents;
function get_array_of_fastq_paths(tso500_samples, is_dest) {
    /*
    Get the array of fastq paths, if is_dest is set to true then
    the destination path is returned instead
    */
    var fastq_paths = [];
    for (var i = 0; i < tso500_samples.length; i++) {
        /*
        Extend the listing for each sample present
        First we must get matching fastq list rows as inputs
        */
        var sample_id = tso500_samples[i].sample_id;
        var sample_name = tso500_samples[i].sample_name;
        var sample_number = i + 1;
        if (is_dest) {
            /*
            Now link according to the sample id
            */
            fastq_paths = fastq_paths.concat(get_dest_fastq_paths(sample_id, sample_number, tso500_samples[i].fastq_list_rows));
        }
        else {
            /*
            Just iterate over the fastq list rows and return the path attribute for each read pair.
            */
            for (var j = 0; j < tso500_samples[i].fastq_list_rows.length; i++) {
                var read_1_file = tso500_samples[i].fastq_list_rows[j].read_1;
                var read_2_file = tso500_samples[i].fastq_list_rows[j].read_2;
                fastq_paths.push(read_1_file.path);
                fastq_paths.push(read_2_file.path);
            }
        }
    }
    return fastq_paths;
}
exports.get_array_of_fastq_paths = get_array_of_fastq_paths;
// Mount logic
function get_fastq_src_paths_array(tso500_samples) {
    /*
    Get the array of src paths
    */
    return get_array_of_fastq_paths(tso500_samples, false);
}
exports.get_fastq_src_paths_array = get_fastq_src_paths_array;
function get_fastq_dest_paths_array(tso500_samples) {
    /*
    Get the array of src paths
    */
    return get_array_of_fastq_paths(tso500_samples, true);
}
exports.get_fastq_dest_paths_array = get_fastq_dest_paths_array;
function get_demultiplex_workflow_run_mounts(inputs) {
    return [
        /*
        Input json
        */
        {
            "entryname": get_input_json_path(),
            "entry": get_demultiplex_workflow_input_json_content(inputs.resources_dir.path, inputs.samplesheet.path, inputs.samplesheet_prefix, inputs.tso500_samples)
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
}
exports.get_demultiplex_workflow_run_mounts = get_demultiplex_workflow_run_mounts;
function get_analysis_workflow_run_mounts(inputs) {
    /*
    Initialise listing with input jsons and cromwell script and run folder files
    */
    var e = [
        /*
        Input json
        */
        {
            "entryname": get_input_json_path(),
            "entry": get_analysis_workflow_input_json_content(inputs.resources_dir.path, inputs.tso500_samples, inputs.fastq_validation_dsdm.path)
        }
    ];
    /*
    Check if dragen license is added
    */
    if (inputs.dragen_license_key !== null) {
        e.push({
            "entryname": get_dragen_license_path(),
            "entry": inputs.dragen_license_key
        });
    }
    /*
    Return entries
    */
    return e;
}
exports.get_analysis_workflow_run_mounts = get_analysis_workflow_run_mounts;
function get_reporting_workflow_run_mounts(inputs) {
    return [
        /*
        Input json
        */
        {
            "entryname": get_input_json_path(),
            "entry": get_reporting_workflow_json_content(inputs.resources_dir.path, inputs.samplesheet.path, inputs.samplesheet_prefix, inputs.tso500_samples, inputs.contamination_dsdm.path)
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
}
exports.get_reporting_workflow_run_mounts = get_reporting_workflow_run_mounts;
