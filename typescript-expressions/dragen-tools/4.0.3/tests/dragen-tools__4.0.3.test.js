"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
Object.defineProperty(exports, "__esModule", { value: true });
// Imports
var cwl_ts_auto_1 = require("cwl-ts-auto");
var fs_1 = require("fs");
var dragen_tools__4_0_3_1 = require("../dragen-tools__4.0.3");
var NORMAL_BAM_INPUT_FILE = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "MY_SAMPLE_ID.bam",
    nameroot: "MY_SAMPLE_ID"
};
var NORMAL_BAM_INPUT_FILE_WITH_NORMAL_SUFFIX = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "MY_SAMPLE_ID_normal.bam",
    nameroot: "MY_SAMPLE_ID_normal"
};
var FASTQ_LIST_CSV_FILE_PATH = "tests/data/fastq_list.csv";
var FASTQ_LIST_REORDERED_CSV_FILE_PATH = "tests/data/fastq_list.reordered.csv";
var TUMOR_FASTQ_LIST_CSV_FILE_PATH = "tests/data/tumor_fastq_list.csv";
var ORA_FASTQ_LIST_CSV_FILE_PATH = "tests/data/fastq_list.ora.csv";
var MV_ORA_FILE_PATH = "tests/data/mv-ora.sh";
var GENERATE_NEW_FASTQ_LIST_CSV_SH_PATH = "tests/data/generate-new-fastq-list-csv.sh";
var GENERATE_MD5SUM_FOR_FASTQ_GZ_FILES_SH_PATH = "tests/data/generate-md5sum-for-fastq-gz-files.sh";
var GENERATE_MD5SUM_FOR_FASTQ_ORA_FILES_SH_PATH = "tests/data/generate-md5sum-for-fastq-ora-files.sh";
var GENERATE_FILE_SIZES_FOR_FASTQ_GZ_FILES_SH_PATH = "tests/data/generate-file-sizes-for-fastq-gz-files.sh";
var FASTQ_LIST_CSV_FILE = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "fastq_list.csv",
    location: FASTQ_LIST_CSV_FILE_PATH,
    contents: (0, fs_1.readFileSync)(FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
var FASTQ_LIST_REORDERED_CSV_FILE = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "fastq_list.csv",
    location: FASTQ_LIST_REORDERED_CSV_FILE_PATH,
    contents: (0, fs_1.readFileSync)(FASTQ_LIST_REORDERED_CSV_FILE_PATH, "utf8")
};
var TUMOR_CSV_FILE = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "fastq_list.csv",
    location: TUMOR_FASTQ_LIST_CSV_FILE_PATH,
    contents: (0, fs_1.readFileSync)(TUMOR_FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
var FASTQ_LIST_ROWS = [
    {
        "rgid": "AAAAAAAA.CCCCCCCC.4.MY_RUN_ID.MY_SAMPLE_ID",
        "rglb": "MY_LIBRARY_ID",
        "rgsm": "MY_SAMPLE_ID",
        "lane": 4,
        "read_1": {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "location": "data/MY_SAMPLE_ID_L004_R1_001.fastq.gz"
        },
        "read_2": {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "location": "data/MY_SAMPLE_ID_L004_R2_001.fastq.gz"
        }
    },
    {
        "rgid": "AAAAAAAA.CCCCCCCC.2.MY_RUN_ID.MY_SAMPLE_ID",
        "rglb": "MY_LIBRARY_ID",
        "lane": 2,
        "rgsm": "MY_SAMPLE_ID",
        "read_1": {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "location": "data/MY_SAMPLE_ID_L002_R1_001.fastq.gz"
        },
        "read_2": {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "location": "data/MY_SAMPLE_ID_L002_R2_001.fastq.gz"
        }
    }
];
var EXPECTED_FASTQ_LIST_CSV_OUTPUT = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "fastq_list.csv",
    contents: (0, fs_1.readFileSync)(FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
var TUMOR_FASTQ_LIST_ROWS = [
    {
        "rgid": "TTTTTTTT.GGGGGGGG.4.MY_RUN_ID.MY_TUMOR_SAMPLE_ID",
        "rglb": "MY_TUMOR_LIBRARY_ID",
        "rgsm": "MY_TUMOR_SAMPLE_ID",
        "lane": 4,
        "read_1": {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "location": "data/MY_TUMOR_SAMPLE_ID_L004_R1_001.fastq.gz"
        },
        "read_2": {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "location": "data/MY_TUMOR_SAMPLE_ID_L004_R2_001.fastq.gz"
        }
    },
    {
        "rgid": "TTTTTTTT.GGGGGGGG.2.MY_RUN_ID.MY_TUMOR_SAMPLE_ID",
        "rglb": "MY_TUMOR_LIBRARY_ID",
        "lane": 2,
        "rgsm": "MY_TUMOR_SAMPLE_ID",
        "read_1": {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "location": "data/MY_TUMOR_SAMPLE_ID_L002_R1_001.fastq.gz"
        },
        "read_2": {
            "class_": cwl_ts_auto_1.File_class.FILE,
            "location": "data/MY_TUMOR_SAMPLE_ID_L002_R2_001.fastq.gz"
        }
    }
];
var EXPECTED_TUMOR_FASTQ_LIST_CSV_OUTPUT = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "fastq_list.csv",
    contents: (0, fs_1.readFileSync)(TUMOR_FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
var HEADER_NAMES = [
    "rglb",
    "rgid",
    "rgsm",
    "read_1",
    "read_2"
];
var EXPECTED_OUTPUT_HEADER_NAMES = "RGLB,RGID,RGSM,Read1File,Read2File";
var MOUNT_POINTS_FASTQ_LIST_ROWS_INPUT = {
    fastq_list_rows: FASTQ_LIST_ROWS,
    tumor_fastq_list_rows: TUMOR_FASTQ_LIST_ROWS,
    fastq_list: null,
    tumor_fastq_list: null
};
var MOUNT_POINTS_FASTQ_LIST_CSV_INPUT = {
    fastq_list_rows: null,
    tumor_fastq_list_rows: null,
    fastq_list: FASTQ_LIST_CSV_FILE,
    tumor_fastq_list: TUMOR_CSV_FILE
};
var ORA_RUN_DIRECTORY = {
    class_: cwl_ts_auto_1.Directory_class.DIRECTORY,
    location: "data",
    path: "data",
    basename: "data",
    listing: [
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "MY_SAMPLE_ID_L002_R1_001.fastq.gz",
            path: "data/MY_SAMPLE_ID_L002_R1_001.fastq.gz",
            location: "data/MY_SAMPLE_ID_L002_R1_001.fastq.gz"
        },
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "MY_SAMPLE_ID_L002_R2_001.fastq.gz",
            path: "data/MY_SAMPLE_ID_L002_R2_001.fastq.gz",
            location: "data/MY_SAMPLE_ID_L002_R2_001.fastq.gz"
        },
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "MY_SAMPLE_ID_L004_R1_001.fastq.gz",
            path: "data/MY_SAMPLE_ID_L004_R1_001.fastq.gz",
            location: "data/MY_SAMPLE_ID_L004_R1_001.fastq.gz"
        },
        {
            class_: cwl_ts_auto_1.File_class.FILE,
            basename: "MY_SAMPLE_ID_L004_R2_001.fastq.gz",
            path: "data/MY_SAMPLE_ID_L004_R2_001.fastq.gz",
            location: "data/MY_SAMPLE_ID_L004_R2_001.fastq.gz"
        },
    ]
};
var EXPECTED_ORA_FASTQ_LIST_CSV_OUTPUT = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "fastq_list.csv",
    contents: (0, fs_1.readFileSync)(ORA_FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
var EXPECTED_ORA_MV_SH_OUTPUT = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "mv-ora-output-files.sh",
    contents: (0, fs_1.readFileSync)(MV_ORA_FILE_PATH, "utf8")
};
var EXPECTED_ORA_NEW_FASTQ_LIST_CSV_SH_OUTPUT = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "generate-new-fastq-list-csv.sh",
    contents: (0, fs_1.readFileSync)(GENERATE_NEW_FASTQ_LIST_CSV_SH_PATH, "utf8")
};
var EXPECTED_MD5SUM_FOR_FASTQ_GZ_FILES_SH_OUTPUT = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "generate-md5sum-for-fastq-gz-files.sh",
    contents: (0, fs_1.readFileSync)(GENERATE_MD5SUM_FOR_FASTQ_GZ_FILES_SH_PATH, "utf8")
};
var EXPECTED_MD5SUM_FOR_FASTQ_ORA_FILES_SH_OUTPUT = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "generate-md5sum-for-fastq-ora-files.sh",
    contents: (0, fs_1.readFileSync)(GENERATE_MD5SUM_FOR_FASTQ_ORA_FILES_SH_PATH, "utf8")
};
var EXPECTED_FILE_SIZES_FOR_FASTQ_GZ_FILES_SH_OUTPUT = {
    class_: cwl_ts_auto_1.File_class.FILE,
    basename: "generate-file-sizes-for-fastq-gz-files.sh",
    contents: (0, fs_1.readFileSync)(GENERATE_FILE_SIZES_FOR_FASTQ_GZ_FILES_SH_PATH, "utf8")
};
describe('Test Simple Functions', function () {
    // Simple expected outputs
    var expected_get_script_path_output = "run-dragen-script.sh";
    var expected_get_fastq_list_csv_path_output = "fastq_list.csv";
    var expected_get_tumor_fastq_list_csv_path_output = "tumor_fastq_list.csv";
    // Get script path
    test("Test the get script path function", function () {
        expect((0, dragen_tools__4_0_3_1.get_script_path)()).toEqual(expected_get_script_path_output);
    });
    test("Test the get fastq list csv path function", function () {
        expect((0, dragen_tools__4_0_3_1.get_fastq_list_csv_path)()).toEqual(expected_get_fastq_list_csv_path_output);
    });
    test("Test the get tumor fastq list csv path function", function () {
        expect((0, dragen_tools__4_0_3_1.get_tumor_fastq_list_csv_path)()).toEqual(expected_get_tumor_fastq_list_csv_path_output);
    });
});
// Get normal names import
describe('Test the get normal name function suite', function () {
    var expected_rgsm_value = "MY_SAMPLE_ID";
    var fastq_list_as_input = {
        "fastq_list_rows": null,
        "fastq_list": FASTQ_LIST_CSV_FILE,
        "bam_input": null,
        "cram_input": null
    };
    var fastq_list_rows_as_input = {
        "fastq_list_rows": FASTQ_LIST_ROWS,
        "fastq_list": null,
        "bam_input": null,
        "cram_input": null
    };
    var bam_input_as_input = {
        "fastq_list_rows": null,
        "fastq_list": null,
        "bam_input": NORMAL_BAM_INPUT_FILE,
        "cram_input": null
    };
    var bam_with_normal_as_input = {
        "fastq_list_rows": null,
        "fastq_list": null,
        "bam_input": NORMAL_BAM_INPUT_FILE_WITH_NORMAL_SUFFIX,
        "cram_input": null
    };
    /*
    Testing from file
    */
    test("Test collecting normal name from the fastq list csv", function () {
        expect((0, dragen_tools__4_0_3_1.get_normal_name_from_fastq_list_csv)(FASTQ_LIST_CSV_FILE)).toEqual(expected_rgsm_value);
    });
    test("Test collecting normal name from the reordered fastq list csv", function () {
        expect((0, dragen_tools__4_0_3_1.get_normal_name_from_fastq_list_csv)(FASTQ_LIST_REORDERED_CSV_FILE)).toEqual(expected_rgsm_value);
    });
    test("Test the get normal output prefix function with fastq list rows as non null", function () {
        expect((0, dragen_tools__4_0_3_1.get_normal_output_prefix)(fastq_list_as_input)).toEqual(expected_rgsm_value + "_normal");
    });
    /*
    Testing from schema
    */
    test("Test collecting normal name from the fastq list rows csv", function () {
        expect((0, dragen_tools__4_0_3_1.get_normal_name_from_fastq_list_rows)(FASTQ_LIST_ROWS)).toEqual(expected_rgsm_value);
    });
    test("Test the get normal output prefix function with fastq list rows as non null", function () {
        expect((0, dragen_tools__4_0_3_1.get_normal_output_prefix)(fastq_list_rows_as_input)).toEqual(expected_rgsm_value + "_normal");
    });
    /*
    Test from bam input
    */
    test("Test the get_normal_output prefix function with bam input as non null", function () {
        expect((0, dragen_tools__4_0_3_1.get_normal_output_prefix)(bam_input_as_input)).toEqual(expected_rgsm_value + "_normal");
    });
    /*
    Test bam input with normal suffix (should be the same as above)
    */
    test("Test the get_normal_output prefix function with bam input as non null", function () {
        expect((0, dragen_tools__4_0_3_1.get_normal_output_prefix)(bam_with_normal_as_input)).toEqual(expected_rgsm_value + "_normal");
    });
});
// Test the fastq list csv builders
describe('Test the fastq list csv builder functions', function () {
    var expected_fastq_list_row_output = [
        "AAAAAAAA.CCCCCCCC.4.MY_RUN_ID.MY_SAMPLE_ID",
        "MY_LIBRARY_ID",
        "MY_SAMPLE_ID",
        "4",
        "data/MY_SAMPLE_ID_L004_R1_001.fastq.gz",
        "data/MY_SAMPLE_ID_L004_R2_001.fastq.gz" // read 2 file location
    ].join(",") + "\n";
    /*
    Header builder test
    */
    test("Build the fastq list csv header test", function () {
        expect((0, dragen_tools__4_0_3_1.build_fastq_list_csv_header)(HEADER_NAMES)).toEqual(EXPECTED_OUTPUT_HEADER_NAMES + "\n");
    });
    /*
    Get the fastq list row as a csv row test
    */
    test("Create a single row of fastq list test", function () {
        expect((0, dragen_tools__4_0_3_1.get_fastq_list_row_as_csv_row)(FASTQ_LIST_ROWS[0], Object.getOwnPropertyNames(FASTQ_LIST_ROWS[0]))).toEqual(expected_fastq_list_row_output);
    });
    /*
    Generate fastq list csv test
    */
    test("Test generated of the fastq list csv file", function () {
        expect((0, dragen_tools__4_0_3_1.generate_fastq_list_csv)(FASTQ_LIST_ROWS)).toEqual(EXPECTED_FASTQ_LIST_CSV_OUTPUT);
    });
});
describe('Test generate mount points', function () {
    var expected_mount_points_object = [
        {
            "entryname": "fastq_list.csv",
            "entry": EXPECTED_FASTQ_LIST_CSV_OUTPUT
        },
        {
            "entryname": "tumor_fastq_list.csv",
            "entry": EXPECTED_TUMOR_FASTQ_LIST_CSV_OUTPUT
        }
    ];
    var fastq_list_row_mount_points = (0, dragen_tools__4_0_3_1.generate_somatic_mount_points)(MOUNT_POINTS_FASTQ_LIST_ROWS_INPUT);
    var fastq_list_csv_mount_points = (0, dragen_tools__4_0_3_1.generate_somatic_mount_points)(MOUNT_POINTS_FASTQ_LIST_CSV_INPUT);
    test("Test the generate mount points of the tumor and normal fastq list rows", function () {
        expect(fastq_list_row_mount_points).toMatchObject(expected_mount_points_object);
    });
    test("Test the generate mount points of the tumor and normal fastq list csv", function () {
        expect(fastq_list_csv_mount_points).toMatchObject(expected_mount_points_object);
    });
});
describe('Test ora mount points', function () {
    var expected_mount_points_object = [
        {
            "entryname": "fastq_list.csv",
            "entry": EXPECTED_ORA_FASTQ_LIST_CSV_OUTPUT
        },
        {
            "entryname": "mv-ora-output-files.sh",
            "entry": EXPECTED_ORA_MV_SH_OUTPUT
        },
        {
            "entryname": "generate-new-fastq-list-csv.sh",
            "entry": EXPECTED_ORA_NEW_FASTQ_LIST_CSV_SH_OUTPUT
        },
        {
            "entryname": "generate-md5sum-for-fastq-gz-files.sh",
            "entry": EXPECTED_MD5SUM_FOR_FASTQ_GZ_FILES_SH_OUTPUT
        },
        {
            "entryname": "generate-file-sizes-for-fastq-gz-files.sh",
            "entry": EXPECTED_FILE_SIZES_FOR_FASTQ_GZ_FILES_SH_OUTPUT
        },
        {
            "entryname": "generate-md5sum-for-fastq-ora-files.sh",
            "entry": EXPECTED_MD5SUM_FOR_FASTQ_ORA_FILES_SH_OUTPUT
        }
    ];
    var fastq_list_csv_mount_points = (0, dragen_tools__4_0_3_1.generate_ora_mount_points)(ORA_RUN_DIRECTORY, "output-directory-path");
    test("Test the generate mount points of the tumor and normal fastq list rows", function () {
        expect(fastq_list_csv_mount_points).toMatchObject(expected_mount_points_object);
    });
});
