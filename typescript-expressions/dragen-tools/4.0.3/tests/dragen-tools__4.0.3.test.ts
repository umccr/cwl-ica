// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript

// Imports
import {File_class, FileProperties as IFile, DirentProperties as IDirectory, Directory_class} from "cwl-ts-auto";

import {readFileSync} from "fs";

import {FastqListRow} from "../../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0";

import {
    build_fastq_list_csv_header,
    generate_fastq_list_csv, generate_ora_mount_points,
    generate_somatic_mount_points,
    get_fastq_list_csv_path,
    get_fastq_list_row_as_csv_row,
    get_normal_name_from_fastq_list_csv,
    get_normal_name_from_fastq_list_rows,
    get_normal_output_prefix,
    get_script_path,
    get_tumor_fastq_list_csv_path
} from "../dragen-tools__4.0.3";

const NORMAL_BAM_INPUT_FILE: IFile = {
    class_: File_class.FILE,
    basename: "MY_SAMPLE_ID.bam",
    nameroot: "MY_SAMPLE_ID"
}

const NORMAL_BAM_INPUT_FILE_WITH_NORMAL_SUFFIX: IFile = {
    class_: File_class.FILE,
    basename: "MY_SAMPLE_ID_normal.bam",
    nameroot: "MY_SAMPLE_ID_normal"
}

const FASTQ_LIST_CSV_FILE_PATH = "tests/data/fastq_list.csv"
const FASTQ_LIST_REORDERED_CSV_FILE_PATH = "tests/data/fastq_list.reordered.csv";
const TUMOR_FASTQ_LIST_CSV_FILE_PATH = "tests/data/tumor_fastq_list.csv";
const ORA_FASTQ_LIST_CSV_FILE_PATH = "tests/data/fastq_list.ora.csv"
const MV_ORA_FILE_PATH = "tests/data/mv-ora.sh"
const GENERATE_NEW_FASTQ_LIST_CSV_SH_PATH = "tests/data/generate-new-fastq-list-csv.sh"
const GENERATE_MD5SUM_FOR_FASTQ_GZ_FILES_SH_PATH = "tests/data/generate-md5sum-for-fastq-raw-files.sh"
const GENERATE_MD5SUM_FOR_FASTQ_ORA_FILES_SH_PATH = "tests/data/generate-md5sum-for-fastq-ora-files.sh"
const GENERATE_FILE_SIZES_FOR_FASTQ_GZ_FILES_SH_PATH = "tests/data/generate-file-sizes-for-fastq-gz-files.sh"
const GENERATE_FILE_SIZES_FOR_FASTQ_ORA_FILES_SH_PATH = "tests/data/generate-file-sizes-for-fastq-ora-files.sh"

