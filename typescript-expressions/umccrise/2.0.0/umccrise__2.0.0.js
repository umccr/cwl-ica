"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_eval_umccrise_line = exports.get_run_script_entryname = exports.get_genomes_dir_path = exports.get_genomes_dir_name = exports.get_germline_input_dir = exports.get_somatic_input_dir = exports.get_scratch_input_dir = exports.get_scratch_working_dir = exports.get_scratch_working_parent_dir = exports.get_genomes_parent_dir = exports.get_name_root_from_tarball = exports.get_scratch_mount = exports.get_num_threads = void 0;
// Functions
function get_num_threads(input_threads, runtime_cores) {
    /*
    Use all cores unless 'threads' is set
    */
    if (input_threads !== null) {
        return input_threads;
    }
    else {
        return runtime_cores;
    }
}
exports.get_num_threads = get_num_threads;
function get_scratch_mount() {
    /*
    Get the scratch mount directory
    */
    return "/scratch";
}
exports.get_scratch_mount = get_scratch_mount;
function get_name_root_from_tarball(tar_file) {
    /*
    Get the name of the reference folder
    */
    var tar_ball_regex = /(\S+)\.tar\.gz/g;
    var tar_ball_expression = tar_ball_regex.exec(tar_file);
    if (tar_ball_expression === null) {
        throw new Error("Could not get nameroot from ".concat(tar_file));
    }
    return tar_ball_expression[1];
}
exports.get_name_root_from_tarball = get_name_root_from_tarball;
function get_genomes_parent_dir() {
    /*
    Get the genomes directory
    */
    return Array(get_scratch_mount(), "genome_dir").join("/");
}
exports.get_genomes_parent_dir = get_genomes_parent_dir;
function get_scratch_working_parent_dir() {
    /*
    Get the parent directory for the working directory
    By just on the off chance someone happens to stupidly set the output as 'genome'
    */
    return Array(get_scratch_mount(), "working_dir").join("/");
}
exports.get_scratch_working_parent_dir = get_scratch_working_parent_dir;
function get_scratch_working_dir(output_directory_name) {
    /*
    Get the scratch working directory
    */
    return Array(get_scratch_working_parent_dir(), output_directory_name).join("/");
}
exports.get_scratch_working_dir = get_scratch_working_dir;
function get_scratch_input_dir() {
    /*
    Get the inputs directory in /scratch space
    */
    return Array(get_scratch_mount(), "inputs").join("/");
}
exports.get_scratch_input_dir = get_scratch_input_dir;
function get_somatic_input_dir(dragen_somatic_directory_basename) {
    /*
    Get the inputs directory in /scratch space for the dragen somatic input
    */
    return Array(get_scratch_input_dir(), "somatic", dragen_somatic_directory_basename).join("/");
}
exports.get_somatic_input_dir = get_somatic_input_dir;
function get_germline_input_dir(dragen_germline_directory_basename) {
    /*
    Get the inputs directory in /scratch space for the dragen somatic input
    */
    return Array(get_scratch_input_dir(), "germline", dragen_germline_directory_basename).join("/");
}
exports.get_germline_input_dir = get_germline_input_dir;
function get_genomes_dir_name(genomes_tar_basename) {
    /*
    Return the stripped basename of the genomes tarball
    */
    return get_name_root_from_tarball(genomes_tar_basename);
}
exports.get_genomes_dir_name = get_genomes_dir_name;
function get_genomes_dir_path(genomes_tar_basename) {
    /*
    Get the genomes dir path
    */
    return Array(get_genomes_parent_dir(), get_genomes_dir_name(genomes_tar_basename)).join("/");
}
exports.get_genomes_dir_path = get_genomes_dir_path;
function get_run_script_entryname() {
    /*
    Get the run script entry name
    */
    return "scripts/run-umccrise.sh";
}
exports.get_run_script_entryname = get_run_script_entryname;
function get_eval_umccrise_line() {
    /*
    Get the line eval umccrise...
    */
    return "eval \"umccrise\" '\"\$@\"'\n";
}
exports.get_eval_umccrise_line = get_eval_umccrise_line;
