"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
Object.defineProperty(exports, "__esModule", { value: true });
// Standard typescript imports
var fs_1 = require("fs");
var cwl_ts_auto_1 = require("cwl-ts-auto");
var get_fastq_list_rows_from_fastq_list_csv__1_0_0_1 = require("../get-fastq-list-rows-from-fastq-list-csv__1.0.0");
var FASTQ_LIST_CSV_FILE_OUTPUT_FILE_PATH = "tests/data/fastq_list.csv";
var FASTQ_LIST_CSV_OUTPUT_FILE = {
    "class_": cwl_ts_auto_1.File_class.FILE,
    basename: "fastq_list.csv",
    location: FASTQ_LIST_CSV_FILE_OUTPUT_FILE_PATH,
    contents: (0, fs_1.readFileSync)(FASTQ_LIST_CSV_FILE_OUTPUT_FILE_PATH, "utf8")
};
var EXPECTED_OUTPUT_FASTQ_LIST_ROWS = [
    {
        rgid: "AAAAAAAA.CCCCCCCC.4.MY_RUN_ID.MY_SAMPLE_ID",
        rgsm: "MY_SAMPLE_ID",
        rglb: "MY_LIBRARY_ID",
        lane: 4,
        read_1: {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "path": "My_Sample_Project/MY_SAMPLE_ID_L004_R1_001.fastq.gz"
        },
        read_2: {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "path": "My_Sample_Project/MY_SAMPLE_ID_L004_R2_001.fastq.gz"
        }
    },
    {
        rgid: "AAAAAAAA.CCCCCCCC.2.MY_RUN_ID.MY_SAMPLE_ID",
        rgsm: "MY_SAMPLE_ID",
        rglb: "MY_LIBRARY_ID",
        lane: 2,
        read_1: {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "path": "My_Sample_Project/MY_SAMPLE_ID_L002_R1_001.fastq.gz"
        },
        read_2: {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "path": "My_Sample_Project/MY_SAMPLE_ID_L002_R2_001.fastq.gz"
        }
    }
];
describe('Test get fastq list row from csv', function () {
    var fastq_list_rows = (0, get_fastq_list_rows_from_fastq_list_csv__1_0_0_1.get_fastq_list_rows_from_file)(FASTQ_LIST_CSV_OUTPUT_FILE);
    test("Test Get Fastq List Row", function () {
        expect(fastq_list_rows).toMatchObject(EXPECTED_OUTPUT_FASTQ_LIST_ROWS);
    });
});
