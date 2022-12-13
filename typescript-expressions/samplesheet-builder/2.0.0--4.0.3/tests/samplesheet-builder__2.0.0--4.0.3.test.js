"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
Object.defineProperty(exports, "__esModule", { value: true });
// Imports
var cwl_ts_auto_1 = require("cwl-ts-auto");
var samplesheet_builder__2_0_0__4_0_3_1 = require("../samplesheet-builder__2.0.0--4.0.3");
// Inputs and outputs for Header section
// Input
var INPUT_HEADER_SECTION_NAME = "Header";
var INPUT_HEADER_SECTION_SCHEMA_1 = {
    "iem_file_version": 2,
    "experiment_name": "Test Input Header Schema",
    "date": "2022-08-07",
    "workflow": "GenerateFastq",
    "application": "NovaSeq Fastq Only",
    "instrument_type": "NovaSeq",
    "assay": "Truseq Nano DNA",
    "index_adapters": "Truseq DNA CD Indexes",
    "chemistry": "Amplicon",
    "file_format_version": 2,
};
var EXPECTED_OUTPUT_HEADER_SECTION_STR_1 = "[".concat(INPUT_HEADER_SECTION_NAME, "]\n") +
    "IEMFileVersion,2\n" +
    "ExperimentName,Test Input Header Schema\n" +
    "Date,2022-08-07\n" +
    "Workflow,GenerateFastq\n" +
    "Application,NovaSeq Fastq Only\n" +
    "InstrumentType,NovaSeq\n" +
    "Assay,Truseq Nano DNA\n" +
    "IndexAdapters,Truseq DNA CD Indexes\n" +
    "Chemistry,Amplicon\n" +
    "FileFormatVersion,2\n" +
    "\n";
var INPUT_HEADER_SECTION_SCHEMA_2 = {
    "iem_file_version": 5,
    "experiment_name": "Project28Jan22",
    "date": "28/01/2022",
    "workflow": "GenerateFastq",
    "application": "NovaSeq Fastq Only",
    "instrument_type": "NovaSeq",
    "assay": "Illumina DNA Prep",
    "index_adapters": "IDT-ILMN Nextera DNA UD Indexes (96 Indexes) Set D",
    "chemistry": "Amplicon",
    "file_format_version": 2
};
var EXPECTED_OUTPUT_HEADER_SECTION_STR_2 = "[".concat(INPUT_HEADER_SECTION_NAME, "]\n") +
    "IEMFileVersion,5\n" +
    "ExperimentName,Project28Jan22\n" +
    "Date,28/01/2022\n" +
    "Workflow,GenerateFastq\n" +
    "Application,NovaSeq Fastq Only\n" +
    "InstrumentType,NovaSeq\n" +
    "Assay,Illumina DNA Prep\n" +
    "IndexAdapters,IDT-ILMN Nextera DNA UD Indexes (96 Indexes) Set D\n" +
    "Chemistry,Amplicon\n" +
    "FileFormatVersion,2\n" +
    "\n";
// Inputs and outputs for Reads section
var INPUT_READS_SECTION_NAME = "Reads";
var INPUT_READS_SECTION_SCHEMA_1 = {
    read_1_cycles: 151,
    read_2_cycles: 151
};
var INPUT_READS_SECTION_SCHEMA_2 = {
    read_1_cycles: 151,
    read_2_cycles: 151
};
var EXPECTED_READS_OUTPUT_SECTION_STR_1 = "[".concat(INPUT_READS_SECTION_NAME, "]\n") +
    "Read1Cycles,151\n" +
    "Read2Cycles,151\n" +
    "\n";
var EXPECTED_READS_OUTPUT_SECTION_STR_2 = "[".concat(INPUT_READS_SECTION_NAME, "]\n") +
    "Read1Cycles,151\n" +
    "Read2Cycles,151\n" +
    "\n";
