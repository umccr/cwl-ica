"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var cwl_ts_auto_1 = require("cwl-ts-auto");
var get_bam_file_from_directory__1_0_1_1 = require("../get-bam-file-from-directory__1.0.1");
// Test the get bam file from directory
var INPUT_BAM_FILE_NAMEROOT = "footest";
var INPUT_BAM_FILE_NAMEEXT = ".bam";
var INPUT_BAM_FILE_BASENAME = INPUT_BAM_FILE_NAMEROOT + INPUT_BAM_FILE_NAMEEXT;
var INPUT_OUTPUT_DIRECTORY_LOCATION = "outputs/output-directory";
// When in the top directory
var INPUT_SHALLOW_LISTING = {
    class_: cwl_ts_auto_1.Directory_class.DIRECTORY,
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION),
    listing: [
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "index.html",
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/index.html")
        },
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "".concat(INPUT_BAM_FILE_BASENAME),
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_BAM_FILE_BASENAME)
        },
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "".concat(INPUT_BAM_FILE_BASENAME, ".bai"),
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_BAM_FILE_BASENAME, ".bai")
        },
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "logs.txt",
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/logs.txt")
        }
    ]
};
// When in a nested directory directory
var INPUT_NESTED_DIRECTORY_NAME = "nested-directory";
var INPUT_DEEP_LISTING = {
    class_: cwl_ts_auto_1.Directory_class.DIRECTORY,
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION),
    listing: [
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "index.html",
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/index.html")
        },
        {
            class_: cwl_ts_auto_1.Directory_class.DIRECTORY,
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME),
            listing: [
                {
                    class_: cwl_ts_auto_1.File_class.FILE,
                    basename: "".concat(INPUT_BAM_FILE_BASENAME),
                    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/").concat(INPUT_BAM_FILE_BASENAME)
                },
                {
                    class_: cwl_ts_auto_1.File_class.FILE,
                    basename: "".concat(INPUT_BAM_FILE_BASENAME, ".bai"),
                    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/").concat(INPUT_BAM_FILE_BASENAME, ".bai")
                },
                {
                    class_: cwl_ts_auto_1.File_class.FILE,
                    basename: "logs.txt",
                    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/logs.txt")
                }
            ]
        }
    ]
};
var EXPECTED_SHALLOW_LISTING_OUTPUT_BAM_FILE = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "".concat(INPUT_BAM_FILE_BASENAME),
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_BAM_FILE_BASENAME),
    secondaryFiles: [
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "".concat(INPUT_BAM_FILE_BASENAME, ".bai"),
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_BAM_FILE_BASENAME, ".bai")
        }
    ]
};
var EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "".concat(INPUT_BAM_FILE_BASENAME),
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/").concat(INPUT_BAM_FILE_BASENAME),
    secondaryFiles: [
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "".concat(INPUT_BAM_FILE_BASENAME, ".bai"),
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/").concat(INPUT_BAM_FILE_BASENAME, ".bai")
        }
    ]
};
describe('Test Shallow Directory Listing', function () {
    // Get script path
    test("Test the get bam file from directory function non-recursively", function () {
        expect((0, get_bam_file_from_directory__1_0_1_1.get_bam_file_from_directory)(INPUT_SHALLOW_LISTING, INPUT_BAM_FILE_NAMEROOT)).toMatchObject(EXPECTED_SHALLOW_LISTING_OUTPUT_BAM_FILE);
    });
});
describe('Test Deep Directory Listing', function () {
    // Get script path
    test("Test the deep listing function", function () {
        expect((0, get_bam_file_from_directory__1_0_1_1.get_bam_file_from_directory)(INPUT_DEEP_LISTING, INPUT_BAM_FILE_NAMEROOT, true)).toMatchObject(EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE);
    });
});
