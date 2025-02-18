// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
import {
    File_class, Directory_class,
    FileProperties as IFile,
    DirectoryProperties as IDirectory,
    DirentProperties as IDirent,
} from "cwl-ts-auto"
import {FastqListRow} from "../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0"

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
export function get_script_path(): string {
    /*
    Abstract script path, can then be referenced in baseCommand attribute too
    Makes things more readable.
    */
    return "run-dragen-script.sh";
}

export function get_scratch_mount(): string {
    /*
    Return the path of the scratch directory space
    */
    return "/ephemeral/";
}

export function get_intermediate_results_dir(): string {
    /*
    Get intermediate results directory as /scratch for dragen runs
    */
    return get_scratch_mount() + "intermediate-results/";
}

export function get_name_root_from_tarball(basename: string): string {
    const tar_ball_regex = /(\S+)\.tar\.gz/g;
    const tar_ball_expression = tar_ball_regex.exec(basename);
    if (tar_ball_expression === null){
        throw new Error(`Could not get nameroot from ${basename}`)
    }
    return tar_ball_expression[1]
}

export function get_ref_path(reference_input_obj: IFile): string {
    /*
    Get the reference path
    */
    return get_ref_mount() + get_name_root_from_tarball(<string>reference_input_obj.basename) + "/";
}

export function get_ref_mount(): string {
    /*
    Get the reference mount point
    */
    return get_scratch_mount() + "ref/";
}

export function get_dragen_bin_path(): string {
    /*
    Get dragen bin path
    */
    return "/opt/edico/bin/dragen"
}

export function get_dragen_eval_line(): string {
    /*
    Return string
    */
    return "eval \"" + get_dragen_bin_path() + "\" '\"\$@\"' \n";
}

export function get_fastq_list_csv_path(): string {
    /*
    The fastq list path must be placed in working directory
    */
    return "fastq_list.csv"
}

export function get_tumor_fastq_list_csv_path(): string {
    /*
    The tumor fastq list path must be placed in working directory
    */
    return "tumor_fastq_list.csv"
}

export function get_ora_mv_files_script_path(): string {
    /*
    Get the ora mv files script path
    */
    return "mv-ora-output-files.sh"
}

export function get_new_fastq_list_csv_script_path(): string {
    /*
    Get the new fastq list csv script path
    */
    return "generate-new-fastq-list-csv.sh"
}
export function get_fastq_raw_md5sum_files_script_path(): string {
    /*
    Get the script path to generating the md5sum for each fastq gzip file
    */
    return "generate-md5sum-for-fastq-raw-files.sh"
}

export function get_fastq_gz_file_sizes_script_path(): string {
    /*
    Get the script path to generating the filesizes for each fastq gzip file
    */
    return "generate-file-sizes-for-fastq-gz-files.sh"
}

export function get_fastq_ora_md5sum_files_script_path(): string {
    /*
    Get the script path for generating the md5sum for each fastq ora file
    */
    return "generate-md5sum-for-fastq-ora-files.sh"
}

export function get_fastq_ora_file_sizes_script_path(): string {
    /*
    Get the script path to generating the filesizes for each fastq gzip file
    */
    return "generate-file-sizes-for-fastq-ora-files.sh"
}

export function get_normal_name_from_fastq_list_rows(fastq_list_rows: Array<FastqListRow> | null): string | null {
    /*
    Get the normal sample name from the fastq list rows object
    */

    /*
    Check fastq list rows is defined
    */
    if (fastq_list_rows === undefined || fastq_list_rows === null) {
        return null;
    }

    /*
    Get RGSM value and return
    */
    return fastq_list_rows[0].rgsm
}

export function get_normal_name_from_fastq_list_csv(fastq_list_csv: IFile | null): string | null {
    /*
    Get the normal name from the fastq list csv...
    */

    /*
    Check file is defined
    */
    if (fastq_list_csv === undefined || fastq_list_csv === null) {
        return null;
    }

    /*
    Check contents are defined
    */
    if (fastq_list_csv.contents === null || fastq_list_csv.contents === undefined) {
        return null;
    }

    /*
    Confirm fastq list csv is of type File
    */
    if (fastq_list_csv.class_ !== File_class.FILE){
        throw new Error("Could not confirm input fastq_list_csv is of type File")
    }

    /*
    Split contents by line
    */
    let contents_by_line: Array<string> = [];
    fastq_list_csv.contents.split("\n").forEach(
        function (line_content: string) {
            let stripped_line_content = line_content.replace(/(\r\n|\n|\r)/gm,"")
            if (stripped_line_content !== ""){
                contents_by_line.push(stripped_line_content)
            }
        }
    )

    let column_names = contents_by_line[0].split(",")

    /*
    Get RGSM index value (which column is RGSM at?)
    */
    let rgsm_index = column_names.indexOf("RGSM")

    /*
    RGSM is not in index. Return null
    */
    if (rgsm_index === -1) {
        return null;
    }

    /*
    Get RGSM value of first row and return
    */
    return contents_by_line[1].split(",")[rgsm_index]
}