// Inputs and outputs for BCLConvert Settings section
var INPUT_BCLCONVERT_SETTINGS_SECTION_NAME = "BCLConvert_Settings";
var INPUT_BCLCONVERT_SETTINGS_SECTION_SCHEMA_1 = {
    adapter_behavior: "trim",
    adapter_stringency: 1,
    create_fastq_for_index_reads: false,
    no_lane_splitting: false,
    override_cycles: "Y151;I8;N8;Y151",
    trim_umi: false
};
var INPUT_BCLCONVERT_SETTINGS_SECTION_SCHEMA_2 = {
    override_cycles: "Y151;I10;I10;Y151",
};
var EXPECTED_BCLCONVERT_SETTINGS_SECTION_OUTPUT_1 = "[".concat(INPUT_BCLCONVERT_SETTINGS_SECTION_NAME, "]\n") +
    "AdapterBehavior,trim\n" +
    "AdapterStringency,1\n" +
    "CreateFastqForIndexReads,0\n" +
    "NoLaneSplitting,false\n" +
    "OverrideCycles,Y151;I8;N8;Y151\n" +
    "TrimUMI,0\n" +
    "\n";
var EXPECTED_BCLCONVERT_SETTINGS_SECTION_OUTPUT_2 = "[".concat(INPUT_BCLCONVERT_SETTINGS_SECTION_NAME, "]\n") +
    "OverrideCycles,Y151;I10;I10;Y151\n" +
    "\n";
// Inputs and outputs for BCLConvert Data section
var INPUT_BCLCONVERT_DATA_SECTION_NAME = "BCLConvert_Data";
var INPUT_BCLCONVERT_DATA_SECTION_SCHEMA_1 = [
    {
        lane: 1,
        sample_id: "MySampleID",
        index: "AAAAAAAA",
        index2: "GGGGGGGG",
        sample_project: "MySampleProject",
        override_cycles: "Y151;I8;N8;Y151"
    },
    {
        lane: 2,
        sample_id: "MySampleID",
        index2: "GGGGGGGG",
        index: "AAAAAAAA",
        sample_project: "MySampleProject",
        override_cycles: "Y151;I8;N8;Y151"
    }
];
var INPUT_BCLCONVERT_DATA_HEADER_NAMES_ARRAY_1 = ["lane", "sample_id", "index", "index2", "sample_project", "override_cycles"];
var INPUT_BCLCONVERT_DATA_SECTION_SCHEMA_2 = [
    {
        "index": "GAACAATTCC",
        "index2": "TCCAACTCTA",
        "lane": 1,
        "sample_id": "PRJ220074_LPRJ220074",
        "sample_project": "Project2",
        "override_cycles": "Y151;I10;I10;Y151"
    },
    {
        "index": "TGTGGTCCGG",
        "index2": "CTAGTGCTCT",
        "lane": 1,
        "sample_id": "PRJ220075_LPRJ220075",
        "sample_project": "Project2",
        "override_cycles": "Y151;I10;I10;Y151"
    },
    {
        "sample_id": "PRJ220076_LPRJ220076",
        "index": "CTTCTAAGTC",
        "lane": 1,
        "sample_project": "Project2",
        "override_cycles": "Y151;I10;N10;Y151"
    },
    {
        "index": "AATATTGCCA",
        "sample_id": "PRJ220077_LPRJ220077",
        "lane": 1,
        "sample_project": "Project2",
        "override_cycles": "Y151;I10;N10;Y151"
    }
];
// const INPUT_BCLCONVERT_DATA_HEADER_NAMES_ARRAY_2 = [ "index", "index2", "lane", "sample_id", "sample_project"]
var EXPECTED_BCLCONVERT_DATA_HEADER_OUTPUT_STR_1 = "Lane,Sample_ID,index,index2,Sample_Project,OverrideCycles\n";
var EXPECTED_DATA_ROW_1_STR_1 = "1,MySampleID,AAAAAAAA,GGGGGGGG,MySampleProject,Y151;I8;N8;Y151\n";
var EXPECTED_DATA_ROW_2_STR_1 = "2,MySampleID,AAAAAAAA,GGGGGGGG,MySampleProject,Y151;I8;N8;Y151\n";
var EXPECTED_BCLCONVERT_DATA_OUTPUT_STR_1 = "[".concat(INPUT_BCLCONVERT_DATA_SECTION_NAME, "]\n") +
    EXPECTED_BCLCONVERT_DATA_HEADER_OUTPUT_STR_1 +
    EXPECTED_DATA_ROW_1_STR_1 +
    EXPECTED_DATA_ROW_2_STR_1 + "\n";
