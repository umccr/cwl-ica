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
import {DragenQcCoverage} from "../../../schemas/dragen-qc-coverage/1.0.0/dragen-qc-coverage__1.0.0";
import {
    DragenWgtsOptionsAlignmentStage
} from "../../../schemas/dragen-wgts-options-alignment-stage/4.4.4/dragen-wgts-options-alignment-stage__4.4.4";
import {
    DragenWgtsDnaOptionsVariantCallingStage
} from "../../../schemas/dragen-wgts-dna-options-variant-calling-stage/4.4.4/dragen-wgts-dna-options-variant-calling-stage__4.4.4";
import {
    DragenWgtsDnaAlignmentStageOptionsFromPipelineProps,
    DragenWgtsDnaVariantCallingStageOptionsFromPipelineProps, DragenWgtsRnaAlignmentStageOptionsFromPipelineProps,
    DragenWgtsRnaVariantCallingStageOptionsFromPipelineProps,
    MultiQcNamingOptionsProps
} from "./dragen-tools_function_interfaces";
import {DragenInputAlignmentType, DragenInputSequenceType} from "./dragen-tools_custom_input_interfaces";
import {DragenReference} from "../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0";
import {
    DragenWgtsRnaOptionsVariantCallingStage
} from "../../../schemas/dragen-wgts-rna-options-variant-calling-stage/4.4.4/dragen-wgts-rna-options-variant-calling-stage__4.4.4";


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

// Globals
/*
List of options that are booleans but where the values are expressed as a number
*/
const DragenNumericBooleanType = [
    "global",
    "all"
]

const DEFAULT_LIC_INSTANCE_ID_LOCATION_PATH = '/opt/instance-identity'

// Functions
export function get_scratch_mount(): string {
    /*
    Return the path of the scratch directory space
    */
    return "/scratch/";
}

export function get_intermediate_results_dir(): string {
    /*
    Get intermediate results directory as /scratch for dragen runs
    */
    return get_scratch_mount() + "intermediate-results/";
}


export function get_name_root_from_tarball(basename: string): string {
    const tar_ball_regex = /(\S+)\.tar(?:\.gz)?/g;
    const tar_ball_expression = tar_ball_regex.exec(basename);
    if (tar_ball_expression === null) {
        throw new Error(`Could not get nameroot from ${basename}`)
    }
    return tar_ball_expression[1]
}