export function get_normal_output_prefix(inputs: { fastq_list_rows: FastqListRow[] | null;  fastq_list: IFile | null; bam_input: IFile | null; cram_input: IFile | null }): string {
    /*
    Get the normal RGSM value and then add _normal to it
    */
    let normal_name: string | null = null
    let normal_re_replacement = /_normal$/

    /*
    Check if bam_input is set
    */
    if (inputs.bam_input !== null && inputs.bam_input !== undefined){
        /* Remove _normal from nameroot if it already exists */
        /* We dont want _normal_normal as a suffix */
        return <string>`${inputs.bam_input.nameroot?.replace(normal_re_replacement, "")}_normal`
    }

    /*
    Check if cram_input is set
    */
    if (inputs.cram_input !== null && inputs.cram_input !== undefined){
        /* Remove _normal from nameroot if it already exists */
        /* We dont want _normal_normal as a suffix */
        return <string>`${inputs.cram_input.nameroot?.replace(normal_re_replacement, "")}_normal`
    }

    /*
    Check if fastq list file is set
    */
    if (inputs.fastq_list !== null && inputs.fastq_list !== undefined) {
        normal_name = get_normal_name_from_fastq_list_csv(inputs.fastq_list)
        if ( normal_name !== null) {
            return `${normal_name}_normal`
        }
    }

    /*
    Otherwise collect and return from schema object
    */
    normal_name = get_normal_name_from_fastq_list_rows(inputs.fastq_list_rows)
    return <string>`${normal_name}_normal`
}

export function build_fastq_list_csv_header(header_names: Array<string>): string {
    /*
    Convert lowercase labels to uppercase values
    i.e
    [ "rgid", "rglb", "rgsm", "lane", "read_1", "read_2" ]
    to
    "RGID,RGLB,RGSM,Lane,Read1File,Read2File"
    */
    let modified_header_names: Array<string> = []

    for (let header_name of header_names) {
        if (header_name.indexOf("rg") === 0) {
            /*
            rgid -> RGID
            */
            modified_header_names.push(header_name.toUpperCase())
        } else if (header_name.indexOf("read") === 0) {
            /*
            read_1 -> Read1File
            */
            modified_header_names.push("Read" + header_name.charAt(header_name.length - 1) + "File")
        } else {
            /*
            lane to Lane
            */
            modified_header_names.push(header_name[0].toUpperCase() + header_name.substr(1))
        }
    }

    /*
    Convert array to comma separated strings
    */
    return modified_header_names.join(",") + "\n"
}

export function get_fastq_list_row_as_csv_row(fastq_list_row: FastqListRow, row_order: Array<string>): string {
    let fastq_list_row_values_array: Array<string> = []

    // This for loop is here to ensure were assigning values in the same order as the header
    for (let item_index of row_order) {
        let found_item = false
        // Find matching attribute in this row
        for (let fastq_list_row_field_name of Object.getOwnPropertyNames(fastq_list_row)) {
            let fastq_list_row_field_value = <string | IFile> fastq_list_row[fastq_list_row_field_name as keyof FastqListRow]

            if (fastq_list_row_field_value === null) {
                /*
                Item not found, add an empty attribute for this cell in the csv
                */
                continue
            }

            // The header value matches the name in the item
            if (fastq_list_row_field_name === item_index) {
                /*
                If the field value has a class attribute then it's either read_1 or read_2
                */
                if (fastq_list_row_field_value.hasOwnProperty("class_")){
                    let fastq_list_row_field_value_file = <IFile> fastq_list_row_field_value
                    /*
                    Assert that this is actually of class file
                    */
                    if ( fastq_list_row_field_value_file.class_ !== File_class.FILE ) {
                        continue
                    }

                    if (fastq_list_row_field_value_file.path !== null && fastq_list_row_field_value_file.path !== undefined){
                        /*
                        Push the path attribute to the fastq list csv row if it is not null
                        */
                        fastq_list_row_values_array.push(<string>fastq_list_row_field_value_file.path)
                    } else {
                        /*
                        Otherwise push the location attribute
                        */
                        fastq_list_row_values_array.push(<string>fastq_list_row_field_value_file.location)
                    }
                } else {
                    /*
                    Push the string attribute to the fastq list csv row
                    */
                    fastq_list_row_values_array.push(fastq_list_row_field_value.toString())
                }
                found_item = true
                break
            }
        }
        if (!found_item){
            /*
            Push blank cell if no item found
            */
            fastq_list_row_values_array.push("")
        }
    }

    /*
    Convert to string and return as string
    */
    return fastq_list_row_values_array.join(",") + "\n"
}

