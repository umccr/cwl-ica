// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports

import {FastqListRow} from "../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0";
import {Tso500Sample} from "../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0";
import {FileProperties} from "cwl-ts-auto";

// Backward compatibility with --target es5
declare global {
    interface Set<T> {
    }

    interface Map<K, V> {
    }

    interface WeakSet<T> {
    }

    interface WeakMap<K extends object, V> {
    }
}

// Functions

// Get path functions
export function abs_path(rel_path: string): string {
    /*
    Return the absolute path of a relative path
    */
    // Ignore runtime not existing
    // @ts-ignore
    return runtime.outdir + "/" + rel_path;
}

export function get_cromwell_path(): string {
    /*
    Return the hard-coded cromwell path in the directory
    */
    return "/opt/cromwell/cromwell.jar";
}

export function get_demux_wdl_path(): string {
    /*
    Get the demux workflow wdl path
    */
    return "/opt/illumina/wdl/DemultiplexWorkflow.wdl";
}

export function get_analysis_wdl_path(): string {
    return "/opt/illumina/wdl/AnalysisWorkflow.wdl";
}

export function get_reporting_wdl_path(): string {
    return "/opt/illumina/wdl/ReportingWorkflow.wdl";
}

export function get_scratch_mount() {
    return "/scratch";
}

export function get_scratch_resources_dir() {
    return get_scratch_mount() + "/" + "resources";
}

export function get_run_dir_path(): string {
    return "run";
}

export function get_fastq_dir_path(): string {
    return "fastqs";
}


export function get_demux_step_analysis_dir(): string {
    return "demux_workflow";
}

export function get_analysis_step_analysis_dir(): string {
    return get_scratch_mount() + "/" + "analysis_workflow";
}

export function get_reporting_step_analysis_dir(): string {
    return "reporting_workflow";
}

export function get_output_dir(): string {
    // @ts-ignore
    return inputs.output_dirname;
}


export function get_demux_logs_intermediates_dir(): string {
    return get_demux_step_analysis_dir() + "/" + "demux_outputs";
}

export function get_analysis_logs_intermediates_dir(): string {
    return get_analysis_step_analysis_dir() + "/" + "analysis_outputs"
}

export function get_reporting_logs_intermediates_dir(): string {
    return get_reporting_step_analysis_dir() + "/" + "reporting_outputs";
}

export function get_writable_input_dir(): string {
    return get_scratch_mount() + "/" + "analysis_workflow_outputs";
}

export function get_results_dir() {
    return "results";
}


export function get_dragen_license_key_folder(): string {
    /*
    Returns the analysis folder
    */
    return "license";
}

export function get_dragen_license_instance_folder(): string {
    /*
    Not required since we're not actually demuxing anything
    */
    return "/opt/instance-identity";
}

export function get_dragen_license_path(): string {
    /*
    Returns the file to the dragen license
    */
    return get_dragen_license_key_folder() + "/" + "dragen_license.txt";
}

export function get_input_json_path(): string {
    return "input.json";
}

export function get_run_cromwell_script_path(): string {
    return "run_cromwell.sh";
}

export function get_demux_dsdm_json_path(): string {
    return get_demux_logs_intermediates_dir() + "/" + "FastqValidation" + "/" + "dsdm.json";
}

export function get_analysis_dsdm_json_path(): string {
    return get_analysis_logs_intermediates_output_dir() + "/" + "Contamination" + "/" + "dsdm.json";
}

export function get_reporting_dsdm_json_path(): string {
    return get_reporting_logs_intermediates_dir() + "/" + "Cleanup" + "/" + "dsdm.json";
}

export function get_analysis_logs_intermediates_output_dir(): string {
    return get_output_dir() + "/" + "analysis_outputs"
}

export function get_samplesheet_csv_path() {
    return get_demux_logs_intermediates_dir() + "/" + "SamplesheetValidation" + "/" + "SampleSheet_Intermediate.csv";
}

// Collect sample ids from tso
export function get_sample_ids(tso500_samples: Array<Tso500Sample>) {
    /*
    Iterate through each item in the tso500_samples input and return the sample_id attribute
    */

    /*
    Initialise sample ids list
    */
    let sample_ids = []

    /*
    Iterate through inputs
    */
    for (let i = 0; i < tso500_samples.length; i++) {
        sample_ids.push(tso500_samples[i].sample_id);
    }

    /*
    Return joined as comma separated values
    */
    return sample_ids.join(",");
}

