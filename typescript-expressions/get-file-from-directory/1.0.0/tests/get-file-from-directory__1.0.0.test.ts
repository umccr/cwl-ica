// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
import {Directory_class, DirectoryProperties as IDirectory, File_class, FileProperties as IFile} from "cwl-ts-auto";
import {get_file_from_directory} from "../get-file-from-directory__1.0.0";

// Test the get bam file from directory
const INPUT_FILE_NAMEROOT = "footest"
const INPUT_FILE_NAMEEXT = ".txt"
const INPUT_FILE_BASENAME = INPUT_FILE_NAMEROOT + INPUT_FILE_NAMEEXT
const INPUT_OUTPUT_DIRECTORY_LOCATION = "outputs/output-directory"

// When in the top directory
const INPUT_SHALLOW_LISTING: IDirectory = {
    class_: Directory_class.DIRECTORY,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}`,
    listing: [
        {
            class_: File_class.FILE,
            basename: "index.html",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/index.html`
        },
        {
            class_: File_class.FILE,
            basename: `${INPUT_FILE_BASENAME}`,
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_FILE_BASENAME}`
        },
        {
            class_: File_class.FILE,
            basename: `${INPUT_FILE_BASENAME}.bai`,
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_FILE_BASENAME}.bai`
        },
        {
            class_: File_class.FILE,
            basename: "logs.txt",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/logs.txt`
        },
    ]
}

// When in a nested directory directory
const INPUT_NESTED_DIRECTORY_NAME = "nested-directory";

const INPUT_DEEP_LISTING: IDirectory = {
    class_: Directory_class.DIRECTORY,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}`,
    listing: [
        {
            class_: File_class.FILE,
            basename: "index.html",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/index.html`
        },
        {
            class_: Directory_class.DIRECTORY,
            basename: "nested-directory",
            location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}`,
            listing: [
                {
                    class_: File_class.FILE,
                    basename: `${INPUT_FILE_BASENAME}`,
                    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/${INPUT_FILE_BASENAME}`
                },
                {
                    class_: File_class.FILE,
                    basename: `${INPUT_FILE_BASENAME}.bai`,
                    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/${INPUT_FILE_BASENAME}.bai`
                },
                {
                    class_: File_class.FILE,
                    basename: "logs.txt",
                    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/logs.txt`
                }
            ]
        }
    ]
}


const EXPECTED_SHALLOW_LISTING_OUTPUT_BAM_FILE: IFile = {
    class_: File_class.FILE,
    basename: `${INPUT_FILE_BASENAME}`,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_FILE_BASENAME}`
}

const EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE: IFile = {
    class_: File_class.FILE,
    basename: `${INPUT_FILE_BASENAME}`,
    location: `${INPUT_OUTPUT_DIRECTORY_LOCATION}/${INPUT_NESTED_DIRECTORY_NAME}/${INPUT_FILE_BASENAME}`
}


describe('Test Shallow Directory Listing', function () {
    // Get script path
    test("Test the get bam file from directory function non-recursively", () => {
        expect(
            get_file_from_directory(INPUT_SHALLOW_LISTING, INPUT_FILE_BASENAME)
        ).toMatchObject(EXPECTED_SHALLOW_LISTING_OUTPUT_BAM_FILE)
    })
});

describe('Test Deep Directory Listing', function () {
    // Get script path
    test("Test the deep listing function", () => {
        expect(
            get_file_from_directory(INPUT_DEEP_LISTING, INPUT_FILE_BASENAME, true)
        ).toMatchObject(EXPECTED_DEEP_LISTING_OUTPUT_BAM_FILE)
    })
});