export function generate_fastq_list_csv(fastq_list_rows: FastqListRow[]): IFile {
    /*
    Fastq list rows generation
    */
    let fastq_csv_file: IFile = {
        class_: File_class.FILE,
        basename: get_fastq_list_csv_path()
    }

    /*
    Set the row order
    */
    let row_order: Array<string> = []

    /*
    Set the array order
    Make sure we iterate through all rows of the array
    */
    for (let fastq_list_row of fastq_list_rows) {
        for (let fastq_list_row_field_name of Object.getOwnPropertyNames(fastq_list_row)) {
            if (row_order.indexOf(fastq_list_row_field_name) === -1) {
                row_order.push(fastq_list_row_field_name)
            }
        }
    }

    /*
    Make header
    */
    fastq_csv_file.contents = build_fastq_list_csv_header(row_order)

    /*
    For each fastq list row,
    collect the values of each attribute but in the order of the header
    */
    for (let fastq_list_row of fastq_list_rows) {
        // Add csv row to file contents
        fastq_csv_file.contents += get_fastq_list_row_as_csv_row(fastq_list_row, row_order)
    }

    return fastq_csv_file
}

export function generate_germline_mount_points(inputs: {
    fastq_list_rows: FastqListRow[] | null;
    fastq_list: IFile | null;
}): Array<IDirent> {
    /*
    Create and add in the fastq list csv for the input fastqs
    */
    const e = [];

    if (inputs.fastq_list_rows !== null) {
        e.push({
            "entryname": get_fastq_list_csv_path(),
            "entry": generate_fastq_list_csv(inputs.fastq_list_rows)
        });
    }

    if (inputs.fastq_list !== null) {
        e.push({
            "entryname": get_fastq_list_csv_path(),
            "entry": inputs.fastq_list
        });
    }

    /*
    Return file paths
    */

    // @ts-ignore Type '{ entryname: string; entry: FileProperties; }[]' is not assignable to type 'DirentProperties[]'
    return e;
}

export function generate_somatic_mount_points(inputs: {
    fastq_list_rows: FastqListRow[] | null;
    tumor_fastq_list_rows: FastqListRow[] | null;
    fastq_list: IFile | null;
    tumor_fastq_list: IFile | null;
}): Array<IDirent> {
    /*
    Create and add in the fastq list csv for the input fastqs
    */
    const e = [];

    if (inputs.fastq_list_rows !== null) {
        e.push({
            "entryname": get_fastq_list_csv_path(),
            "entry": generate_fastq_list_csv(inputs.fastq_list_rows)
        });
    }

    if (inputs.tumor_fastq_list_rows !== null) {
        e.push({
            "entryname": get_tumor_fastq_list_csv_path(),
            "entry": generate_fastq_list_csv(inputs.tumor_fastq_list_rows)
        });
    }

    if (inputs.fastq_list !== null) {
        e.push({
            "entryname": get_fastq_list_csv_path(),
            "entry": inputs.fastq_list
        });
    }

    if (inputs.tumor_fastq_list !== null) {
        e.push({
            "entryname": get_tumor_fastq_list_csv_path(),
            "entry": inputs.tumor_fastq_list
        });
    }

    /*
    Return file paths
    */

    // @ts-ignore Type '{ entryname: string; entry: FileProperties; }[]' is not assignable to type 'DirentProperties[]'
    return e;
}