// Mount logic
export function get_dest_fastq_paths(sample_id: string, sample_number: number, input_fastq_list_rows: Array<FastqListRow>) {
    /*
    Return a list of entry/entryname dicts to be mounted for a given sample
    */

    /*
    Initialise an array of dicts
    */
    let dest_fastq_paths: Array<string> = [];

    /*
    Iterate through each fastq list row
    Mount each read1 file with the following nomenclature

    Note key-values are squished together otherwise yaml has a hissy-fit
    */

    for (let i = 0; i < input_fastq_list_rows.length; i++) {
        /*
        Get the lane id
        */
        let lane = input_fastq_list_rows[i].lane;

        /*
        Set the basenames for each file
        */
        let read_1_base_name = sample_id + "_S" + String(sample_number) + "_L" + String(lane).padStart(3, '0') + "_R1_" + "001.fastq.gz";
        let read_2_base_name = sample_id + "_S" + String(sample_number) + "_L" + String(lane).padStart(3, '0') + "_R2_" + "001.fastq.gz";

        /*
        Set the mount points for each file
        */
        let read_1_dest_path = get_fastq_dir_path() + "/" + sample_id + "/" + read_1_base_name;
        let read_2_dest_path = get_fastq_dir_path() + "/" + sample_id + "/" + read_2_base_name;

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

// Input Jsons
export function get_demultiplex_workflow_input_json_content(resources_dir: string, samplesheet: string, samplesheet_prefix: string, tso500_samples: Array<Tso500Sample>) {
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

export function get_analysis_workflow_input_json_content(resources_dir: string, tso500_samples: Array<Tso500Sample>, fastq_validation_dsdm_path: string, ){
    /*
    Create a json file based on inputs and then stringify
    */
    return JSON.stringify({
        "AnalysisWorkflow.sampleIdentifiers":get_sample_ids(tso500_samples),
        "AnalysisWorkflow.fastqFolder":abs_path(get_fastq_dir_path()),
        "AnalysisWorkflow.dsdmFile":fastq_validation_dsdm_path,
        "AnalysisWorkflow.analysisFolder":get_analysis_step_analysis_dir(),
        "AnalysisWorkflow.logsIntermediatesFolder":get_analysis_logs_intermediates_dir(),
        "AnalysisWorkflow.resourceFolder":get_scratch_resources_dir(),
        "AnalysisWorkflow.dragenLicenseKeyFolder":abs_path(get_dragen_license_key_folder()),
        "AnalysisWorkflow.dragenLicenseInstanceFolder":get_dragen_license_instance_folder()
    });
}


export function get_reporting_workflow_json_content(resources_dir: string, samplesheet_path: string, samplesheet_prefix: string, tso500_samples: Array<Tso500Sample>, contamination_dsdm_path: string){
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


export function string_bash_array_contents(string_array: Array<string>) {
    /*
    String together elements inside a bash array
    */
    return string_array.join(" \\\n    ");
}

export function get_array_of_fastq_paths(tso500_samples: Array<Tso500Sample>, is_dest: boolean) {
    /*
    Get the array of fastq paths, if is_dest is set to true then
    the destination path is returned instead
    */

    let fastq_paths: Array<string> = [];

    for (let i = 0; i < tso500_samples.length; i++) {
        /*
        Extend the listing for each sample present
        First we must get matching fastq list rows as inputs
        */
        let sample_id = tso500_samples[i].sample_id;
        let sample_name = tso500_samples[i].sample_name;
        let sample_number = i + 1;

        if (is_dest) {
            /*
            Now link according to the sample id
            */
            fastq_paths = fastq_paths.concat(
                get_dest_fastq_paths(sample_id, sample_number, tso500_samples[i].fastq_list_rows)
            );
        } else {
            /*
            Just iterate over the fastq list rows and return the path attribute for each read pair.
            */
            for (let j = 0; j < tso500_samples[i].fastq_list_rows.length; j++) {
                let read_1_file = <FileProperties>tso500_samples[i].fastq_list_rows[j].read_1
                let read_2_file = <FileProperties>tso500_samples[i].fastq_list_rows[j].read_2
                fastq_paths.push(<string>read_1_file.path);
                fastq_paths.push(<string>read_2_file.path);
            }
        }
    }

    return fastq_paths;
}

// Mount logic
export function get_fastq_src_paths_array(tso500_samples: Array<Tso500Sample>) {
    /*
    Get the array of src paths
    */
    return get_array_of_fastq_paths(tso500_samples, false);
}


export function get_fastq_dest_paths_array(tso500_samples: Array<Tso500Sample>) {
    /*
    Get the array of src paths
    */
    return get_array_of_fastq_paths(tso500_samples, true);
}


export function get_demultiplex_workflow_run_mounts(inputs: any): Array<Object> {
    return [
            /*
            Input json
            */
            {
             "entryname": get_input_json_path(),
             "entry": get_demultiplex_workflow_input_json_content(
                 <string>inputs.resources_dir.path,
                 <string>inputs.samplesheet.path,
                 <string>inputs.samplesheet_prefix,
                 <Array<Tso500Sample>>inputs.tso500_samples
             )
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

export function get_analysis_workflow_run_mounts(inputs: any): Array<Object> {
    /*
    Initialise listing with input jsons and cromwell script and run folder files
    */
    let e = [
              /*
              Input json
              */
              {
               "entryname": get_input_json_path(),
               "entry": get_analysis_workflow_input_json_content(
                   <string>inputs.resources_dir.path,
                   <Array<Tso500Sample>>inputs.tso500_samples,
                   <string>inputs.fastq_validation_dsdm.path
               )
              }
            ];

    /*
    Check if dragen license is added
    */
    if ( inputs.dragen_license_key !== null ){
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


export function get_reporting_workflow_run_mounts(inputs: any): Array<Object> {
    return [
            /*
            Input json
            */
            {
             "entryname": get_input_json_path(),
             "entry": get_reporting_workflow_json_content(
                 <string>inputs.resources_dir.path,
                 <string>inputs.samplesheet.path,
                 <string>inputs.samplesheet_prefix,
                 <Array<Tso500Sample>>inputs.tso500_samples,
                 <string>inputs.contamination_dsdm.path
             )
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