var EXPECTED_BCLCONVERT_DATA_HEADER_OUTPUT_STR_2 = "index,index2,Lane,Sample_ID,Sample_Project,OverrideCycles\n";
var EXPECTED_DATA_ROW_1_STR_2 = "GAACAATTCC,TCCAACTCTA,1,PRJ220074_LPRJ220074,Project2,Y151;I10;I10;Y151\n";
var EXPECTED_DATA_ROW_2_STR_2 = "TGTGGTCCGG,CTAGTGCTCT,1,PRJ220075_LPRJ220075,Project2,Y151;I10;I10;Y151\n";
var EXPECTED_DATA_ROW_3_STR_2 = "CTTCTAAGTC,,1,PRJ220076_LPRJ220076,Project2,Y151;I10;N10;Y151\n";
var EXPECTED_DATA_ROW_4_STR_2 = "AATATTGCCA,,1,PRJ220077_LPRJ220077,Project2,Y151;I10;N10;Y151\n";
var EXPECTED_BCLCONVERT_DATA_OUTPUT_STR_2 = "[".concat(INPUT_BCLCONVERT_DATA_SECTION_NAME, "]\n") +
    EXPECTED_BCLCONVERT_DATA_HEADER_OUTPUT_STR_2 +
    EXPECTED_DATA_ROW_1_STR_2 +
    EXPECTED_DATA_ROW_2_STR_2 +
    EXPECTED_DATA_ROW_3_STR_2 +
    EXPECTED_DATA_ROW_4_STR_2 + "\n";