export function generate_transcriptome_mount_points(inputs: {
    fastq_list_rows: FastqListRow[] | null;
    fastq_list: IFile | null;
}): Array<IDirent> {
    /*
    Calls another function that generates mount points
    */
   return generate_germline_mount_points(inputs)

}

// Custom functions for dragen reference tarball build
export function get_liftover_dir() {
    // Hardcoded liftover directory in dragen 4.2
    return "/opt/edico/liftover/";
}
export function get_mask_dir() {
    // Hardcoded mask directory in dragen 4.2
    return "/opt/edico/fasta_mask/";
}

export function get_ref_scratch_dir(reference_name: string) {
    // We get the reference scratch directory as a combination of
    // the dragen scratch mount and the reference name
    return get_scratch_mount() + reference_name + "/";
}

export function get_ora_intermediate_output_dir() {
    return get_scratch_mount() + "ora-outputs/";
}

export function generate_ora_mv_files_script(fastq_list_rows: FastqListRow[], input_directory: IDirectory, output_directory: string): IFile {
    /*
    Generate the shell script with a list of echo commands to write a new fastq list csv to stdout, however
    the fastq list csv contains the ora files as outputs instead
    */
    let ora_mv_files_script = "#!/usr/bin/env bash\n\n"

    ora_mv_files_script += `# Exit on failure\n`
    ora_mv_files_script += `set -euo pipefail\n\n`

    ora_mv_files_script += `# Get fastq ora paths\n`
    ora_mv_files_script += `FASTQ_ORA_OUTPUT_PATHS=(\n`

    // Iterate over all files
    for (let fastq_list_row of fastq_list_rows) {
        // Confirm read 1 is a file type
        if ("class_" in fastq_list_row.read_1 && fastq_list_row.read_1.class_ === File_class.FILE) {
            // Add relative path of read 1
            ora_mv_files_script += `  "${fastq_list_row.read_1.path.replace(input_directory.path + "/", '').replace(".gz", ".ora")}" \\\n`
        }
        // Confirm read 2 is a file type
        if (fastq_list_row.read_2 !== null && "class_" in fastq_list_row.read_2 && fastq_list_row.read_2.class_ === File_class.FILE) {
            // Add relative path of read 2
            ora_mv_files_script += `  "${fastq_list_row.read_2.path.replace(input_directory.path + "/", '').replace(".gz", ".ora")}" \\\n`
        }
    }

    // Complete the bash array
    ora_mv_files_script += `)\n\n`

    ora_mv_files_script += `# Move all ora files to the final output directory\n`
    ora_mv_files_script += `xargs \\\n`
    ora_mv_files_script += `  --max-args=1 \\\n`
    ora_mv_files_script += `  --max-procs=16 \\\n`
    ora_mv_files_script += `  bash -c \\\n`
    ora_mv_files_script += `    '\n`
    ora_mv_files_script += `      fastq_ora_scratch_path="${get_ora_intermediate_output_dir()}\$(basename "\$@")"\n`
    ora_mv_files_script += `      mkdir -p "\$(dirname "${output_directory}/\$@")"\n`
    ora_mv_files_script += `      rsync \\\n`
    ora_mv_files_script += `        --archive \\\n`
    ora_mv_files_script += `        --remove-source-files \\\n`
    ora_mv_files_script += `        --include "\$(basename "\$@")" \\\n`
    ora_mv_files_script += `        --exclude "*" \\\n`
    ora_mv_files_script += `        "\$(dirname "\${fastq_ora_scratch_path}")/" \\\n`
    ora_mv_files_script += `        "\$(dirname "${output_directory}/\$@")/"\n`
    ora_mv_files_script += `    ' \\\n`
    ora_mv_files_script += `  _ \\\n`
    ora_mv_files_script += `  <<< "\${FASTQ_ORA_OUTPUT_PATHS[@]}"\n\n`
    ora_mv_files_script += `# Transfer all other files\n`
    ora_mv_files_script += `mkdir -p "${output_directory}/ora-logs/"\n`
    ora_mv_files_script += `mv "${get_ora_intermediate_output_dir()}" "${output_directory}/ora-logs/compression/"\n`

    return {
        class_: File_class.FILE,
        basename: get_ora_mv_files_script_path(),
        contents: ora_mv_files_script
    }
}

