"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var get_bam_file_from_directory__1_0_0_1 = require("../get-bam-file-from-directory__1.0.0");
// Test the get bam file from directory
var INPUT_BAM_FILE_NAMEROOT = "samplename";
var INPUT_BAM_FILE_NAMEEXT = ".bam";
var INPUT_BAM_FILE_BASENAME = INPUT_BAM_FILE_NAMEROOT + INPUT_BAM_FILE_NAMEEXT;
var INPUT_OUTPUT_DIRECTORY_LOCATION = "output-directory";
var LISTED_BAM_FILE = {
    class: "File",
    basename: "".concat(INPUT_BAM_FILE_BASENAME),
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_BAM_FILE_BASENAME)
};
var LISTED_BAM_INDEX_FILE = {
    class: "File",
    basename: "".concat(INPUT_BAM_FILE_BASENAME, ".bai"),
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/").concat(INPUT_BAM_FILE_BASENAME, ".bai")
};
var INPUT_LISTING = {
    class: "Directory",
    basename: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION),
    location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION),
    listing: [
        {
            class: "File",
            basename: "index.html",
            location: "".concat(INPUT_OUTPUT_DIRECTORY_LOCATION, "/index.html")
        },
        LISTED_BAM_FILE,
        LISTED_BAM_INDEX_FILE
    ]
};
var EXPECTED_LISTING_OUTPUT_BAM_FILE = JSON.parse(JSON.stringify(LISTED_BAM_FILE));
EXPECTED_LISTING_OUTPUT_BAM_FILE.secondaryFiles = [
    LISTED_BAM_INDEX_FILE
];
// Dummy Test
describe('Test Directory Listing', function () {
    test('Test the get_bam_file_from_directory function', function () {
        expect((0, get_bam_file_from_directory__1_0_0_1.get_bam_file_from_directory)(INPUT_LISTING, INPUT_BAM_FILE_BASENAME)).toMatchObject(EXPECTED_LISTING_OUTPUT_BAM_FILE);
    });
});
