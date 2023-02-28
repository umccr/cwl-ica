// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
import {
    Directory as IDirectory,
    File as IFile
} from "cwlts/mappings/v1.0";

import {get_bam_file_from_directory} from "../get-bam-file-from-directory__1.0.0";

// Test the get bam file from directory
const INPUT_BAM_FILE_NAMEROOT = "samplename"
const INPUT_BAM_FILE_NAMEEXT = ".bam"
const INPUT_BAM_FILE_BASENAME = INPUT_BAM_FILE_NAMEROOT + INPUT_BAM_FILE_NAMEEXT
const INPUT_OUTPUT_DIRECTORY_LOCATION = "output-directory"

const LISTED_BAM_FILE: IFile = {
    class: "File",
    basename: `${INPUT_BAM_FILE_BASENAME}`,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_BAM_FILE_BASENAME}`
}
const LISTED_BAM_INDEX_FILE: IFile = {
    class: "File",
    basename: `${INPUT_BAM_FILE_BASENAME}.bai`,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_BAM_FILE_BASENAME}.bai`
}

const INPUT_LISTING: IDirectory = {
    class: "Directory",
    basename: `${INPUT_OUTPUT_DIRECTORY_LOCATION}`,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}`,
    listing: [
        {
            class: "File",
            basename: "index.html",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/index.html`
        },
        LISTED_BAM_FILE,
        LISTED_BAM_INDEX_FILE
    ]
}

const EXPECTED_LISTING_OUTPUT_BAM_FILE: IFile = JSON.parse(JSON.stringify(LISTED_BAM_FILE))
EXPECTED_LISTING_OUTPUT_BAM_FILE.secondaryFiles = [
    LISTED_BAM_INDEX_FILE
]

// Dummy Test
describe('Test Directory Listing', function() {
    test('Test the get_bam_file_from_directory function', () => {
        expect(
            get_bam_file_from_directory(INPUT_LISTING, INPUT_BAM_FILE_BASENAME)
        ).toMatchObject(EXPECTED_LISTING_OUTPUT_BAM_FILE)
    })
})


