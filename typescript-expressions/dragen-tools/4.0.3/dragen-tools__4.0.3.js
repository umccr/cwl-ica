"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_script_path = get_script_path;
exports.get_scratch_mount = get_scratch_mount;
exports.get_intermediate_results_dir = get_intermediate_results_dir;
exports.get_name_root_from_tarball = get_name_root_from_tarball;
exports.get_ref_path = get_ref_path;
exports.get_ref_mount = get_ref_mount;
exports.get_dragen_bin_path = get_dragen_bin_path;
exports.get_dragen_eval_line = get_dragen_eval_line;
exports.get_fastq_list_csv_path = get_fastq_list_csv_path;
exports.get_tumor_fastq_list_csv_path = get_tumor_fastq_list_csv_path;
exports.get_ora_mv_files_script_path = get_ora_mv_files_script_path;
exports.get_new_fastq_list_csv_script_path = get_new_fastq_list_csv_script_path;
exports.get_fastq_raw_md5sum_files_script_path = get_fastq_raw_md5sum_files_script_path;
exports.get_fastq_gz_file_sizes_script_path = get_fastq_gz_file_sizes_script_path;
exports.get_fastq_ora_md5sum_files_script_path = get_fastq_ora_md5sum_files_script_path;
exports.get_fastq_ora_file_sizes_script_path = get_fastq_ora_file_sizes_script_path;
exports.get_normal_name_from_fastq_list_rows = get_normal_name_from_fastq_list_rows;
exports.get_normal_name_from_fastq_list_csv = get_normal_name_from_fastq_list_csv;
exports.get_normal_output_prefix = get_normal_output_prefix;
exports.build_fastq_list_csv_header = build_fastq_list_csv_header;
exports.get_fastq_list_row_as_csv_row = get_fastq_list_row_as_csv_row;
exports.generate_fastq_list_csv = generate_fastq_list_csv;
exports.generate_germline_mount_points = generate_germline_mount_points;
exports.generate_somatic_mount_points = generate_somatic_mount_points;
exports.generate_transcriptome_mount_points = generate_transcriptome_mount_points;
exports.get_liftover_dir = get_liftover_dir;
exports.get_mask_dir = get_mask_dir;
exports.get_ref_scratch_dir = get_ref_scratch_dir;
exports.get_ora_intermediate_output_dir = get_ora_intermediate_output_dir;
exports.generate_ora_mv_files_script = generate_ora_mv_files_script;
exports.generate_new_fastq_list_csv_script = generate_new_fastq_list_csv_script;
exports.find_fastq_files_in_directory_recursively_with_regex = find_fastq_files_in_directory_recursively_with_regex;
exports.get_rgsm_value_from_fastq_file_name = get_rgsm_value_from_fastq_file_name;
exports.get_lane_value_from_fastq_file_name = get_lane_value_from_fastq_file_name;
exports.generate_ora_mount_points = generate_ora_mount_points;
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
function get_scratch_mount() {
    /*
    Return the path of the scratch directory space
    */
    return "/ephemeral/";
}
function get_intermediate_results_dir() {
    /*
    Get intermediate results directory as /scratch for dragen runs
    */
    return get_scratch_mount() + "intermediate-results/";
}
function get_name_root_from_tarball(basename) {
    var tar_ball_regex = /(\S+)\.tar\.gz/g;
    var tar_ball_expression = tar_ball_regex.exec(basename);
    if (tar_ball_expression === null) {
        throw new Error("Could not get nameroot from ".concat(basename));
    }
    return tar_ball_expression[1];
}
function get_ref_path(reference_input_obj) {
    /*
    Get the reference path
    */
    return get_ref_mount() + get_name_root_from_tarball(reference_input_obj.basename) + "/";
}
function get_ref_mount() {
    /*
    Get the reference mount point
    */
    return get_scratch_mount() + "ref/";
}
function get_dragen_bin_path() {
    /*
    Get dragen bin path
    */
    return "/opt/edico/bin/dragen";
}
function get_dragen_eval_line() {
    /*
    Return string
    */
    return "eval \"" + get_dragen_bin_path() + "\" '\"\$@\"' \n";
}
function get_fastq_list_csv_path() {
    /*
    The fastq list path must be placed in working directory
    */
    return "fastq_list.csv";
}
function get_tumor_fastq_list_csv_path() {
    /*
    The tumor fastq list path must be placed in working directory
    */
    return "tumor_fastq_list.csv";
}
function get_ora_mv_files_script_path() {
    /*
    Get the ora mv files script path
    */
    return "mv-ora-output-files.sh";
}
function get_new_fastq_list_csv_script_path() {
    /*
    Get the new fastq list csv script path
    */
    return "generate-new-fastq-list-csv.sh";
}
function get_fastq_raw_md5sum_files_script_path() {
    /*
    Get the script path to generating the md5sum for each fastq gzip file
    */
    return "generate-md5sum-for-fastq-raw-files.sh";
}
function get_fastq_gz_file_sizes_script_path() {
    /*
    Get the script path to generating the filesizes for each fastq gzip file
    */
    return "generate-file-sizes-for-fastq-gz-files.sh";
}
function get_fastq_ora_md5sum_files_script_path() {
    /*
    Get the script path for generating the md5sum for each fastq ora file
    */
    return "generate-md5sum-for-fastq-ora-files.sh";
}
function get_fastq_ora_file_sizes_script_path() {
    /*
    Get the script path to generating the filesizes for each fastq gzip file
    */
    return "generate-file-sizes-for-fastq-ora-files.sh";
}
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
function get_normal_output_prefix(inputs) {
    var _a, _b;
    /*
    Get the normal RGSM value and then add _normal to it
    */
    var normal_name = null;
    var normal_re_replacement = /_normal$/;
    /*
    Check if bam_input is set
    */
    if (inputs.bam_input !== null && inputs.bam_input !== undefined) {
        /* Remove _normal from nameroot if it already exists */
        /* We dont want _normal_normal as a suffix */
        return "".concat((_a = inputs.bam_input.nameroot) === null || _a === void 0 ? void 0 : _a.replace(normal_re_replacement, ""), "_normal");
    }
    /*
    Check if cram_input is set
    */
    if (inputs.cram_input !== null && inputs.cram_input !== undefined) {
        /* Remove _normal from nameroot if it already exists */
        /* We dont want _normal_normal as a suffix */
        return "".concat((_b = inputs.cram_input.nameroot) === null || _b === void 0 ? void 0 : _b.replace(normal_re_replacement, ""), "_normal");
    }
    /*
    Check if fastq list file is set
    */
    if (inputs.fastq_list !== null && inputs.fastq_list !== undefined) {
        normal_name = get_normal_name_from_fastq_list_csv(inputs.fastq_list);
        if (normal_name !== null) {
            return "".concat(normal_name, "_normal");
        }
    }
    /*
    Otherwise collect and return from schema object
    */
    normal_name = get_normal_name_from_fastq_list_rows(inputs.fastq_list_rows);
    return "".concat(normal_name, "_normal");
}
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
function get_fastq_list_row_as_csv_row(fastq_list_row, row_order) {
    var fastq_list_row_values_array = [];
    // This for loop is here to ensure were assigning values in the same order as the header
    for (var _i = 0, row_order_1 = row_order; _i < row_order_1.length; _i++) {
        var item_index = row_order_1[_i];
        var found_item = false;
        // Find matching attribute in this row
        for (var _a = 0, _b = Object.getOwnPropertyNames(fastq_list_row); _a < _b.length; _a++) {
            var fastq_list_row_field_name = _b[_a];
            var fastq_list_row_field_value = fastq_list_row[fastq_list_row_field_name];
            if (fastq_list_row_field_value === null) {
                /*
                Item not found, add an empty attribute for this cell in the csv
                */
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
                found_item = true;
                break;
            }
        }
        if (!found_item) {
            /*
            Push blank cell if no item found
            */
            fastq_list_row_values_array.push("");
        }
    }
    /*
    Convert to string and return as string
    */
    return fastq_list_row_values_array.join(",") + "\n";
}
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
function generate_transcriptome_mount_points(inputs) {
    /*
    Calls another function that generates mount points
    */
    return generate_germline_mount_points(inputs);
}
// Custom functions for dragen reference tarball build
function get_liftover_dir() {
    // Hardcoded liftover directory in dragen 4.2
    return "/opt/edico/liftover/";
}
function get_mask_dir() {
    // Hardcoded mask directory in dragen 4.2
    return "/opt/edico/fasta_mask/";
}
function get_ref_scratch_dir(reference_name) {
    // We get the reference scratch directory as a combination of
    // the dragen scratch mount and the reference name
    return get_scratch_mount() + reference_name + "/";
}
function get_ora_intermediate_output_dir() {
    return get_scratch_mount() + "ora-outputs/";
}
function generate_ora_mv_files_script(fastq_list_rows, input_directory, output_directory) {
    /*
    Generate the shell script with a list of echo commands to write a new fastq list csv to stdout, however
    the fastq list csv contains the ora files as outputs instead
    */
    var ora_mv_files_script = "#!/usr/bin/env bash\n\n";
    ora_mv_files_script += "# Exit on failure\n";
    ora_mv_files_script += "set -euo pipefail\n\n";
    ora_mv_files_script += "# Get fastq ora paths\n";
    ora_mv_files_script += "FASTQ_ORA_OUTPUT_PATHS=(\n";
    // Iterate over all files
    for (var _i = 0, fastq_list_rows_3 = fastq_list_rows; _i < fastq_list_rows_3.length; _i++) {
        var fastq_list_row = fastq_list_rows_3[_i];
        // Confirm read 1 is a file type
        if ("class_" in fastq_list_row.read_1 && fastq_list_row.read_1.class_ === cwl_ts_auto_1.File_class.FILE) {
            // Add relative path of read 1
            ora_mv_files_script += "  \"".concat(fastq_list_row.read_1.path.replace(input_directory.path + "/", '').replace(".gz", ".ora"), "\" \\\n");
        }
        // Confirm read 2 is a file type
        if (fastq_list_row.read_2 !== null && "class_" in fastq_list_row.read_2 && fastq_list_row.read_2.class_ === cwl_ts_auto_1.File_class.FILE) {
            // Add relative path of read 2
            ora_mv_files_script += "  \"".concat(fastq_list_row.read_2.path.replace(input_directory.path + "/", '').replace(".gz", ".ora"), "\" \\\n");
        }
    }
    // Complete the bash array
    ora_mv_files_script += ")\n\n";
    ora_mv_files_script += "# Move all ora files to the final output directory\n";
    ora_mv_files_script += "xargs \\\n";
    ora_mv_files_script += "  --max-args=1 \\\n";
    ora_mv_files_script += "  --max-procs=16 \\\n";
    ora_mv_files_script += "  bash -c \\\n";
    ora_mv_files_script += "    '\n";
    ora_mv_files_script += "      fastq_ora_scratch_path=\"".concat(get_ora_intermediate_output_dir(), "$(basename \"$@\")\"\n");
    ora_mv_files_script += "      mkdir -p \"$(dirname \"".concat(output_directory, "/$@\")\"\n");
    ora_mv_files_script += "      rsync \\\n";
    ora_mv_files_script += "        --archive \\\n";
    ora_mv_files_script += "        --remove-source-files \\\n";
    ora_mv_files_script += "        --include \"$(basename \"$@\")\" \\\n";
    ora_mv_files_script += "        --exclude \"*\" \\\n";
    ora_mv_files_script += "        \"$(dirname \"${fastq_ora_scratch_path}\")/\" \\\n";
    ora_mv_files_script += "        \"$(dirname \"".concat(output_directory, "/$@\")/\"\n");
    ora_mv_files_script += "    ' \\\n";
    ora_mv_files_script += "  _ \\\n";
    ora_mv_files_script += "  <<< \"${FASTQ_ORA_OUTPUT_PATHS[@]}\"\n\n";
    ora_mv_files_script += "# Transfer all other files\n";
    ora_mv_files_script += "mkdir -p \"".concat(output_directory, "/ora-logs/\"\n");
    ora_mv_files_script += "mv \"".concat(get_ora_intermediate_output_dir(), "\" \"").concat(output_directory, "/ora-logs/compression/\"\n");
    return {
        class_: cwl_ts_auto_1.File_class.FILE,
        basename: get_ora_mv_files_script_path(),
        contents: ora_mv_files_script
    };
}
function generate_new_fastq_list_csv_script(fastq_list_rows, input_directory) {
    /*
    Generate the shell script with a list of mv commands to move the output files from the scratch space to their
    original location in the working directory
    */
    var new_fastq_list_csv_script = "#!/usr/bin/env bash\n\n";
    new_fastq_list_csv_script += "set -euo pipefail\n\n";
    new_fastq_list_csv_script += "# Generate a new fastq list csv script\n";
    new_fastq_list_csv_script += "# Initialise header\n";
    new_fastq_list_csv_script += "echo \"RGID,RGLB,RGSM,Lane,Read1File,Read2File\"\n";
    for (var _i = 0, fastq_list_rows_4 = fastq_list_rows; _i < fastq_list_rows_4.length; _i++) {
        var fastq_list_row = fastq_list_rows_4[_i];
        // Initialise echo line
        var echo_line = "echo \"".concat(fastq_list_row.rgid, ",").concat(fastq_list_row.rglb, ",").concat(fastq_list_row.rgsm, ",").concat(fastq_list_row.lane, ",");
        // Confirm read 1 is a file type
        if ("class_" in fastq_list_row.read_1 && fastq_list_row.read_1.class_ === cwl_ts_auto_1.File_class.FILE) {
            echo_line += "".concat(fastq_list_row.read_1.path.replace(input_directory.path + "/", '').replace(".gz", ".ora"), ",");
        }
        else {
            echo_line += ',';
        }
        // Confirm read 2 is a file type
        if (fastq_list_row.read_2 !== null && "class_" in fastq_list_row.read_2 && fastq_list_row.read_2.class_ === cwl_ts_auto_1.File_class.FILE) {
            echo_line += "".concat(fastq_list_row.read_2.path.replace(input_directory.path + "/", '').replace(".gz", ".ora"));
        }
        // Finish off echo line
        echo_line += "\"\n";
        new_fastq_list_csv_script += echo_line;
    }
    return {
        class_: cwl_ts_auto_1.File_class.FILE,
        basename: get_new_fastq_list_csv_script_path(),
        contents: new_fastq_list_csv_script
    };
}
function find_fastq_files_in_directory_recursively_with_regex(input_dir) {
    var _a;
    /*
    Initialise the output file object
    */
    var read_1_file_list = [];
    var read_2_file_list = [];
    var output_file_objs = [];
    var fastq_file_regex = /\.fastq\.gz$/;
    var r1_fastq_file_regex = /_R1_001\.fastq\.gz$/;
    var r2_fastq_file_regex = /_R2_001\.fastq\.gz$/;
    /*
    Check input_dir is a directory and has a listing
    */
    if (input_dir.class_ === undefined || input_dir.class_ !== cwl_ts_auto_1.Directory_class.DIRECTORY) {
        throw new Error("Could not confirm that the first argument was a directory");
    }
    if (input_dir.listing === undefined || input_dir.listing === null) {
        throw new Error("Could not collect listing from directory \"".concat(input_dir.basename, "\""));
    }
    /*
    Collect listing as a variable
    */
    var input_listing = input_dir.listing;
    /*
    Iterate through the file listing
    */
    for (var _i = 0, input_listing_1 = input_listing; _i < input_listing_1.length; _i++) {
        var listing_item = input_listing_1[_i];
        if (listing_item.class_ === cwl_ts_auto_1.File_class.FILE && fastq_file_regex.test(listing_item.basename)) {
            /*
            Got the file of interest and the file basename matches the file regex
            */
            /*
            Check if the file is read 1 or read 2
            */
            if (r1_fastq_file_regex.test(listing_item.basename)) {
                read_1_file_list.push(listing_item);
            }
            if (r2_fastq_file_regex.test(listing_item.basename)) {
                read_2_file_list.push(listing_item);
            }
        }
        if (listing_item.class_ === cwl_ts_auto_1.Directory_class.DIRECTORY) {
            var subdirectory_list = listing_item;
            try {
                // Consider that the file might not be in this subdirectory and that is okay
                output_file_objs.push.apply(output_file_objs, find_fastq_files_in_directory_recursively_with_regex(subdirectory_list));
            }
            catch (error) {
                // Dont need to report an error though, just continue
            }
        }
    }
    // Iterate over all the read 1 files and try to find a matching read 2 file
    for (var _b = 0, read_1_file_list_1 = read_1_file_list; _b < read_1_file_list_1.length; _b++) {
        var read_1_file = read_1_file_list_1[_b];
        var read_2_file = undefined;
        for (var _c = 0, read_2_file_list_1 = read_2_file_list; _c < read_2_file_list_1.length; _c++) {
            var read_2_file_candidate = read_2_file_list_1[_c];
            if (((_a = read_1_file.basename) === null || _a === void 0 ? void 0 : _a.replace("R1_001.fastq.gz", "R2_001.fastq.gz")) === read_2_file_candidate.basename) {
                read_2_file = read_2_file_candidate;
                break;
            }
        }
        output_file_objs.push({ read1obj: read_1_file, read2obj: read_2_file });
    }
    // Return the output file object
    return output_file_objs;
}
function get_rgsm_value_from_fastq_file_name(fastq_file_name) {
    // Get the RGID value from the fastq file name
    var rgid_regex = /(.+?)(?:_S\d+)?(?:_L00\d)?_R[12]_001\.fastq\.gz$/;
    var rgid_expression = rgid_regex.exec(fastq_file_name);
    if (rgid_expression === null) {
        throw new Error("Could not get rgid from ".concat(fastq_file_name));
    }
    return rgid_expression[1];
}
function get_lane_value_from_fastq_file_name(fastq_file_name) {
    // Get the lane value from the fastq file name
    var lane_regex = /(?:.+?)(?:_S\d+)?_L00(\d)_R[12]_001\.fastq\.gz$/;
    var lane_expression = lane_regex.exec(fastq_file_name);
    if (lane_expression === null) {
        return 1;
    }
    else {
        console.log(lane_expression);
        return parseInt(lane_expression[1]);
    }
}
function generate_ora_mount_points(input_run, output_directory_path, sample_id_list) {
    /*
    Three main parts

    1. Collect the fastq files
    2. For each fastq file pair, generate the rgid, rgsm, rglb and lane attributes as necessary to make a fastq list row
    3. Generate the fastq list csv file
    */
    // Collect the fastq files
    var fastq_files_pairs = find_fastq_files_in_directory_recursively_with_regex(input_run);
    // For each fastq file pair, generate the rgid, rgsm, rglb and lane attributes as necessary
    var fastq_list_rows = [];
    for (var _i = 0, fastq_files_pairs_1 = fastq_files_pairs; _i < fastq_files_pairs_1.length; _i++) {
        var fastq_files_pair = fastq_files_pairs_1[_i];
        var rgsm_value = get_rgsm_value_from_fastq_file_name(fastq_files_pair.read1obj.basename);
        // Skip fastq list pair if sample_id_list is defined and the rgsm_value is not in the list
        if (sample_id_list !== undefined && sample_id_list !== null && sample_id_list !== "" && sample_id_list.indexOf(rgsm_value) === -1) {
            continue;
        }
        // Remove undetermined files from the list of fastqs to process (they are often empty)
        if (rgsm_value === "Undetermined") {
            continue;
        }
        // Check if we have the size attribute and if so check if it is greater than 0
        if (fastq_files_pair.read1obj.size !== null && fastq_files_pair.read1obj.size !== undefined && fastq_files_pair.read1obj.size == 0) {
            continue;
        }
        // Repeat the condition for read 2 although also ensure that read 2 is also actually defined
        if (fastq_files_pair.read2obj !== undefined && fastq_files_pair.read2obj !== null) {
            if (fastq_files_pair.read2obj.size !== null && fastq_files_pair.read2obj.size !== undefined && fastq_files_pair.read2obj.size == 0) {
                continue;
            }
        }
        var lane_value = get_lane_value_from_fastq_file_name(fastq_files_pair.read1obj.basename);
        var fastq_list_row = {
            rgid: lane_value.toString() + '.' + rgsm_value,
            rgsm: rgsm_value,
            rglb: "UnknownLibrary",
            lane: lane_value,
            read_1: fastq_files_pair.read1obj,
            read_2: fastq_files_pair.read2obj
        };
        fastq_list_rows.push(fastq_list_row);
    }
    // Initialise dirent
    var e = [];
    // Generate the fastq list csv file
    e.push({
        "entryname": get_fastq_list_csv_path(),
        "entry": generate_fastq_list_csv(fastq_list_rows)
    });
    // Generate the script to then move the files from the scratch space to the working directory
    e.push({
        "entryname": get_ora_mv_files_script_path(),
        "entry": generate_ora_mv_files_script(fastq_list_rows, input_run, output_directory_path)
    });
    // Generate the script to generate the new output fastq list csv
    e.push({
        "entryname": get_new_fastq_list_csv_script_path(),
        "entry": generate_new_fastq_list_csv_script(fastq_list_rows, input_run)
    });
    // Return the dirent
    // @ts-ignore Type '{ entryname: string; entry: FileProperties; }[]' is not assignable to type 'DirentProperties[]'
    return e;
}