const FASTQ_LIST_CSV_FILE: IFile = {
    class_: File_class.FILE,
    basename: "fastq_list.csv",
    location: FASTQ_LIST_CSV_FILE_PATH,
    contents: readFileSync(FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
const FASTQ_LIST_REORDERED_CSV_FILE: IFile = {
    class_: File_class.FILE,
    basename: "fastq_list.csv",
    location: FASTQ_LIST_REORDERED_CSV_FILE_PATH,
    contents: readFileSync(FASTQ_LIST_REORDERED_CSV_FILE_PATH, "utf8")
};
const TUMOR_CSV_FILE: IFile = {
    class_: File_class.FILE,
    basename: "fastq_list.csv",
    location: TUMOR_FASTQ_LIST_CSV_FILE_PATH,
    contents: readFileSync(TUMOR_FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
const FASTQ_LIST_ROWS: Array<FastqListRow> = [
    {
        "rgid": "AAAAAAAA.CCCCCCCC.4.MY_RUN_ID.MY_SAMPLE_ID",
        "rglb": "MY_LIBRARY_ID",
        "rgsm": "MY_SAMPLE_ID",
        "lane": 4,
        "read_1": {
            "class_": File_class.FILE,
            "location": "data/MY_SAMPLE_ID_L004_R1_001.fastq.gz"
        },
        "read_2": {
            "class_": File_class.FILE,
            "location": "data/MY_SAMPLE_ID_L004_R2_001.fastq.gz"
        }
    },
    {
        "rgid": "AAAAAAAA.CCCCCCCC.2.MY_RUN_ID.MY_SAMPLE_ID",
        "rglb": "MY_LIBRARY_ID",
        "lane": 2,
        "rgsm": "MY_SAMPLE_ID",
        "read_1": {
            "class_": File_class.FILE,
            "location": "data/MY_SAMPLE_ID_L002_R1_001.fastq.gz"
        },
        "read_2": {
            "class_": File_class.FILE,
            "location": "data/MY_SAMPLE_ID_L002_R2_001.fastq.gz"
        }
    }
];
const EXPECTED_FASTQ_LIST_CSV_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "fastq_list.csv",
    contents: readFileSync(FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
const TUMOR_FASTQ_LIST_ROWS: Array<FastqListRow> = [
    {
        "rgid": "TTTTTTTT.GGGGGGGG.4.MY_RUN_ID.MY_TUMOR_SAMPLE_ID",
        "rglb": "MY_TUMOR_LIBRARY_ID",
        "rgsm": "MY_TUMOR_SAMPLE_ID",
        "lane": 4,
        "read_1": <IFile> {
            "class_": File_class.FILE,
            "location": "data/MY_TUMOR_SAMPLE_ID_L004_R1_001.fastq.gz"
        },
        "read_2": <IFile> {
            "class_": File_class.FILE,
            "location": "data/MY_TUMOR_SAMPLE_ID_L004_R2_001.fastq.gz"
        }
    },
    {
        "rgid": "TTTTTTTT.GGGGGGGG.2.MY_RUN_ID.MY_TUMOR_SAMPLE_ID",
        "rglb": "MY_TUMOR_LIBRARY_ID",
        "lane": 2,
        "rgsm": "MY_TUMOR_SAMPLE_ID",
        "read_1": <IFile> {
            "class_": File_class.FILE,
            "location": "data/MY_TUMOR_SAMPLE_ID_L002_R1_001.fastq.gz"
        },
        "read_2": <IFile> {
            "class_": File_class.FILE,
            "location": "data/MY_TUMOR_SAMPLE_ID_L002_R2_001.fastq.gz"
        }
    }
];
const EXPECTED_TUMOR_FASTQ_LIST_CSV_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "fastq_list.csv",
    contents: readFileSync(TUMOR_FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
const HEADER_NAMES = [
    "rglb",
    "rgid",
    "rgsm",
    "read_1",
    "read_2"
];
const EXPECTED_OUTPUT_HEADER_NAMES = "RGLB,RGID,RGSM,Read1File,Read2File";
const MOUNT_POINTS_FASTQ_LIST_ROWS_INPUT = {
    fastq_list_rows: FASTQ_LIST_ROWS,
    tumor_fastq_list_rows: TUMOR_FASTQ_LIST_ROWS,
    fastq_list: null,
    tumor_fastq_list: null
};
const MOUNT_POINTS_FASTQ_LIST_CSV_INPUT = {
    fastq_list_rows: null,
    tumor_fastq_list_rows: null,
    fastq_list: FASTQ_LIST_CSV_FILE,
    tumor_fastq_list: TUMOR_CSV_FILE
};
const ORA_RUN_DIRECTORY: IDirectory = {
    class_: Directory_class.DIRECTORY,
    location: "data",
    path: "data",
    basename: "data",
    listing: [
        {
            class_: File_class.FILE,
            basename: "MY_SAMPLE_ID_L002_R1_001.fastq.gz",
            path: "data/MY_SAMPLE_ID_L002_R1_001.fastq.gz",
            location: "data/MY_SAMPLE_ID_L002_R1_001.fastq.gz"
        },
        {
            class_: File_class.FILE,
            basename: "MY_SAMPLE_ID_L002_R2_001.fastq.gz",
            path: "data/MY_SAMPLE_ID_L002_R2_001.fastq.gz",
            location: "data/MY_SAMPLE_ID_L002_R2_001.fastq.gz"
        },
        {
            class_: File_class.FILE,
            basename: "MY_SAMPLE_ID_L004_R1_001.fastq.gz",
            path: "data/MY_SAMPLE_ID_L004_R1_001.fastq.gz",
            location: "data/MY_SAMPLE_ID_L004_R1_001.fastq.gz"
        },
        {
            class_: File_class.FILE,
            basename: "MY_SAMPLE_ID_L004_R2_001.fastq.gz",
            path: "data/MY_SAMPLE_ID_L004_R2_001.fastq.gz",
            location: "data/MY_SAMPLE_ID_L004_R2_001.fastq.gz"
        },
    ]
};
const EXPECTED_ORA_FASTQ_LIST_CSV_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "fastq_list.csv",
    contents: readFileSync(ORA_FASTQ_LIST_CSV_FILE_PATH, "utf8")
};
const EXPECTED_ORA_MV_SH_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "mv-ora-output-files.sh",
    contents: readFileSync(MV_ORA_FILE_PATH, "utf8")
};
const EXPECTED_ORA_NEW_FASTQ_LIST_CSV_SH_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "generate-new-fastq-list-csv.sh",
    contents: readFileSync(GENERATE_NEW_FASTQ_LIST_CSV_SH_PATH, "utf8")
};
const EXPECTED_MD5SUM_FOR_FASTQ_GZ_FILES_SH_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "generate-md5sum-for-fastq-raw-files.sh",
    contents: readFileSync(GENERATE_MD5SUM_FOR_FASTQ_GZ_FILES_SH_PATH, "utf8")
};
const EXPECTED_MD5SUM_FOR_FASTQ_ORA_FILES_SH_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "generate-md5sum-for-fastq-ora-files.sh",
    contents: readFileSync(GENERATE_MD5SUM_FOR_FASTQ_ORA_FILES_SH_PATH, "utf8")
};
const FILE_SIZES_FOR_FASTQ_GZ_FILES_SH_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "generate-file-sizes-for-fastq-gz-files.sh",
    contents: readFileSync(GENERATE_FILE_SIZES_FOR_FASTQ_GZ_FILES_SH_PATH, "utf8")
};
const FILE_SIZES_FOR_FASTQ_ORA_FILES_SH_OUTPUT: IFile = {
    class_: File_class.FILE,
    basename: "generate-file-sizes-for-fastq-ora-files.sh",
    contents: readFileSync(GENERATE_FILE_SIZES_FOR_FASTQ_ORA_FILES_SH_PATH, "utf8")
};


