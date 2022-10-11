// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
import {File_class, FileProperties as IFile, PrimitiveType} from "cwl-ts-auto"
import {SamplesheetHeader} from "../../../schemas/samplesheet-header/2.0.0/samplesheet-header__2.0.0";
import {BclconvertDataRow} from "../../../schemas/bclconvert-data-row/4.0.3/bclconvert-data-row__4.0.3";
import {SamplesheetReads} from "../../../schemas/samplesheet-reads/2.0.0/samplesheet-reads__2.0.0";
import {BclconvertSettings} from "../../../schemas/bclconvert-settings/4.0.3/bclconvert-settings__4.0.3";
import {Samplesheet} from "../../../schemas/samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3";

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

/*
Create a BCLConvert file using Object Orientation
*/
export function key_name_to_camelcase(key_name: string, output_separator: string): string {
    /*
    Convert index_adapters to IndexAdapters etc
    */

    // Initialise variables
    let key_name_as_array: Array<string> = key_name.split("_")
    let key_name_as_camel_case_array: Array<string> = []

    // Known regex replacements
    const key_name_iem_regex = /^Iem$/
    const key_name_iem_replacement = "IEM"

    // For Sample ID
    const key_name_id_regex = /^Id$/
    const key_name_id_replacement = "ID"

    // For TrimUMI
    const umi_regex = /^Umi$/
    const umi_regex_replacement = "UMI"


    for (const word of key_name_as_array){
        let new_word = word.substring(0, 1).toUpperCase() + word.substring(1)
        // Replace strings
        new_word = new_word.replace(key_name_iem_regex, key_name_iem_replacement)
        new_word = new_word.replace(key_name_id_regex, key_name_id_replacement)
        new_word = new_word.replace(umi_regex, umi_regex_replacement)

        // Push new word to new word list
        key_name_as_camel_case_array.push(
            new_word
        )
    }

    return key_name_as_camel_case_array.join(output_separator)
}

export function convert_bool_to_string_int(setting_value: boolean | null): string | null {
    /*
    Convert boolean value to a number
    Settings such as CreateFastqForIndexReads require a number as a value
    */
    if (setting_value === undefined || setting_value === null){
        return null
    }

    if (setting_value){
        return "1"
    } else {
        return "0"
    }
}

export function create_nondata_samplesheet_section(section_name: string, section_object: SamplesheetHeader | SamplesheetReads | BclconvertSettings): string {
    /*
    Create key value pairs for a given section of the samplesheet
    */
    let section_contents = `[${section_name}]\n`
    let has_contents = false

    for (const samplesheet_section_key of Object.getOwnPropertyNames(section_object)){
        // create_fastq_for_index_reads to CraeteFastqForIndexReads
        const new_key_name = key_name_to_camelcase(samplesheet_section_key, "")
        type object_key = keyof typeof section_object;
        let object_value: any = section_object[samplesheet_section_key as object_key]

        // Check object value exists
        if (object_value === undefined || object_value === null){
            continue
        }
        has_contents = true

        // If object type is a boolean, convert to a "stringint"
        // For options CreateFastqForIndexReads and TrimUMI
        if (typeof object_value === "boolean" && ["CreateFastqForIndexReads", "TrimUMI"].indexOf(new_key_name) > -1){
            object_value = convert_bool_to_string_int(object_value)
        }

        // Otherwise add content to list
        section_contents += `${new_key_name},${object_value}\n`
    }

    // Extra line for good measure
    section_contents += "\n"

    if (has_contents){
        return section_contents
    } else {
        return ""
    }
}

export function build_bclconvert_data_header(header_names: Array<string>): string {
    /*
    Convert lowercase labels to uppercase values
    i.e
    [ "lane", "sample_id", "index", "index2", "sample_project", "override_cycles" ]
    to
    "Lane,Sample_ID,index,index2,Sample_Project,Override_Cycles"
    */
    let modified_header_names: Array<string> = []

    for (let header_name of header_names) {
        if (header_name.indexOf("index") === 0) {
            /*
            index -> index, index2 -> index2
            */
            modified_header_names.push(header_name)
        } else if (header_name == "override_cycles") {
            /*
            override_cycles -> OverrideCycles
            */
            modified_header_names.push(key_name_to_camelcase(header_name, ""))
        } else {
            /*
            lane -> Lane, sample_id -> Sample_ID,
            */
            modified_header_names.push(key_name_to_camelcase(header_name, "_"))
        }
    }

    /*
    Convert array to comma separated strings
    */
    return modified_header_names.join(",") + "\n"
}

