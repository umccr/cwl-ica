"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_bam_file_from_directory = void 0;
function get_bam_file_from_directory(input_dir, bam_nameroot, recursive) {
    if (recursive === void 0) { recursive = false; }
    /*
    Initialise the output file object
    */
    var output_bam_obj = null;
    var output_bam_index_obj = null;
    /*
    Check input_dir is a directory and has a listing
    */
    if (input_dir.class === undefined || input_dir.class !== "Directory") {
        throw new Error("Could not confirm that the first argument was a directory");
    }
    if (input_dir.listing === undefined || input_dir.listing === null) {
        throw new Error("Could not collect listing from directory \"".concat(input_dir.basename, "\""));
    }
    /*
    Check that the bam_nameroot input is defined
    */
    if (bam_nameroot === undefined || bam_nameroot === null) {
        throw new Error("Did not receive a name of a bam file");
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
        if (listing_item.class === "File" && listing_item.basename === bam_nameroot + ".bam") {
            /*
            Got the bam file
            */
            output_bam_obj = listing_item;
            break;
        }
        if (listing_item.class === "Directory" && recursive) {
            try {
                // Consider that the bam file might not be in this subdirectory and that is okay
                output_bam_obj = get_bam_file_from_directory(listing_item, bam_nameroot, recursive);
            }
            catch (error) {
                // Dont need to report an error though, just continue
            }
            if (output_bam_obj !== null) {
                break;
            }
        }
    }
    /*
    Iterate through the listing again and look for the secondary file
    */
    for (var _a = 0, input_listing_2 = input_listing; _a < input_listing_2.length; _a++) {
        var listing_item = input_listing_2[_a];
        if (listing_item.class === "File" && listing_item.basename === bam_nameroot + ".bam.bai") {
            /*
            Got the bam index file
            */
            output_bam_index_obj = listing_item;
            break;
        }
    }
    /*
    Ensure we found the bam object
    */
    if (output_bam_obj === null) {
        throw new Error("Could not find bam file in the directory ".concat(input_dir.basename));
    }
    /*
    Check the secondary file has been defined
    */
    if (output_bam_obj.secondaryFiles !== undefined) {
        // Picked up index object in the recursion step
    }
    else if (output_bam_index_obj === null) {
        throw new Error("Could not find secondary file in the directory ".concat(input_dir.basename));
    }
    else {
        /*
        Assign bam index as a secondary file of the output bam object
        */
        output_bam_obj.secondaryFiles = [
            output_bam_index_obj
        ];
    }
    return output_bam_obj;
}
exports.get_bam_file_from_directory = get_bam_file_from_directory;