describe('Test Simple Functions', function () {
    // Simple expected outputs
    const expected_get_script_path_output = "run-dragen-script.sh";
    const expected_get_fastq_list_csv_path_output = "fastq_list.csv";
    const expected_get_tumor_fastq_list_csv_path_output = "tumor_fastq_list.csv";
    // Get script path
    test("Test the get script path function", function () {
        expect(get_script_path()).toEqual(expected_get_script_path_output);
    });
    test("Test the get fastq list csv path function", function () {
        expect(get_fastq_list_csv_path()).toEqual(expected_get_fastq_list_csv_path_output);
    });
    test("Test the get tumor fastq list csv path function", function () {
        expect(get_tumor_fastq_list_csv_path()).toEqual(expected_get_tumor_fastq_list_csv_path_output);
    });
});

// Get normal names import
describe('Test the get normal name function suite', function () {
    const expected_rgsm_value = "MY_SAMPLE_ID";
    const fastq_list_as_input = {
        "fastq_list_rows": null,
        "fastq_list": FASTQ_LIST_CSV_FILE,
        "bam_input": null,
        "cram_input": null
    };
    const fastq_list_rows_as_input = {
        "fastq_list_rows": FASTQ_LIST_ROWS,
        "fastq_list": null,
        "bam_input": null,
        "cram_input": null
    };
    const bam_input_as_input = {
        "fastq_list_rows": null,
        "fastq_list": null,
        "bam_input": NORMAL_BAM_INPUT_FILE,
        "cram_input": null
    }
    const bam_with_normal_as_input = {
        "fastq_list_rows": null,
        "fastq_list": null,
        "bam_input": NORMAL_BAM_INPUT_FILE_WITH_NORMAL_SUFFIX,
        "cram_input": null
    }
    /*
    Testing from file
    */
    test("Test collecting normal name from the fastq list csv", function () {
        expect(get_normal_name_from_fastq_list_csv(FASTQ_LIST_CSV_FILE)).toEqual(expected_rgsm_value);
    });
    test("Test collecting normal name from the reordered fastq list csv", function () {
        expect(get_normal_name_from_fastq_list_csv(FASTQ_LIST_REORDERED_CSV_FILE)).toEqual(expected_rgsm_value);
    });
    test("Test the get normal output prefix function with fastq list rows as non null", function () {
        expect(get_normal_output_prefix(fastq_list_as_input)).toEqual(expected_rgsm_value + "_normal");
    });
    /*
    Testing from schema
    */
    test("Test collecting normal name from the fastq list rows csv", function () {
        expect(get_normal_name_from_fastq_list_rows(FASTQ_LIST_ROWS)).toEqual(expected_rgsm_value);
    });
    test("Test the get normal output prefix function with fastq list rows as non null", function () {
        expect(get_normal_output_prefix(fastq_list_rows_as_input)).toEqual(expected_rgsm_value + "_normal");
    });
    /*
    Test from bam input
    */
    test(
        "Test the get_normal_output prefix function with bam input as non null", function() {
            expect(get_normal_output_prefix(bam_input_as_input)).toEqual(expected_rgsm_value + "_normal");
    });
    /*
    Test bam input with normal suffix (should be the same as above)
    */
    test(
        "Test the get_normal_output prefix function with bam input as non null", function() {
            expect(get_normal_output_prefix(bam_with_normal_as_input)).toEqual(expected_rgsm_value + "_normal");
    });
});