export function generate_new_fastq_list_csv_script(fastq_list_rows: FastqListRow[], input_directory: IDirectory): IFile {
    /*
    Generate the shell script with a list of mv commands to move the output files from the scratch space to their
    original location in the working directory
    */
    let new_fastq_list_csv_script = "#!/usr/bin/env bash\n\n"

    new_fastq_list_csv_script += `set -euo pipefail\n\n`
    new_fastq_list_csv_script += `# Generate a new fastq list csv script\n`

    new_fastq_list_csv_script += `# Initialise header\n`

    new_fastq_list_csv_script += `echo "RGID,RGLB,RGSM,Lane,Read1File,Read2File"\n`

    for (let fastq_list_row of fastq_list_rows){
        // Initialise echo line
        let echo_line = `echo \"${fastq_list_row.rgid},${fastq_list_row.rglb},${fastq_list_row.rgsm},${fastq_list_row.lane},`
        // Confirm read 1 is a file type
        if ("class_" in fastq_list_row.read_1 && fastq_list_row.read_1.class_ === File_class.FILE){
            echo_line += `${fastq_list_row.read_1.path.replace(input_directory.path + "/", '').replace(".gz", ".ora")},`
        } else {
          echo_line += ','
        }
        // Confirm read 2 is a file type
        if (fastq_list_row.read_2 !== null && "class_" in fastq_list_row.read_2 && fastq_list_row.read_2.class_ === File_class.FILE){
            echo_line += `${fastq_list_row.read_2.path.replace(input_directory.path + "/", '').replace(".gz", ".ora")}`
        }

        // Finish off echo line
        echo_line += `\"\n`

        new_fastq_list_csv_script += echo_line
    }

    return {
        class_: File_class.FILE,
        basename: get_new_fastq_list_csv_script_path(),
        contents: new_fastq_list_csv_script
    }

}

export function find_fastq_files_in_directory_recursively_with_regex(input_dir: IDirectory): ({read1obj: IFile, read2obj?: IFile})[] {
    /*
    Initialise the output file object
    */
    const read_1_file_list: IFile[] = []
    const read_2_file_list: IFile[] = []
    const output_file_objs: ({read1obj: IFile, read2obj?: IFile})[] = []

    const fastq_file_regex = /\.fastq\.gz$/
    const r1_fastq_file_regex = /_R1_001\.fastq\.gz$/
    const r2_fastq_file_regex = /_R2_001\.fastq\.gz$/

    /*
    Check input_dir is a directory and has a listing
    */
    if (input_dir.class_ === undefined || input_dir.class_ !== Directory_class.DIRECTORY){
        throw new Error("Could not confirm that the first argument was a directory")
    }
    if (input_dir.listing === undefined || input_dir.listing === null){
        throw new Error(`Could not collect listing from directory "${input_dir.basename}"`)
    }

    /*
    Collect listing as a variable
    */
    const input_listing: (IDirectory | IFile)[] = input_dir.listing

    /*
    Iterate through the file listing
    */
    for (const listing_item of input_listing) {
        if (listing_item.class_ === File_class.FILE && fastq_file_regex.test(<string>listing_item.basename)){
            /*
            Got the file of interest and the file basename matches the file regex
            */
            /*
            Check if the file is read 1 or read 2
            */
            if (r1_fastq_file_regex.test(<string>listing_item.basename)){
                read_1_file_list.push(<IFile>listing_item)
            }
            if (r2_fastq_file_regex.test(<string>listing_item.basename)){
                read_2_file_list.push(<IFile>listing_item)
            }
        }
        if (listing_item.class_ === Directory_class.DIRECTORY){
            const subdirectory_list = <IDirectory>listing_item
            try {
                // Consider that the file might not be in this subdirectory and that is okay
                output_file_objs.push(...find_fastq_files_in_directory_recursively_with_regex(subdirectory_list))
            } catch (error){
                // Dont need to report an error though, just continue
            }
        }
    }

    // Iterate over all the read 1 files and try to find a matching read 2 file
    for (const read_1_file of read_1_file_list){
        let read_2_file: IFile | undefined = undefined
        for (const read_2_file_candidate of read_2_file_list){
            if (read_1_file.basename?.replace("R1_001.fastq.gz", "R2_001.fastq.gz") === read_2_file_candidate.basename){
                read_2_file = read_2_file_candidate
                break
            }
        }
        output_file_objs.push({read1obj: read_1_file, read2obj: read_2_file})
    }

    // Return the output file object
    return output_file_objs
}

