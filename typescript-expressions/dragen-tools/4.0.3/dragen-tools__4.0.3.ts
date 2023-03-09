// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
import {
    File_class,
    FileProperties as IFile,
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

export function get_normal_output_prefix(inputs: { fastq_list_rows: FastqListRow[] | null;  fastq_list: IFile | null; bam_input: IFile | null }): string {
    /*
    Get the normal RGSM value and then add _normal to it
    */
    let normal_name: string | null = null

    /*
    Check if bam_input is set
    */
    if (inputs.bam_input !== null && inputs.bam_input !== undefined){
        return <string>`${inputs.bam_input.nameroot}_normal`
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