// Test the fastq list csv builders
describe('Test the fastq list csv builder functions', function () {
    const expected_fastq_list_row_output = [
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
        expect(build_fastq_list_csv_header(HEADER_NAMES)).toEqual(EXPECTED_OUTPUT_HEADER_NAMES + "\n");
    });
    /*
    Get the fastq list row as a csv row test
    */
    test("Create a single row of fastq list test", function () {
        expect(get_fastq_list_row_as_csv_row(FASTQ_LIST_ROWS[0], Object.getOwnPropertyNames(FASTQ_LIST_ROWS[0]))).toEqual(expected_fastq_list_row_output);
    });
    /*
    Generate fastq list csv test
    */
    test("Test generated of the fastq list csv file", function () {
        expect(generate_fastq_list_csv(FASTQ_LIST_ROWS)).toEqual(EXPECTED_FASTQ_LIST_CSV_OUTPUT);
    });
});

describe('Test generate mount points', function () {
    const expected_mount_points_object = [
        {
            "entryname": "fastq_list.csv",
            "entry": EXPECTED_FASTQ_LIST_CSV_OUTPUT
        },
        {
            "entryname": "tumor_fastq_list.csv",
            "entry": EXPECTED_TUMOR_FASTQ_LIST_CSV_OUTPUT
        }
    ];
    const fastq_list_row_mount_points = generate_somatic_mount_points(MOUNT_POINTS_FASTQ_LIST_ROWS_INPUT);
    const fastq_list_csv_mount_points = generate_somatic_mount_points(MOUNT_POINTS_FASTQ_LIST_CSV_INPUT);
    test("Test the generate mount points of the tumor and normal fastq list rows", function () {
        expect(fastq_list_row_mount_points).toMatchObject(expected_mount_points_object);
    });
    test("Test the generate mount points of the tumor and normal fastq list csv", function () {
        expect(fastq_list_csv_mount_points).toMatchObject(expected_mount_points_object);
    });
});


describe('Test ora mount points', function () {
    const expected_mount_points_object = [
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
            "entryname": "generate-md5sum-for-fastq-raw-files.sh",
            "entry": EXPECTED_MD5SUM_FOR_FASTQ_GZ_FILES_SH_OUTPUT
        },
        {
            "entryname": "generate-file-sizes-for-fastq-gz-files.sh",
            "entry": FILE_SIZES_FOR_FASTQ_GZ_FILES_SH_OUTPUT
        },
        {
            "entryname": "generate-md5sum-for-fastq-ora-files.sh",
            "entry": EXPECTED_MD5SUM_FOR_FASTQ_ORA_FILES_SH_OUTPUT
        },
        {
            "entryname": "generate-file-sizes-for-fastq-ora-files.sh",
            "entry": FILE_SIZES_FOR_FASTQ_ORA_FILES_SH_OUTPUT
        },
    ];
    const fastq_list_csv_mount_points = generate_ora_mount_points(ORA_RUN_DIRECTORY, "output-directory-path");
    test("Test the generate mount points of the tumor and normal fastq list rows", function () {
        expect(fastq_list_csv_mount_points).toMatchObject(expected_mount_points_object);
    });
});
