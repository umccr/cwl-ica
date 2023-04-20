// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports

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
export function get_num_threads(input_threads: number | null, runtime_cores: number): number {
    /*
    Use all cores unless 'threads' is set
    */
    if (input_threads !== null){
        return input_threads;
    } else {
        return runtime_cores;
    }
}

export function get_scratch_mount() {
    /*
    Get the scratch mount directory
    */
    return "/scratch";
}


export function get_name_root_from_tarball(tar_file: string): string {
    /*
    Get the name of the reference folder
    */
    const tar_ball_regex = /(\S+)\.tar\.gz/g;
    const tar_ball_expression = tar_ball_regex.exec(tar_file);
    if (tar_ball_expression === null){
        throw new Error(`Could not get nameroot from ${tar_file}`)
    }
    return tar_ball_expression[1]
}


export function get_genomes_parent_dir(): string{
    /*
    Get the genomes directory
    */
    return Array(get_scratch_mount(), "genome_dir").join("/");
}

export function get_scratch_working_parent_dir(){
    /*
    Get the parent directory for the working directory
    By just on the off chance someone happens to stupidly set the output as 'genome'
    */
    return Array(get_scratch_mount(), "working_dir").join("/");
}


export function get_scratch_working_dir(output_directory_name: string): string{
    /*
    Get the scratch working directory
    */
    return Array(get_scratch_working_parent_dir(), output_directory_name).join("/");
}


export function get_scratch_input_dir(){
    /*
    Get the inputs directory in /scratch space
    */
    return Array(get_scratch_mount(), "inputs").join("/");
}

export function get_somatic_input_dir(dragen_somatic_directory_basename: string): string{
    /*
    Get the inputs directory in /scratch space for the dragen somatic input
    */
    return Array(get_scratch_input_dir(), "somatic", dragen_somatic_directory_basename).join("/");
}

export function get_germline_input_dir(dragen_germline_directory_basename: string): string{
    /*
    Get the inputs directory in /scratch space for the dragen somatic input
    */
    return Array(get_scratch_input_dir(), "germline", dragen_germline_directory_basename).join("/");
}

export function get_genomes_dir_name(genomes_tar_basename: string): string {
    /*
    Return the stripped basename of the genomes tarball
    */
    return get_name_root_from_tarball(genomes_tar_basename);
}


export function get_genomes_dir_path(genomes_tar_basename: string): string{
    /*
    Get the genomes dir path
    */
    return Array(get_genomes_parent_dir(), get_genomes_dir_name(genomes_tar_basename)).join("/");
}

export function get_run_script_entryname(){
    /*
    Get the run script entry name
    */
    return "scripts/run-umccrise.sh";
}

export function get_eval_umccrise_line(){
    /*
    Get the line eval umccrise...
    */
    return "eval \"umccrise\" '\"\$@\"'\n"
}