export function get_rgsm_value_from_fastq_file_name(fastq_file_name: string): string {
    // Get the RGID value from the fastq file name
    const rgid_regex = /(.+?)(?:_S\d+)?(?:_L00\d)?_R[12]_001\.fastq\.gz$/
    const rgid_expression = rgid_regex.exec(fastq_file_name)
    if (rgid_expression === null){
        throw new Error(`Could not get rgid from ${fastq_file_name}`)
    }
    return rgid_expression[1]
}

export function get_lane_value_from_fastq_file_name(fastq_file_name: string): number {
    // Get the lane value from the fastq file name
    const lane_regex = /(?:.+?)(?:_S\d+)?_L00(\d)_R[12]_001\.fastq\.gz$/
    const lane_expression = lane_regex.exec(fastq_file_name)
    if (lane_expression === null){
        return 1
    } else {
        console.log(lane_expression)
        return parseInt(lane_expression[1])
    }
}

export function generate_ora_mount_points(input_run: IDirectory, output_directory_path: string, sample_id_list?: string): Array<IDirent> {
    /*
    Three main parts

    1. Collect the fastq files
    2. For each fastq file pair, generate the rgid, rgsm, rglb and lane attributes as necessary to make a fastq list row
    3. Generate the fastq list csv file
    */

    // Collect the fastq files
    const fastq_files_pairs: ({read1obj: IFile, read2obj?: IFile})[] = find_fastq_files_in_directory_recursively_with_regex(input_run)

    // For each fastq file pair, generate the rgid, rgsm, rglb and lane attributes as necessary
    const fastq_list_rows: FastqListRow[] = []
    for (const fastq_files_pair of fastq_files_pairs){
        const rgsm_value = get_rgsm_value_from_fastq_file_name(<string>fastq_files_pair.read1obj.basename)
        // Skip fastq list pair if sample_id_list is defined and the rgsm_value is not in the list
        if (sample_id_list !== undefined && sample_id_list !== null && sample_id_list !== "" && sample_id_list.indexOf(rgsm_value) === -1){
            continue
        }
        // Remove undetermined files from the list of fastqs to process (they are often empty)
        if (rgsm_value === "Undetermined") {
            continue
        }
        // Check if we have the size attribute and if so check if it is greater than 0
        if (fastq_files_pair.read1obj.size !== null && fastq_files_pair.read1obj.size !== undefined && fastq_files_pair.read1obj.size == 0){
            continue
        }
        // Repeat the condition for read 2 although also ensure that read 2 is also actually defined
        if (fastq_files_pair.read2obj !== undefined && fastq_files_pair.read2obj !== null){
            if (fastq_files_pair.read2obj.size !== null && fastq_files_pair.read2obj.size !== undefined && fastq_files_pair.read2obj.size == 0){
                continue
            }
        }
        const lane_value = get_lane_value_from_fastq_file_name(<string>fastq_files_pair.read1obj.basename)
        const fastq_list_row: FastqListRow = {
            rgid: lane_value.toString() + '.' + rgsm_value,
            rgsm: rgsm_value,
            rglb: "UnknownLibrary",
            lane: lane_value,
            read_1: fastq_files_pair.read1obj,
            read_2: <IFile>fastq_files_pair.read2obj
        }
        fastq_list_rows.push(fastq_list_row)
    }

    // Initialise dirent
    const e = [];

    // Generate the fastq list csv file
    e.push({
        "entryname": get_fastq_list_csv_path(),
        "entry": generate_fastq_list_csv(fastq_list_rows)
    });

    // Generate the script to then move the files from the scratch space to the working directory
    e.push({
        "entryname": get_ora_mv_files_script_path(),
        "entry": generate_ora_mv_files_script(fastq_list_rows, input_run, output_directory_path)
    })

    // Generate the script to generate the new output fastq list csv
    e.push({
        "entryname": get_new_fastq_list_csv_script_path(),
        "entry": generate_new_fastq_list_csv_script(fastq_list_rows, input_run)
    })

    // Return the dirent
    // @ts-ignore Type '{ entryname: string; entry: FileProperties; }[]' is not assignable to type 'DirentProperties[]'
    return e;
}

export function get_contamination_dir(): string {
    /*
    Hardcoded contamination directory in dragen
    */
    return "/opt/edico/config/";
}