// Test key_name_to_camelcase
describe('Test key name to camelcase function', function () {
    // Simple expected outputs
    var minimum_adapter_overlap_input = "minimum_adapter_overlap";
    var minimum_adapter_overlap_expected_output = "MinimumAdapterOverlap";
    var iem_input = "iem_file_version";
    var iem_expected_output = "IEMFileVersion";
    var sample_id_input = "sample_id";
    var sample_id_expected_output = "Sample_ID";
    var trim_umi_input = "trim_umi";
    var trim_umi_expected_output = "TrimUMI";
    // Get script path
    test("Test key name to camelcase function 1", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.key_name_to_camelcase)(minimum_adapter_overlap_input, "")).toEqual(minimum_adapter_overlap_expected_output);
    });
    test("Test key name to camelcase function 2", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.key_name_to_camelcase)(iem_input, "")).toEqual(iem_expected_output);
    });
    test("Test key name to camelcase function 3 - with underscore separator", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.key_name_to_camelcase)(sample_id_input, "_")).toEqual(sample_id_expected_output);
    });
    test("Test key name to camelcase function 4", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.key_name_to_camelcase)(trim_umi_input, "")).toEqual(trim_umi_expected_output);
    });
});
// Test convert_bool_to_string_int
describe('Test convert bool to string int', function () {
    // Simple expected outputs
    var false_as_bool = false;
    var false_as_string_int = "0";
    var true_as_bool = true;
    var true_as_string_int = "1";
    // Get script path
    test("Test convert bool to string int 1", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.convert_bool_to_string_int)(false_as_bool)).toEqual(false_as_string_int);
    });
    test("Test convert bool to string int 2", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.convert_bool_to_string_int)(true_as_bool)).toEqual(true_as_string_int);
    });
});
// Test create_nondata_samplesheet_section
describe("Test creating samplesheet header with the create_non_data_section function", function () {
    test("Test create samplesheet header", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.create_nondata_samplesheet_section)(INPUT_HEADER_SECTION_NAME, INPUT_HEADER_SECTION_SCHEMA_1)).toEqual(EXPECTED_OUTPUT_HEADER_SECTION_STR_1);
    });
    test("Test expected reads samplesheet output", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.create_nondata_samplesheet_section)(INPUT_READS_SECTION_NAME, INPUT_READS_SECTION_SCHEMA_1)).toEqual(EXPECTED_READS_OUTPUT_SECTION_STR_1);
    });
    test("Test expected bclconvert settings samplesheet output", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.create_nondata_samplesheet_section)(INPUT_BCLCONVERT_SETTINGS_SECTION_NAME, INPUT_BCLCONVERT_SETTINGS_SECTION_SCHEMA_1)).toEqual(EXPECTED_BCLCONVERT_SETTINGS_SECTION_OUTPUT_1);
    });
});
describe("Test building the bclconvert data section", function () {
    test("Test build bclconvert data header", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.build_bclconvert_data_header)(INPUT_BCLCONVERT_DATA_HEADER_NAMES_ARRAY_1)).toEqual(EXPECTED_BCLCONVERT_DATA_HEADER_OUTPUT_STR_1);
    });
    test("Test get bclconvert data row as a csv row 1", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.get_bclconvert_data_row_as_csv_row)(INPUT_BCLCONVERT_DATA_SECTION_SCHEMA_1[0], INPUT_BCLCONVERT_DATA_HEADER_NAMES_ARRAY_1)).toEqual(EXPECTED_DATA_ROW_1_STR_1);
    });
    test("Test get bclconvert data row as a csv row 2", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.get_bclconvert_data_row_as_csv_row)(INPUT_BCLCONVERT_DATA_SECTION_SCHEMA_1[1], INPUT_BCLCONVERT_DATA_HEADER_NAMES_ARRAY_1)).toEqual(EXPECTED_DATA_ROW_2_STR_1);
    });
    // Test create_samplesheet_bclconvert_data_section
    test("Test create samplesheet bclconvert data section", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.create_samplesheet_bclconvert_data_section)(INPUT_BCLCONVERT_DATA_SECTION_SCHEMA_1)).toEqual(EXPECTED_BCLCONVERT_DATA_OUTPUT_STR_1);
    });
});
// Test create_samplesheet
describe('Test Create SampleSheet 1', function () {
    var samplesheet_input = {
        header: INPUT_HEADER_SECTION_SCHEMA_1,
        reads: INPUT_READS_SECTION_SCHEMA_1,
        bclconvert_settings: INPUT_BCLCONVERT_SETTINGS_SECTION_SCHEMA_1,
        bclconvert_data: INPUT_BCLCONVERT_DATA_SECTION_SCHEMA_1
    };
    var expected_samplesheet_output_str = EXPECTED_OUTPUT_HEADER_SECTION_STR_1 +
        EXPECTED_READS_OUTPUT_SECTION_STR_1 +
        EXPECTED_BCLCONVERT_SETTINGS_SECTION_OUTPUT_1 +
        EXPECTED_BCLCONVERT_DATA_OUTPUT_STR_1;
    var expected_samplesheet_output_file = {
        class_: cwl_ts_auto_1.File_class.FILE,
        basename: "SampleSheet.csv",
        contents: expected_samplesheet_output_str
    };
    test("Test Create SampleSheet 1", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.create_samplesheet)(samplesheet_input)).toEqual(expected_samplesheet_output_file);
    });
});
// Test create_samplesheet
describe('Test Create SampleSheet 2', function () {
    var samplesheet_input = {
        header: INPUT_HEADER_SECTION_SCHEMA_2,
        reads: INPUT_READS_SECTION_SCHEMA_2,
        bclconvert_settings: INPUT_BCLCONVERT_SETTINGS_SECTION_SCHEMA_2,
        bclconvert_data: INPUT_BCLCONVERT_DATA_SECTION_SCHEMA_2
    };
    var expected_samplesheet_output_str = EXPECTED_OUTPUT_HEADER_SECTION_STR_2 +
        EXPECTED_READS_OUTPUT_SECTION_STR_2 +
        EXPECTED_BCLCONVERT_SETTINGS_SECTION_OUTPUT_2 +
        EXPECTED_BCLCONVERT_DATA_OUTPUT_STR_2;
    var expected_samplesheet_output_file = {
        class_: cwl_ts_auto_1.File_class.FILE,
        basename: "SampleSheet.csv",
        contents: expected_samplesheet_output_str
    };
    test("Test Create SampleSheet 2", function () {
        expect((0, samplesheet_builder__2_0_0__4_0_3_1.create_samplesheet)(samplesheet_input)).toEqual(expected_samplesheet_output_file);
    });
});
