"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.find_files_in_directory_recursively_with_regex = exports.get_file_from_directory = void 0;
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
var cwl_ts_auto_1 = require("cwl-ts-auto");
// Functions
function get_file_from_directory(input_dir, file_basename, recursive) {
    if (recursive === void 0) { recursive = false; }
    /*
    Initialise the output file object
    */
    var output_file_obj = null;
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
    Check that the basename input is defined
    */
    if (file_basename === undefined || file_basename === null) {
        throw new Error("Did not receive a name of a file");
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
        if (listing_item.class_ === cwl_ts_auto_1.File_class.FILE && listing_item.basename === file_basename) {
            /*
            Got the file of interest
            */
            output_file_obj = listing_item;
            break;
        }
        if (listing_item.class_ === cwl_ts_auto_1.Directory_class.DIRECTORY && recursive) {
            var subdirectory_list = listing_item;
            try {
                // Consider that the file might not be in this subdirectory and that is okay
                output_file_obj = get_file_from_directory(subdirectory_list, file_basename, recursive);
            }
            catch (error) {
                // Dont need to report an error though, just continue
            }
            if (output_file_obj !== null) {
                break;
            }
        }
    }
    /*
    Ensure we found the file object
    */
    if (output_file_obj === null) {
        throw new Error("Could not find file in the directory ".concat(input_dir.basename));
    }
    // Return the output file object
    return output_file_obj;
}
exports.get_file_from_directory = get_file_from_directory;
// Find files in a directory
function find_files_in_directory_recursively_with_regex(input_dir, file_regex) {
    /*
    Initialise the output file object
    */
    var output_file_obj = [];
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
    for (var _i = 0, input_listing_2 = input_listing; _i < input_listing_2.length; _i++) {
        var listing_item = input_listing_2[_i];
        if (listing_item.class_ === cwl_ts_auto_1.File_class.FILE && file_regex.test(listing_item.basename)) {
            /*
            Got the file of interest and the file basename matches the file regex
            */
            output_file_obj.push(listing_item);
        }
        if (listing_item.class_ === cwl_ts_auto_1.Directory_class.DIRECTORY) {
            var subdirectory_list = listing_item;
            try {
                // Consider that the file might not be in this subdirectory and that is okay
                var subdirectory_files = find_files_in_directory_recursively_with_regex(subdirectory_list, file_regex);
                output_file_obj.push.apply(output_file_obj, subdirectory_files);
            }
            catch (error) {
                // Dont need to report an error though, just continue
            }
        }
    }
    // Return the output file object
    return output_file_obj;
}
exports.find_files_in_directory_recursively_with_regex = find_files_in_directory_recursively_with_regex;
