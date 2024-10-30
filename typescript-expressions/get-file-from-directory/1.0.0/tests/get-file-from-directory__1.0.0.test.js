"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
var cwl_ts_auto_1 = require("cwl-ts-auto");
var get_file_from_directory__1_0_0_1 = require("../get-file-from-directory__1.0.0");
// Test the get bam file from directory
var INPUT_FILE_NAMEROOT = "footest";
var INPUT_FILE_NAMEEXT = ".txt";
var INPUT_FILE_BASENAME = INPUT_FILE_NAMEROOT + INPUT_FILE_NAMEEXT;
var INPUT_OUTPUT_DIRECTORY_LOCATION = "outputs/output-directory";
// When in the top directory
// @ts-ignore
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
            basename: "".concat(INPUT_FILE_BASENAME),
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_FILE_BASENAME)
        },
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "".concat(INPUT_FILE_BASENAME, ".bai"),
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_FILE_BASENAME, ".bai")
        },
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "logs.txt",
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/logs.txt")
        },
    ]
};
// When in a nested directory directory
var INPUT_NESTED_DIRECTORY_NAME = "nested-directory";
// @ts-ignore
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
            basename: "nested-directory",
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME),
            listing: [
                {
                    class_: cwl_ts_auto_1.File_class.FILE,
                    basename: "".concat(INPUT_FILE_BASENAME),
                    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/").concat(INPUT_FILE_BASENAME)
                },
                {
                    class_: cwl_ts_auto_1.File_class.FILE,
                    basename: "".concat(INPUT_FILE_BASENAME, ".bai"),
                    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/").concat(INPUT_FILE_BASENAME, ".bai")
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
    basename: "".concat(INPUT_FILE_BASENAME),
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_FILE_BASENAME)
};
var EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "".concat(INPUT_FILE_BASENAME),
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/").concat(INPUT_FILE_BASENAME)
};
describe('Test Shallow Directory Listing', function () {
    // Get script path
    test("Test the get bam file from directory function non-recursively", function () {
        expect((0, get_file_from_directory__1_0_0_1.get_file_from_directory)(INPUT_SHALLOW_LISTING, INPUT_FILE_BASENAME)).toMatchObject(EXPECTED_SHALLOW_LISTING_OUTPUT_BAM_FILE);
    });
});
describe('Test Deep Directory Listing', function () {
    // Get script path
    test("Test the deep listing function", function () {
        expect((0, get_file_from_directory__1_0_0_1.get_file_from_directory)(INPUT_DEEP_LISTING, INPUT_FILE_BASENAME, true)).toMatchObject(EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE);
    });
});
describe('Test Deep Directory Regex', function () {
    // Get script path
    test("Test the deep regex function", function () {
        expect((0, get_file_from_directory__1_0_0_1.find_files_in_directory_recursively_with_regex)(INPUT_DEEP_LISTING, /\.txt$/g)).toMatchObject([
            EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE,
            {
                class_: cwl_ts_auto_1.File_class.FILE,
                basename: "logs.txt",
                location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_NESTED_DIRECTORY_NAME, "/logs.txt")
            }
        ]);
    });
});