export function get_ref_path(reference_input_obj: IFile): string {
    /*
    Get the reference path
    */
    return get_ref_mount() + get_name_root_from_tarball(<string>reference_input_obj.basename);
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

export function get_fastq_list_csv_path(): string {
    /*
    The fastq list path must be placed in working directory
    */
    return "fastq_list.csv"
}

export function capitalizeFirstLetter(str: string): string {
    return str.charAt(0).toUpperCase() + str.slice(1);
}


export function json_to_toml(json_data: Object): string {
    // Convert JSON to TOML format
    // Much easier than the other way around

    // Initialize an empty string to store the TOML data
    let toml_data = '';

    let global_keys_list: string[] = []

    // Iterate through each key in the JSON object to first find the 'global' keys
    for (const key in json_data) {
        const value = (json_data as Record<string, any>)[key]
        if (value === null) {
            continue
        }
        // If the value is a file, return the path
        if (typeof value === 'object' && !Array.isArray(value)) {
            continue
        }
        global_keys_list.push(key)
    }

    // Add global keys to the TOML data first
    for (const key of global_keys_list) {
        const value = (json_data as Record<string, any>)[key]
        if (value === null) {
            continue
        }
        // If the value is an array, we need to make an entry for each item in the array
        else if ( Array.isArray(value)) {
            value.forEach((item) => {
                toml_data += `${key} = ${item}\n`;
            });
        } else {
            // Regular append
            toml_data += `${key} = ${value}\n`;
        }
    }

    // Iterate through each key in the JSON object
    for (const key in json_data) {
        const value = (json_data as Record<string, any>)[key]

        // Skip global keys
        if (global_keys_list.indexOf(key) !== -1) {
            continue
        }

        if (value === null) {
            continue
        }
        // If the value is a file, return the path
        if (typeof value === 'object' && value.hasOwnProperty("class_") && value["class_"] === File_class.FILE) {
            toml_data += `${key} = ${(<IFile>value).path}\n`;
            continue
        }

        // If the value is a directory, return the path
        if (typeof value === 'object' && value.hasOwnProperty("class_") && value["class_"] === Directory_class.DIRECTORY) {
            toml_data += `${key} = ${(<IDirectory>value).path}\n`;
            continue
        }

        // If the value is an object, treat it as a section
        if (typeof value === 'object' && !Array.isArray(value)) {
            // Section header should have a capitalized first letter
            toml_data += `[${capitalizeFirstLetter(key)}]\n`;
            for (const sub_key in value) {
                toml_data += `${sub_key} = ${value[sub_key]}\n`;
            }
        }
        // If the value is a string, treat it as a key-value pair
        else {
            // Otherwise, treat it as a key-value pair
            toml_data += `${key} = ${value}\n`;
        }
    }

    // Return the TOML data
    return toml_data;
}


/* Convert TOML to JSON format */
export function toml_to_json(toml_str: string): Record<string, any> {
    /*
    Convert TOML to JSON format.
    This implementation uses a simple TOML parser for basic key-value pairs and sections.
    For production use, consider using a library like `@iarna/toml` or `toml`.
    */
    const result: Record<string, any> = {};
    let currentSection: string | null = null;
    const lines = toml_str.split(/\r?\n/);

    for (let line of lines) {
        line = line.trim();
        if (!line || line.startsWith("#")) continue;

        // Section header
        const sectionMatch = line.match(/^\[(.+)\]$/);
        if (sectionMatch) {
            // Make section lowercase
            currentSection = sectionMatch[1].toLowerCase().trim();
            if (!result[currentSection]) {
                result[currentSection] = {};
            }
            continue;
        }

        // Key-value pair
        const kvMatch = line.match(/^([^=]+)=(.*)$/);
        if (kvMatch) {
            let key = kvMatch[1].trim();
            let value: any = kvMatch[2].trim();

            // Check if value is empty
            if ((value === "")) {
                value = null
            }
            // Remove quotes if present
            else if (
                (value.startsWith('"') && value.endsWith('"')) ||
                (value.startsWith("'") && value.endsWith("'"))
            ) {
                value = value.slice(1, -1);
            } else if (value === "true" || value === "false") {
                value = value === "true";
            } else if (!isNaN(Number(value))) {
                value = Number(value);
            }

            /* Set the key name by replacing hyphens with underscores */
            key = key.replace(/-/g, '_');

            /* Replace hyphens with underscores in the key */
            if (currentSection) {
                /* Check if the key exists in the current section */
                if (result[currentSection].hasOwnProperty(key)) {
                    /* Check if the existing value is an array */
                    if (Array.isArray(result[currentSection][key])) {
                        /* Push the entry */
                        result[currentSection][key].push(value);
                    } else {
                        /* If the key exists but is not an array, convert it to an array */
                        if (result[currentSection][key] !== undefined) {
                            result[currentSection][key] = [result[currentSection][key], value];
                        } else {
                            result[currentSection][key] = value;
                        }
                    }
                } else {
                    result[currentSection][key] = value;
                }
            } else {
                /* Check if the key exists */
                if (result.hasOwnProperty(key)) {
                    /* Check if the existing value is an array */
                    if (Array.isArray(result[key])) {
                        /* Push the entry */
                        result[key].push(value);
                    } else {
                        /* If the key exists but is not an array, convert it to an array */
                        if (result[key] !== undefined) {
                            result[key] = [result[key], value];
                        } else {
                            result[key] = value;
                        }
                    }
                } else {
                    result[key] = value
                }
            }
        }
    }
    return result;
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
            let fastq_list_row_field_value = <string | IFile>fastq_list_row[fastq_list_row_field_name as keyof FastqListRow]

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
                if (fastq_list_row_field_value.hasOwnProperty("class_")) {
                    let fastq_list_row_field_value_file = <IFile>fastq_list_row_field_value
                    /*
                    Assert that this is actually of class file
                    */
                    if (fastq_list_row_field_value_file.class_ !== File_class.FILE) {
                        continue
                    }

                    if (fastq_list_row_field_value_file.path !== null && fastq_list_row_field_value_file.path !== undefined) {
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
                    Replace any commas in the string with ' -'
                    */
                    fastq_list_row_values_array.push(fastq_list_row_field_value.toString().replace(/,/g, " -"))
                }
                found_item = true
                break
            }
        }
        if (!found_item) {
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


export function get_value_for_config(
    valueObj: any
): any {
    /* If valueObj is an IFile, return its path */
    if (valueObj.hasOwnProperty("class_") && valueObj["class_"] === File_class.FILE) {
        return (<IFile>valueObj).path
    }

    /* If valueObj is an IDirectory, return its path */
    if (valueObj.hasOwnProperty("class_") && valueObj["class_"] === Directory_class.DIRECTORY) {
        return (<IDirectory>valueObj).path
    }

    /* Recursively call this function for nested objects */
    if (typeof valueObj === 'object' && !Array.isArray(valueObj)) {
        const newValueObj: Record<string, any> = {}
        for (const key in valueObj) {
            if (valueObj[key] === null || valueObj[key] === undefined) {
                continue
            }
            /* Special case - boolean to numeric */
            if (key in DragenNumericBooleanType) {
                newValueObj[key.replace(/_/g, "-")] = valueObj[key] ? 1 : 0
                continue
            }
            newValueObj[key.replace(/_/g, "-")] = get_value_for_config(valueObj[key])
        }
        return newValueObj
    }

    /* Consider arrays */
    if (Array.isArray(valueObj)) {
        return valueObj.map(item => get_value_for_config(item))
    }

    /* Otherwise return the value as is */
    return valueObj

}

export function get_dragen_config_path() {
    return "dragen_config.toml"
}

export function dragen_to_config_toml(
    props: Record<string, any>,
): string {
    /* Part 1 - Generate the json blob */
    const json_blob: Record<string, any> = {}

    for (const key in props) {
        /* Get props key value */
        const value = (props as Record<string, any>)[key];

        /* Skip null props */
        if (value === null || value === undefined) {
            continue
        }

        // FIXME denovo to DeNovo

        /* Special cases */
        /* 1. Fastq list rows we rename to 'fastq-list',
            alignment data mounted at the base of the working directory
        */
        /* Sequence data */
        if (key === "fastq_list_rows") {
            json_blob["fastq-list"] = get_fastq_list_csv_path()
            continue
        }
        /* Alignment data */
        if (key === "bam_input") {
            json_blob["bam-input"] = value.basename
            continue
        }
        if (key === "cram_input") {
            json_blob["cram-input"] = value.basename
            continue
        }
        if (key === "cram_reference") {
            json_blob["cram-reference"] = value.basename
            continue
        }
        /* Tumor alignment data */
        if (key === "tumor_bam_input") {
            json_blob["tumor-bam-input"] = value.basename
            continue
        }
        if (key === "tumor_cram_input") {
            json_blob["tumor-cram-input"] = value.basename
            continue
        }
        if (key === "tumor_cram_reference") {
            json_blob["tumor-cram-reference"] = value.basename
            continue
        }

        /* 2. If ref-tar is parsed through, we use ref-dir instead */
        if (key === "ref_tar") {
            json_blob['ref-dir'] = get_ref_mount() + value.basename.replace(/\.tar\.gz$/, "")
            /*
                If the ref_tar does not contain 'graph',
                then we also need to add the parameter,
                --validate-pangenome-reference=false
            */
            if (!value.basename.includes("graph")) {
                json_blob['validate-pangenome-reference'] = false
            }
            continue
        }
        if (key === "ora_reference") {
            /* Mounted at ref mount, strip the .tar.gz from the basename */
            json_blob['ora-reference'] = get_ref_mount() + value.basename.replace(/\.tar\.gz$/, "")
            continue
        }

        /* 3. Check if key is in the boolean to numeric list */
        if (key in DragenNumericBooleanType) {
            json_blob[key.replace(/_/g, "-")] = value ? 1 : 0
            continue
        }

        /* 4. Check if key is a qc coverage object */
        if (key === "qc_coverage") {
            /*
            We need to iterate through the qc coverage objects
            and add them to the json blob
            */
            value.forEach((qcObject: DragenQcCoverage, index: number) => {
                json_blob[`qc-coverage-region-${index + 1}`] = qcObject.region.path;
                json_blob[`qc-coverage-reports-${index + 1}`] = qcObject.report_type;
                if (qcObject.thresholds !== null && qcObject.thresholds !== undefined) {
                    json_blob[`qc-coverage-region-${index + 1}-thresholds`] = qcObject.thresholds.map(
                        (threshold: number) => threshold.toString()
                    ).join(",");
                }
            });
            continue
        }

        /* 5. Get value for standard options */
        if (props.hasOwnProperty(key)) {
            // We replace snake case with hyphen
            json_blob[key.replace(/_/g, "-")] = get_value_for_config(value);
        }
    }

    /* Part 2 - Convert the json blob to toml */
    return json_to_toml(json_blob)
}

export function generate_sequence_data_mount_points(
    sequence_data: DragenInputSequenceType
): Array<IDirent> {
    /*
    Create and add in the fastq list csv for the input fastqs
    If the input is bam or cram, we also mount as it 'un-cwlifies' the command line,
    as this is often attached to the bottom of the PG line in a bam file,
    we'd like to make that as short as possible
    */
    const e = [];

    // Add the sequence data
    if ("fastq_list_rows" in sequence_data && sequence_data.fastq_list_rows !== undefined) {
        e.push({
            "entryname": get_fastq_list_csv_path(),
            "entry": generate_fastq_list_csv(sequence_data.fastq_list_rows)
        });
    } else if ("bam_input" in sequence_data && sequence_data.bam_input !== undefined) {
        e.push({
            "entryname": sequence_data.bam_input.basename,
            "entry": {
                "class": "File",
                "location": sequence_data.bam_input.location
            }
        });
        /* Then add in each secondary file object */
        if (sequence_data.bam_input.secondaryFiles) {
            sequence_data.bam_input.secondaryFiles.forEach(function (secondary_file_iter_) {
                e.push({
                    "entryname": secondary_file_iter_.basename,
                    "entry": {
                        "class": "File",
                        "location": secondary_file_iter_.location
                    }
                })
            })
        }
    } else if ("cram_input" in sequence_data && sequence_data.cram_input !== undefined) {
        e.push({
            "entryname": sequence_data.cram_input.basename,
            "entry": {
                "class": "File",
                "location": sequence_data.cram_input.location
            }
        });
        /* Then add in each secondary file object */
        if (sequence_data.cram_input.secondaryFiles) {
            sequence_data.cram_input.secondaryFiles.forEach(function (secondary_file_iter_) {
                e.push({
                    "entryname": secondary_file_iter_.basename,
                    "entry": {
                        "class": "File",
                        "location": secondary_file_iter_.location
                    }
                })
            })
        }
        // We also add in the reference file if its provided
        if (sequence_data.cram_reference !== undefined) {
            e.push({
                "entryname": sequence_data.cram_reference.basename,
                "entry": {
                    "class": "File",
                    "location": sequence_data.cram_reference.location
                }
            })
            /* Then add in each secondary file object */
            if (sequence_data.cram_reference.secondaryFiles) {
                sequence_data.cram_reference.secondaryFiles.forEach(function (secondary_file_iter_) {
                    e.push({
                        "entryname": secondary_file_iter_.basename,
                        "entry": {
                            "class": "File",
                            "location": secondary_file_iter_.location
                        }
                    })
                })
            }
        }
    }

    // @ts-ignore Type '{ entryname: string; entry: FileProperties; }[]' is not assignable to type 'DirentProperties[]'
    return e
}


export function generate_alignment_data_mount_points(
    alignment_data: DragenInputAlignmentType,
    tumor_alignment_data: DragenInputAlignmentType | null
): Array<IDirent> {
    /*
    If the input is bam or cram, we mount as it 'un-cwlifies' the command line,
    as this is often attached to the bottom of the PG line in a bam file,
    we'd like to make that as short as possible
    */
    const e = [];

    // Add the alignment data data
    if ("bam_input" in alignment_data && alignment_data.bam_input !== undefined) {
        /* Add in the bam file */
        e.push({
            "entryname": alignment_data.bam_input.basename,
            /* Due to the secondary files, we need to manually add in each file object */
            "entry": {
                "class": "File",
                "location": alignment_data.bam_input.location
            }
        });

        /* Then add in each secondary file object */
        if (alignment_data.bam_input.secondaryFiles) {
            alignment_data.bam_input.secondaryFiles.forEach(function (secondary_file_iter_) {
                e.push({
                    "entryname": secondary_file_iter_.basename,
                    "entry": {
                        "class": "File",
                        "location": secondary_file_iter_.location
                    }
                })
            })
        }
    } else if ("cram_input" in alignment_data && alignment_data.cram_input !== undefined) {
        /* Add in the cram file */
        e.push({
            "entryname": alignment_data.cram_input.basename,
            "entry": {
                "class": "File",
                "location": alignment_data.cram_input.location
            }
        });

        /* Then add in each secondary file object */
        if (alignment_data.cram_input.secondaryFiles) {
            alignment_data.cram_input.secondaryFiles.forEach(function (secondary_file_iter_) {
                e.push({
                    "entryname": secondary_file_iter_.basename,
                    "entry": {
                        "class": "File",
                        "location": secondary_file_iter_.location
                    }
                })
            })
        }

        // We also add in the reference file if its provided
        if (alignment_data.cram_reference !== undefined) {
            e.push({
                "entryname": alignment_data.cram_reference.basename,
                "entry": {
                    "class": "File",
                    "location": alignment_data.cram_reference.location
                }
            })
            /* Then add in each secondary file object */
            if (alignment_data.cram_reference.secondaryFiles) {
                alignment_data.cram_reference.secondaryFiles.forEach(function (secondary_file_iter_) {
                    e.push({
                        "entryname": secondary_file_iter_.basename,
                        "entry": {
                            "class": "File",
                            "location": secondary_file_iter_.location
                        }
                    })
                })
            }
        }
    }

    /* Now repeat for tumor alignment data */
    if (tumor_alignment_data) {
        // Add the alignment data data
        if ("bam_input" in tumor_alignment_data && tumor_alignment_data.bam_input !== undefined) {
            /* Add in the bam file */
            e.push({
                "entryname": tumor_alignment_data.bam_input.basename,
                /* Due to the secondary files, we need to manually add in each file object */
                "entry": {
                    "class": "File",
                    "location": tumor_alignment_data.bam_input.location
                }
            });

            /* Then add in each secondary file object */
            if (tumor_alignment_data.bam_input.secondaryFiles) {
                tumor_alignment_data.bam_input.secondaryFiles.forEach(function (secondary_file_iter_) {
                    e.push({
                        "entryname": secondary_file_iter_.basename,
                        "entry": {
                            "class": "File",
                            "location": secondary_file_iter_.location
                        }
                    })
                })
            }
        } else if ("cram_input" in tumor_alignment_data && tumor_alignment_data.cram_input !== undefined) {
            /* Add in the cram file */
            e.push({
                "entryname": tumor_alignment_data.cram_input.basename,
                "entry": {
                    "class": "File",
                    "location": tumor_alignment_data.cram_input.location
                }
            });

            /* Then add in each secondary file object */
            if (tumor_alignment_data.cram_input.secondaryFiles) {
                tumor_alignment_data.cram_input.secondaryFiles.forEach(function (secondary_file_iter_) {
                    e.push({
                        "entryname": secondary_file_iter_.basename,
                        "entry": {
                            "class": "File",
                            "location": secondary_file_iter_.location
                        }
                    })
                })
            }

            // We also add in the reference file if its provided
            if (tumor_alignment_data.cram_reference !== undefined) {
                e.push({
                    "entryname": tumor_alignment_data.cram_reference.basename,
                    "entry": {
                        "class": "File",
                        "location": tumor_alignment_data.cram_reference.location
                    }
                })
                /* Then add in each secondary file object */
                if (tumor_alignment_data.cram_reference.secondaryFiles) {
                    tumor_alignment_data.cram_reference.secondaryFiles.forEach(function (secondary_file_iter_) {
                        e.push({
                            "entryname": secondary_file_iter_.basename,
                            "entry": {
                                "class": "File",
                                "location": secondary_file_iter_.location
                            }
                        })
                    })
                }
            }
        }
    }

    // @ts-ignore Type '{ entryname: string; entry: FileProperties; }[]' is not assignable to type 'DirentProperties[]'
    return e
}


export function dragen_merge_options(options_list: (Record<string, any> | null)[]) {
    /*
    Merge a list of objects, ignoring null or undefined values
    Options are merged in the order they are provided
    So if there are duplicate keys, the last one will be used
    */
    const merged_options: Record<string, any> = {}
    for (const options_object of options_list) {
        if (options_object === null || options_object === undefined) {
            continue
        }
        for (const key in options_object) {
            /*
             Check if the key is null or undefined.
            */
            if (options_object[key] === undefined) {
                continue
            }

            /*
              If the merged key does NOT exist in the merged options but the value is null we add it in
            */
            if ((!merged_options.hasOwnProperty(key)) && options_object[key] === null) {
                merged_options[key] = null
                continue
            }

            /*
              If the merged key DOES exist in the merged options but the value is null we skip it
            */
            if (merged_options.hasOwnProperty(key) && options_object[key] === null) {
                continue
            }

            /*
              If the key already exists in merged options, check if the
              merged_options key is a dictionary, if so we need to recursively merge instead
            */

            if (
                merged_options.hasOwnProperty(key) &&
                typeof merged_options[key] === 'object' &&
                (merged_options[key] !== null) &&
                !Array.isArray(merged_options[key])
            ) {
                /*
                  Check the item key is also an object
                */
                if (typeof options_object[key] === 'object' && !Array.isArray(options_object[key])) {
                    /*
                      If the key is an object, we merge the two objects
                      This is useful for options that have sub-options
                      However we dont to override values in merged_options that are already set
                      if the value in the options object is null,
                      we can solve this by calling the dragen_merge_options function recursively
                    */
                    merged_options[key] = dragen_merge_options([
                        merged_options[key],
                        options_object[key]
                    ])
                }
                /*
                  Otherwise we just override it.
                */
                else {
                    merged_options[key] = options_object[key]
                }
                continue
            }
            /*
            Just a standard option.
            */
            if (options_object.hasOwnProperty(key)) {
                merged_options[key] = options_object[key]
            }
        }
    }

    return merged_options
}


export function get_dragen_wgts_dna_alignment_stage_options_from_pipeline(props: DragenWgtsDnaAlignmentStageOptionsFromPipelineProps): DragenWgtsOptionsAlignmentStage {
    /*
        ? : syntax is required
        since we also need to consider that all inputs are
        evaluated before 'when'
    */

    return <DragenWgtsOptionsAlignmentStage>{
        /* Data inputs */
        sequence_data: props.sequence_data,
        ref_tar: props.reference.tarball,

        /* Ora reference */
        ora_reference: props.ora_reference ? props.ora_reference : null,

        /* Stage specific options */
        output_directory: (
            `${props.sample_name ? props.sample_name : ""}__` +
            `${props.reference.name}__` +
            `${props.reference.structure}__dragen_alignment`
        ),
        output_file_prefix: props.sample_name ? props.sample_name : "",

        /* License file */
        lic_instance_id_location: (
            props.lic_instance_id_location ? props.lic_instance_id_location : DEFAULT_LIC_INSTANCE_ID_LOCATION_PATH
        ),

        /* Alignment options */
        alignment_options: dragen_merge_options([
            filter_object_by_keys(props.default_configuration_options, props.alignment_options),
            props.alignment_options,
        ])
    }
}


export function get_dragen_wgts_rna_alignment_stage_options_from_pipeline(props: DragenWgtsRnaAlignmentStageOptionsFromPipelineProps): DragenWgtsOptionsAlignmentStage {
    /*
        ? : syntax is required
        since we also need to consider that all inputs are
        evaluated before 'when'
    */


    return <DragenWgtsOptionsAlignmentStage>{
        /* Data inputs */
        sequence_data: props.sequence_data,
        ref_tar: props.reference.tarball,

        /* Ora reference */
        ora_reference: props.ora_reference ? props.ora_reference : null,

        /* Stage specific options */
        output_directory: (
            `${props.sample_name}__` +
            `${props.reference.name}__` +
            `${props.reference.structure}__dragen_rna_alignment`
        ),
        output_file_prefix: props.sample_name ? props.sample_name : "",

        /* License file */
        lic_instance_id_location: (
            props.lic_instance_id_location ? props.lic_instance_id_location : DEFAULT_LIC_INSTANCE_ID_LOCATION_PATH
        ),

        /* Set enable rna to true */
        enable_rna: true,

        /* Alignment options */
        alignment_options: dragen_merge_options([
            filter_object_by_keys(props.default_configuration_options, props.alignment_options),
            props.alignment_options,
        ])
    }
}

export function filter_object_by_keys(object1: Record<string, any>, object2: Record<string, any>) {
    /**
     * Return object 1 with only the keys that are in object 2
     */
    const filtered_object: Record<string, any> = {}
    /* Dont need to filter if object1 is null or undefined */
    if (object1 === null || object1 === undefined) {
        return object2
    }
    /* Iterate through object1 and check if the key is in object2 */
    for (const key in object1) {
        if (object2.hasOwnProperty(key)) {
            filtered_object[key] = object1[key]
        }
    }
    return filtered_object
}


export function get_dragen_wgts_dna_variant_calling_stage_options_from_pipeline(props: DragenWgtsDnaVariantCallingStageOptionsFromPipelineProps): DragenWgtsDnaOptionsVariantCallingStage {
    /*
        ? : syntax is required
        since we also need to consider that all inputs are
        evaluated before 'when'
    */

    /* Convert bam_output to bam_input or cram_output to cram_input */
    let alignment_data = null
    if ("bam_output" in props.alignment_data) {
        alignment_data = {
            'bam_input': props.alignment_data.bam_output
        }
    } else {
        alignment_data = {
            'cram_input': props.alignment_data.cram_output
        }
    }

    let tumor_alignment_data = null
    if (props.tumor_alignment_data) {
        if ("bam_output" in props.tumor_alignment_data) {
            /* Convert bam_output to bam_input or cram_output to cram_input */
            tumor_alignment_data = {
                'bam_input': props.tumor_alignment_data.bam_output
            }
        } else {
            tumor_alignment_data = {
                'cram_input': props.tumor_alignment_data.cram_output
            }
        }
    }

    return <DragenWgtsDnaOptionsVariantCallingStage>{
        /* Data inputs */
        alignment_data: alignment_data,
        tumor_alignment_data: tumor_alignment_data,
        ref_tar: props.reference.tarball,
        /* Stage specific options */
        /* Use tumor_sample_name if it exists otherwise use the standard sample name */
        output_file_prefix: (props.tumor_sample_name ? props.tumor_sample_name : props.sample_name),
        /* <TUMOR_SAMPLE_NAME>__<NORMAL_SAMPLE_NAME>_variant_calling for somatic data */
        /* <SAMPLE_NAME>_variant_calling for germline data */
        output_directory: (
            (props.tumor_sample_name ? props.tumor_sample_name + "__" : "") +
            props.sample_name + "__" +
            props.reference.name + "__" +
            props.reference.structure + "__dragen_variant_calling"
        ),
        /* Lic Instance id location */
        lic_instance_id_location: props.lic_instance_id_location,
        /* Variant caller options */
        snv_variant_caller_options: dragen_merge_options([
            filter_object_by_keys(props.default_configuration_options, props.snv_variant_caller_options),
            props.snv_variant_caller_options,
        ]),
        /* CNV caller options */
        cnv_caller_options: props.cnv_caller_options,
        /* MAF Conversion Options */
        maf_conversion_options: props.maf_conversion_options,
        /* SV caller options */
        sv_caller_options: dragen_merge_options([
            filter_object_by_keys(props.default_configuration_options, props.sv_caller_options),
            props.sv_caller_options,
        ]),
        /* Nirvana options */
        nirvana_annotation_options: props.nirvana_annotation_options,
        /* Targeted Caller options */
        targeted_caller_options: props.targeted_caller_options
    }
}


export function get_dragen_wgts_rna_variant_calling_stage_options_from_pipeline(props: DragenWgtsRnaVariantCallingStageOptionsFromPipelineProps): DragenWgtsRnaOptionsVariantCallingStage {
    return <DragenWgtsRnaOptionsVariantCallingStage>{
        /* Data inputs */
        sequence_data: props.sequence_data,
        ref_tar: props.reference.tarball,

        /* Ora reference */
        ora_reference: props.ora_reference ? props.ora_reference : null,

        /* Annotation file, used for a lot of the variant calling optoins */
        annotation_file: props.annotation_file,

        /* Stage specific options */
        /* Use tumor_sample_name if it exists otherwise use the standard sample name */
        output_file_prefix: props.sample_name,
        /* <TUMOR_SAMPLE_NAME>__<NORMAL_SAMPLE_NAME>_variant_calling for somatic data */
        /* <SAMPLE_NAME>_variant_calling for germline data */
        output_directory: (
            props.sample_name + "__" +
            props.reference.name + "__" +
            props.reference.structure + "__dragen_rna_variant_calling"
        ),
        /* Lic Instance id location */
        lic_instance_id_location: props.lic_instance_id_location,

        /* Alignment options */
        alignment_options: dragen_merge_options([
            filter_object_by_keys(props.default_configuration_options, props.alignment_options),
            props.alignment_options,
        ]),

        /* Variant caller options */
        snv_variant_caller_options: dragen_merge_options([
            filter_object_by_keys(props.default_configuration_options, props.snv_variant_caller_options),
            props.snv_variant_caller_options,
        ]),
        gene_expression_quantification_options: dragen_merge_options([
            filter_object_by_keys(props.default_configuration_options, props.gene_expression_quantification_options),
            props.gene_expression_quantification_options,
        ]),
        gene_fusion_detection_options: props.gene_fusion_detection_options,
        splice_variant_caller_options: props.splice_variant_caller_options,

        /* MAF Conversion Options */
        maf_conversion_options: props.maf_conversion_options,

        /* Nirvana options */
        nirvana_annotation_options: props.nirvana_annotation_options,
    }
}


/**
 * Multiqc functions
 *
 */

export function get_wgts_dna_multiqc_output_filename(props: MultiQcNamingOptionsProps) {
    return (props.tumor_sample_name ? props.tumor_sample_name + "_" : "") + props.sample_name + "_multiqc_report.html"
}

export function get_wgts_rna_multiqc_output_filename(props: MultiQcNamingOptionsProps) {
    /* Given a sample name, and potentially a tumor sample name, return the multiqc output directory name */
    return props.sample_name + "_multiqc_report.html"
}


export function get_wgts_dna_multiqc_output_directory_name(props: MultiQcNamingOptionsProps) {
    /* Given a sample name, and potentially a tumor sample name, return the multiqc output directory name */
    return (props.tumor_sample_name ? props.tumor_sample_name + "_" : "") + props.sample_name + "_multiqc"
}

export function get_wgts_rna_multiqc_output_directory_name(props: MultiQcNamingOptionsProps) {
    /* Given a sample name, and potentially a tumor sample name, return the multiqc output directory name */
    return props.sample_name + "_multiqc"
}


export function get_wgts_dna_multiqc_title(props: MultiQcNamingOptionsProps) {
    /* Given a sample name, and potentially a tumor sample name, return the multiqc output directory name */
    return (
        "Dragen 4.4.4 WGTS DNA Pipeline ( " +
        (props.tumor_sample_name ? props.tumor_sample_name + "/" : "") +
        props.sample_name + " )"
    )
}

export function get_wgts_rna_multiqc_title(props: MultiQcNamingOptionsProps) {
    /* Given a sample name, and potentially a tumor sample name, return the multiqc output directory name */
    return (
        "Dragen 4.4.4 WGTS RNA Pipeline ( " +
        props.sample_name +
        " )"
    )
}


export function pick_first_non_null(object_list: []): any {
    for (const object of object_list) {
        if (object) {
            return object
        }
    }
}

export function pick_all_non_null(object_list: []): any[] {
    const non_null_objects: any[] = []
    for (const object of object_list) {
        if (object) {
            non_null_objects.push(object)
        }
    }
    return non_null_objects
}


export function dragen_references_match(reference_list: DragenReference[]): boolean {
    /*
    Determine if the two references match,
    If one the references is null or undefined then still return true
    Since we really just want to know if we have two different references
    */
    if (reference_list.length !== 2) {
        throw new Error("dragen_references_match: reference_list must be of length 2")
    }

    /* Check if either of the references are null or undefined */
    if (!reference_list[0] || !reference_list[1]) {
        return true
    }

    return reference_list[0].tarball.location == reference_list[1].tarball.location;

}


/* Utility functions */

export function get_optional_attribute_from_object(input_object: { [key: string]: any }, attribute: string) {

    /*
    Get attribute from object, if attribute is not defined return null
    Assume the input object is an object of key value pairs where we know the key is of type string
    stackoverflow.com/questions/56833469/typescript-error-ts7053-element-implicitly-has-an-any-type
    */
    if (input_object.hasOwnProperty(attribute)) {
        return input_object[attribute]
    } else {
        return null
    }

}


export function get_attribute_from_optional_input(input_object: any, attribute: string) {
    /*
    Get attribute from optional input -
    If input is not defined, then return null
    */
    if (input_object === null || input_object === undefined) {
        return null
    } else {
        return get_optional_attribute_from_object(input_object, attribute)
    }
}

export function is_not_null(input_obj: any): boolean {
    /*
    Determine if input object is defined and is not null
    */
    return !(input_obj === null || input_obj === undefined);
}