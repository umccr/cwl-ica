"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generate_somatic_mount_points = exports.generate_germline_mount_points = exports.generate_fastq_list_csv = exports.get_fastq_list_row_as_csv_row = exports.build_fastq_list_csv_header = exports.get_normal_output_prefix = exports.get_normal_name_from_fastq_list_csv = exports.get_normal_name_from_fastq_list_rows = exports.get_tumor_fastq_list_csv_path = exports.get_fastq_list_csv_path = exports.get_dragen_eval_line = exports.get_dragen_bin_path = exports.get_ref_mount = exports.get_ref_path = exports.get_name_root_from_tarball = exports.get_intermediate_results_dir = exports.get_scratch_mount = exports.get_script_path = void 0;
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
var cwl_ts_auto_1 = require("cwl-ts-auto");
// Functions
function get_script_path() {
    /*
    Abstract script path, can then be referenced in baseCommand attribute too
    Makes things more readable.
    */
    return "run-dragen-script.sh";
}
exports.get_script_path = get_script_path;
function get_scratch_mount() {
    /*
    Return the path of the scratch directory space
    */
    return "/ephemeral/";
}
exports.get_scratch_mount = get_scratch_mount;
function get_intermediate_results_dir() {
    /*
    Get intermediate results directory as /scratch for dragen runs
    */
    return get_scratch_mount() + "intermediate-results/";
}
exports.get_intermediate_results_dir = get_intermediate_results_dir;
function get_name_root_from_tarball(basename) {
    var tar_ball_regex = /(\S+)\.tar\.gz/g;
    var tar_ball_expression = tar_ball_regex.exec(basename);
    if (tar_ball_expression === null) {
        throw new Error("Could not get nameroot from ".concat(basename));
    }
    return tar_ball_expression[1];
}
exports.get_name_root_from_tarball = get_name_root_from_tarball;
function get_ref_path(reference_input_obj) {
    /*
    Get the reference path
    */
    return get_ref_mount() + get_name_root_from_tarball(reference_input_obj.basename) + "/";
}
exports.get_ref_path = get_ref_path;
function get_ref_mount() {
    /*
    Get the reference mount point
    */
    return get_scratch_mount() + "ref/";
}
exports.get_ref_mount = get_ref_mount;
function get_dragen_bin_path() {
    /*
    Get dragen bin path
    */
    return "/opt/edico/bin/dragen";
}
exports.get_dragen_bin_path = get_dragen_bin_path;
function get_dragen_eval_line() {
    /*
    Return string
    */
    return "eval \"" + get_dragen_bin_path() + "\" '\"\$@\"' \n";
}
exports.get_dragen_eval_line = get_dragen_eval_line;
function get_fastq_list_csv_path() {
    /*
    The fastq list path must be placed in working directory
    */
    return "fastq_list.csv";
}
exports.get_fastq_list_csv_path = get_fastq_list_csv_path;
function get_tumor_fastq_list_csv_path() {
    /*
    The tumor fastq list path must be placed in working directory
    */
    return "tumor_fastq_list.csv";
}
exports.get_tumor_fastq_list_csv_path = get_tumor_fastq_list_csv_path;
function get_normal_name_from_fastq_list_rows(fastq_list_rows) {
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
    return fastq_list_rows[0].rgsm;
}
exports.get_normal_name_from_fastq_list_rows = get_normal_name_from_fastq_list_rows;
function get_normal_name_from_fastq_list_csv(fastq_list_csv) {
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
    if (fastq_list_csv.class_ !== cwl_ts_auto_1.File_class.FILE) {
        throw new Error("Could not confirm input fastq_list_csv is of type File");
    }
    /*
    Split contents by line
    */
    var contents_by_line = [];
    fastq_list_csv.contents.split("\n").forEach(function (line_content) {
        var stripped_line_content = line_content.replace(/(\r\n|\n|\r)/gm, "");
        if (stripped_line_content !== "") {
            contents_by_line.push(stripped_line_content);
        }
    });
    var column_names = contents_by_line[0].split(",");
    /*
    Get RGSM index value (which column is RGSM at?)
    */
    var rgsm_index = column_names.indexOf("RGSM");
    /*
    RGSM is not in index. Return null
    */
    if (rgsm_index === -1) {
        return null;
    }
    /*
    Get RGSM value of first row and return
    */
    return contents_by_line[1].split(",")[rgsm_index];
}
exports.get_normal_name_from_fastq_list_csv = get_normal_name_from_fastq_list_csv;
function get_normal_output_prefix(inputs) {
    /*
    Get the normal RGSM value and then add _normal to it
    */
    var normal_name = null;
    if (inputs.fastq_list !== null && inputs.fastq_list !== undefined) {
        normal_name = get_normal_name_from_fastq_list_csv(inputs.fastq_list);
        if (normal_name !== null) {
            return normal_name;
        }
    }
    normal_name = get_normal_name_from_fastq_list_rows(inputs.fastq_list_rows);
    return normal_name;
}
exports.get_normal_output_prefix = get_normal_output_prefix;
function build_fastq_list_csv_header(header_names) {
    /*
    Convert lowercase labels to uppercase values
    i.e
    [ "rgid", "rglb", "rgsm", "lane", "read_1", "read_2" ]
    to
    "RGID,RGLB,RGSM,Lane,Read1File,Read2File"
    */
    var modified_header_names = [];
    for (var _i = 0, header_names_1 = header_names; _i < header_names_1.length; _i++) {
        var header_name = header_names_1[_i];
        if (header_name.indexOf("rg") === 0) {
            /*
            rgid -> RGID
            */
            modified_header_names.push(header_name.toUpperCase());
        }
        else if (header_name.indexOf("read") === 0) {
            /*
            read_1 -> Read1File
            */
            modified_header_names.push("Read" + header_name.charAt(header_name.length - 1) + "File");
        }
        else {
            /*
            lane to Lane
            */
            modified_header_names.push(header_name[0].toUpperCase() + header_name.substr(1));
        }
    }
    /*
    Convert array to comma separated strings
    */
    return modified_header_names.join(",") + "\n";
}
exports.build_fastq_list_csv_header = build_fastq_list_csv_header;
function get_fastq_list_row_as_csv_row(fastq_list_row, row_order) {
    var fastq_list_row_values_array = [];
    // This for loop is here to ensure were assigning values in the same order as the header
    for (var _i = 0, row_order_1 = row_order; _i < row_order_1.length; _i++) {
        var item_index = row_order_1[_i];
        // Find matching attribute in this row
        for (var _a = 0, _b = Object.getOwnPropertyNames(fastq_list_row); _a < _b.length; _a++) {
            var fastq_list_row_field_name = _b[_a];
            var fastq_list_row_field_value = fastq_list_row[fastq_list_row_field_name];
            if (fastq_list_row_field_value === null) {
                /*
                Item not found, add an empty attribute for this cell in the csv
                */
                fastq_list_row_values_array.push("");
                continue;
            }
            // The header value matches the name in the item
            if (fastq_list_row_field_name === item_index) {
                /*
                If the field value has a class attribute then it's either read_1 or read_2
                */
                if (fastq_list_row_field_value.hasOwnProperty("class_")) {
                    var fastq_list_row_field_value_file = fastq_list_row_field_value;
                    /*
                    Assert that this is actually of class file
                    */
                    if (fastq_list_row_field_value_file.class_ !== cwl_ts_auto_1.File_class.FILE) {
                        fastq_list_row_values_array.push("");
                        continue;
                    }
                    if (fastq_list_row_field_value_file.path !== null && fastq_list_row_field_value_file.path !== undefined) {
                        /*
                        Push the path attribute to the fastq list csv row if it is not null
                        */
                        fastq_list_row_values_array.push(fastq_list_row_field_value_file.path);
                    }
                    else {
                        /*
                        Otherwise push the location attribute
                        */
                        fastq_list_row_values_array.push(fastq_list_row_field_value_file.location);
                    }
                }
                else {
                    /*
                    Push the string attribute to the fastq list csv row
                    */
                    fastq_list_row_values_array.push(fastq_list_row_field_value.toString());
                }
                break;
            }
        }
    }
    /*
    Convert to string and return as string
    */
    return fastq_list_row_values_array.join(",") + "\n";
}
exports.get_fastq_list_row_as_csv_row = get_fastq_list_row_as_csv_row;
function generate_fastq_list_csv(fastq_list_rows) {
    /*
    Fastq list rows generation
    */
    var fastq_csv_file = {
        class_: cwl_ts_auto_1.File_class.FILE,
        basename: get_fastq_list_csv_path()
    };
    /*
    Set the row order
    */
    var row_order = [];
    /*
    Set the array order
    Make sure we iterate through all rows of the array
    */
    for (var _i = 0, fastq_list_rows_1 = fastq_list_rows; _i < fastq_list_rows_1.length; _i++) {
        var fastq_list_row = fastq_list_rows_1[_i];
        for (var _a = 0, _b = Object.getOwnPropertyNames(fastq_list_row); _a < _b.length; _a++) {
            var fastq_list_row_field_name = _b[_a];
            if (row_order.indexOf(fastq_list_row_field_name) === -1) {
                row_order.push(fastq_list_row_field_name);
            }
        }
    }
    /*
    Make header
    */
    fastq_csv_file.contents = build_fastq_list_csv_header(row_order);
    /*
    For each fastq list row,
    collect the values of each attribute but in the order of the header
    */
    for (var _c = 0, fastq_list_rows_2 = fastq_list_rows; _c < fastq_list_rows_2.length; _c++) {
        var fastq_list_row = fastq_list_rows_2[_c];
        // Add csv row to file contents
        fastq_csv_file.contents += get_fastq_list_row_as_csv_row(fastq_list_row, row_order);
    }
    return fastq_csv_file;
}
exports.generate_fastq_list_csv = generate_fastq_list_csv;
function generate_germline_mount_points(inputs) {
    /*
    Create and add in the fastq list csv for the input fastqs
    */
    var e = [];
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
exports.generate_germline_mount_points = generate_germline_mount_points;
function generate_somatic_mount_points(inputs) {
    /*
    Create and add in the fastq list csv for the input fastqs
    */
    var e = [];
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
exports.generate_somatic_mount_points = generate_somatic_mount_points;