export function get_bclconvert_data_row_as_csv_row(bclconvert_data_row: BclconvertDataRow, row_order: Array<string>): string {
    let bclconvert_data_values_array: Array<string> = []

    // This for loop is here to ensure were assigning values in the same order as the header
    for (let item_index of row_order) {
        let found: boolean = false
        // Find matching attribute in this row
        for (let bclconvert_data_field_name of Object.getOwnPropertyNames(bclconvert_data_row)) {

            // @ts-ignore - probably need to be doing something better than Object.getOwnPropertyNames here
            let bclconvert_data_row_field_value = <PrimitiveType | null> bclconvert_data_row[bclconvert_data_field_name]

            if (bclconvert_data_row_field_value === null) {
                /*
                Field value not found add an empty attribute for this cell in the csv
                */
                //
                continue
            }

            // The header value matches the name in the item
            if (bclconvert_data_field_name === item_index) {
                /*
                If the field value has a class attribute then it's either read_1 or read_2
                */
                bclconvert_data_values_array.push(bclconvert_data_row_field_value.toString())
                found = true
                break
            }
        }
        if (!found){
            bclconvert_data_values_array.push("")
        }
    }

    /*
    Convert to string and return as string
    */
    return bclconvert_data_values_array.join(",") + "\n"
}

export function create_samplesheet_bclconvert_data_section(samplesheet_bclconvert_data: Array<BclconvertDataRow>): string {
    /*
    Add in header
    */
    let bclconvert_data_contents = "[BCLConvert_Data]\n"

    /*
    Use similar logic to creating the fastq list row,
    Do not assume order or even attributes, just build based on the contents we have
    */
    /*
    Set the row order
    */
    let row_order: Array<string> = []

    /*
    Set the array order
    Make sure we iterate through all rows of the array
    */
    for (let bclconvert_data_row of samplesheet_bclconvert_data) {
        for (let bclconvert_data_field_name of Object.getOwnPropertyNames(bclconvert_data_row)) {
            let bclconvert_data_row_field_value = <PrimitiveType | null> bclconvert_data_row[bclconvert_data_field_name]
            if (bclconvert_data_row_field_value === null){
                continue
            }
            if (row_order.indexOf(bclconvert_data_field_name) === -1) {
                row_order.push(bclconvert_data_field_name)
            }
        }
    }

    /*
    Make header
    */
    bclconvert_data_contents += build_bclconvert_data_header(row_order)

    for (let bclconvert_data_row of samplesheet_bclconvert_data) {
        // Add csv row to file contents
        bclconvert_data_contents += get_bclconvert_data_row_as_csv_row(bclconvert_data_row, row_order)
    }

    /*
    For good measure
    */
    bclconvert_data_contents += "\n"

    return bclconvert_data_contents
}

export function create_samplesheet(samplesheet: Samplesheet): IFile {
    /*
    Build a samplesheet from scratch
    */

    /*
    Initialise the samplesheet object
    */
    const samplesheet_obj: IFile = {
        "class_": File_class.FILE,
        "basename": "SampleSheet.csv"
    }

    /*
    Create the header
    */
    samplesheet_obj.contents = create_nondata_samplesheet_section("Header", samplesheet.header)

    /*
    Create the reads section
    */
    samplesheet_obj.contents += create_nondata_samplesheet_section("Reads", samplesheet.reads)

    /*
    Create the BCLConvert settings section
    */

    samplesheet_obj.contents += create_nondata_samplesheet_section("BCLConvert_Settings", samplesheet.bclconvert_settings)

    /*
    Create the BCLConvert data section
    */
    samplesheet_obj.contents += create_samplesheet_bclconvert_data_section(samplesheet.bclconvert_data)


    return samplesheet_obj
}

