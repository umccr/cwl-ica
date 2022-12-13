// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript

// Standard typescript imports
import {readFileSync} from 'fs';

// Test get_fastq_list_row_from_file
import {FastqListRow} from "../../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0";
import {File_class, FileProperties as IFile} from "cwl-ts-auto";

import {get_fastq_list_rows_from_file} from "../get-fastq-list-rows-from-fastq-list-csv__1.0.0"

const FASTQ_LIST_CSV_FILE_OUTPUT_FILE_PATH = "tests/data/fastq_list.csv"
const FASTQ_LIST_CSV_OUTPUT_FILE: IFile = {
    "class_": File_class.FILE,
    basename: "fastq_list.csv",
    location: FASTQ_LIST_CSV_FILE_OUTPUT_FILE_PATH,
    contents: readFileSync(FASTQ_LIST_CSV_FILE_OUTPUT_FILE_PATH, "utf8")
}

const EXPECTED_OUTPUT_FASTQ_LIST_ROWS: Array<FastqListRow> = [
    {
        rgid: "AAAAAAAA.CCCCCCCC.4.MY_RUN_ID.MY_SAMPLE_ID",
        rgsm: "MY_SAMPLE_ID",
        rglb: "MY_LIBRARY_ID",
        lane: 4,
        read_1: {
            "class_": File_class.FILE,
            "path": "My_Sample_Project/MY_SAMPLE_ID_L004_R1_001.fastq.gz"
        },
        read_2: {
            "class_": File_class.FILE,
            "path": "My_Sample_Project/MY_SAMPLE_ID_L004_R2_001.fastq.gz"
        }
    },
    {
        rgid: "AAAAAAAA.CCCCCCCC.2.MY_RUN_ID.MY_SAMPLE_ID",
        rgsm: "MY_SAMPLE_ID",
        rglb: "MY_LIBRARY_ID",
        lane: 2,
        read_1: {
            "class_": File_class.FILE,
            "path": "My_Sample_Project/MY_SAMPLE_ID_L002_R1_001.fastq.gz"
        },
        read_2: {
            "class_": File_class.FILE,
            "path": "My_Sample_Project/MY_SAMPLE_ID_L002_R2_001.fastq.gz"
        }
    }
]

describe('Test get fastq list row from csv', function () {
    const fastq_list_rows: Array<FastqListRow> = get_fastq_list_rows_from_file(
        FASTQ_LIST_CSV_OUTPUT_FILE
    )

    test("Test Get Fastq List Row", () => {
        expect(
            fastq_list_rows
        ).toMatchObject(
            EXPECTED_OUTPUT_FASTQ_LIST_ROWS
        )
    })
});