import {
    Directory as IDirectory,
    File as IFile
} from "cwlts/mappings/v1.0";

import {get_bam_file_from_directory} from "../get-bam-file-from-directory__1.0.1-rabix";

// Test the get bam file from directory
const INPUT_BAM_FILE_NAMEROOT = "footest"
const INPUT_BAM_FILE_NAMEEXT = ".bam"
const INPUT_BAM_FILE_BASENAME = INPUT_BAM_FILE_NAMEROOT + INPUT_BAM_FILE_NAMEEXT
const INPUT_OUTPUT_DIRECTORY_LOCATION = "outputs/output-directory"

// When in the top directory
const INPUT_SHALLOW_LISTING: IDirectory = {
    class: "Directory",
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}`,
    listing: [
        {
            class: "File",
            basename: "index.html",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/index.html`
        },
        {
            class: "File",
            basename: `${INPUT_BAM_FILE_BASENAME}`,
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_BAM_FILE_BASENAME}`
        },
        {
            class: "File",
            basename: `${INPUT_BAM_FILE_BASENAME}.bai`,
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_BAM_FILE_BASENAME}.bai`
        },
        {
            class: "File",
            basename: "logs.txt",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/logs.txt`
        }
    ]
}

// When in a nested directory directory
const INPUT_NESTED_DIRECTORY_NAME = "nested-directory";
const INPUT_DEEP_LISTING: IDirectory = {
    class: "Directory",
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}`,
    listing: [
        {
            class: "File",
            basename: "index.html",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/index.html`
        },
        {
            class: "Directory",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}`,
            listing: [
                {
                    class: "File",
                    basename: `${INPUT_BAM_FILE_BASENAME}`,
                    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/${INPUT_BAM_FILE_BASENAME}`
                },
                {
                    class: "File",
                    basename: `${INPUT_BAM_FILE_BASENAME}.bai`,
                    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/${INPUT_BAM_FILE_BASENAME}.bai`
                },
                {
                    class: "File",
                    basename: "logs.txt",
                    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/logs.txt`
                }
            ]
        }
    ]
}


const EXPECTED_SHALLOW_LISTING_OUTPUT_BAM_FILE: IFile = {
    class: "File",
    basename: `${INPUT_BAM_FILE_BASENAME}`,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_BAM_FILE_BASENAME}`,
    secondaryFiles: [
        {
            class: "File",
            basename: `${INPUT_BAM_FILE_BASENAME}.bai`,
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_BAM_FILE_BASENAME}.bai`
        }
    ]
}

const EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE: IFile = {
    class: "File",
    basename: `${INPUT_BAM_FILE_BASENAME}`,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/${INPUT_BAM_FILE_BASENAME}`,
    secondaryFiles: [
        {
            class: "File",
            basename: `${INPUT_BAM_FILE_BASENAME}.bai`,
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/${INPUT_BAM_FILE_BASENAME}.bai`
        }
    ]
}

describe('Test Shallow Directory Listing', function () {
    // Get script path
    test("Test the get bam file from directory function non-recursively", () => {
        expect(
            get_bam_file_from_directory(INPUT_SHALLOW_LISTING, INPUT_BAM_FILE_NAMEROOT)
        ).toMatchObject(EXPECTED_SHALLOW_LISTING_OUTPUT_BAM_FILE)
    })
});

describe('Test Deep Directory Listing', function () {
    // Get script path
    test("Test the deep listing function", () => {
        expect(
            get_bam_file_from_directory(INPUT_DEEP_LISTING, INPUT_BAM_FILE_NAMEROOT, true)
        ).toMatchObject(EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE)
    })
});