"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_fastq_list_rows_from_file = void 0;
var cwl_ts_auto_1 = require("cwl-ts-auto");
function get_fastq_list_rows_from_file(fastq_list_csv) {
    /*
    Load inputs initialise output variables
    Assumes only RG parameters set by bclconvert are RGID, RGSM, RGLB (in that order)
    */
    var output_array = [];
    // Assert that fastq list csv is defined and not null
    if (fastq_list_csv === undefined || fastq_list_csv === null) {
        throw new Error("Could not get fastq list csv file object, got '".concat(fastq_list_csv, "' instead"));
    }
    // Math.pow(2, 16) is about 64 kb
    if (Math.pow(2, 16) < fastq_list_csv.size) {
        throw new Error("fastq_list.csv must be smaller than 64 Kb, but got a file of size ".concat(fastq_list_csv.size, " bytes!"));
    }
    if (fastq_list_csv.contents === undefined) {
        throw new Error("Could not read in fastq_list.csv file contents");
    }
    var lines = fastq_list_csv.contents.split("\n");
    /*
    Generate output object by iterating through fastq_list csv
    */
    var is_first_line = true;
    for (var _i = 0, lines_1 = lines; _i < lines_1.length; _i++) {
        var line = lines_1[_i];
        if (is_first_line) {
            is_first_line = false;
            if (line.trim().indexOf("RGID,RGSM,RGLB,Lane,Read1File") !== 0) {
                throw new Error("Could not confirm that the first line was at least started in the order of 'RGID,RGSM,RGLB,Lane,Read1File' got ".concat(line, " instead"));
            }
            continue;
        }
        if (line.trim() === "") {
            /*
            Empty blank line at the end of the file
            */
            continue;
        }
        var _a = line.trim().split(","), rgid = _a[0], rgsm = _a[1], rglb = _a[2], lane = _a[3], read_1_path = _a[4], read_2_path = _a[5];
        /*
        Confirm none of rgid, rgsm, rglb, lane, and read_1_path are null
        */
        /*
        Initialise the output row as a dict
        */
        var output_fastq_list_row = {
            rgid: rgid,
            rgsm: rgsm,
            rglb: rglb,
            lane: Number(lane),
            read_1: {
                "class_": cwl_ts_auto_1.File_class.FILE,
                "path": read_1_path
            }
        };
        if (read_2_path != null && read_2_path !== "") {
            /*
            read 2 path exists
            */
            output_fastq_list_row["read_2"] = {
                "class_": cwl_ts_auto_1.File_class.FILE,
                "path": read_2_path
            };
        }
        /*
        Append to row
        */
        output_array.push(output_fastq_list_row);
    }
    return output_array;
}
exports.get_fastq_list_rows_from_file = get_fastq_list_rows_from_file;
