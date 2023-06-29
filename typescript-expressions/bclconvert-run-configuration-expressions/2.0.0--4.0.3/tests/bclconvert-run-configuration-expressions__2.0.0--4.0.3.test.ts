// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
import {File_class, FileProperties as IFile, Directory_class, DirectoryProperties as IDirectory} from "cwl-ts-auto";
import {
    BclconvertRunConfiguration
} from "../../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3";
import {
    add_run_info_and_samplesheet_to_bclconvert_run_configuration,
    add_run_info_to_bclconvert_run_configuration,
    create_bcl_configuration_object_for_samplesheet_validation,
    get_attribute_from_bclconvert_run_configuration,
    get_resource_hints_for_bclconvert_run
} from "../bclconvert-run-configuration-expressions__2.0.0--4.0.3";
import {Samplesheet} from "../../../../schemas/samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3";
import {SamplesheetHeader} from "../../../../schemas/samplesheet-header/2.0.0/samplesheet-header__2.0.0";
import {SamplesheetReads} from "../../../../schemas/samplesheet-reads/2.0.0/samplesheet-reads__2.0.0";
import {BclconvertSettings} from "../../../../schemas/bclconvert-settings/4.0.3/bclconvert-settings__4.0.3";
import {BclconvertDataRow} from "../../../../schemas/bclconvert-data-row/4.0.3/bclconvert-data-row__4.0.3";

// Test BclconvertRunConfiguration object
const INPUT_RUN_CONFIGURATION_OBJECT: BclconvertRunConfiguration = {
    bcl_conversion_threads: 1,
    bcl_sampleproject_subdirectories: true,
    output_directory: "output_dir"
}

describe('Check property that exists and is defined', function() {
    test('Get output directory', () => {
        expect(get_attribute_from_bclconvert_run_configuration(INPUT_RUN_CONFIGURATION_OBJECT, "output_directory")).toEqual("output_dir")
    })
})

describe('Check property that exists but is not defined', function() {
    test('Get first tile only', () => {
        expect(get_attribute_from_bclconvert_run_configuration(INPUT_RUN_CONFIGURATION_OBJECT, "first_tile_only")).toEqual(null)
    })
})

// Passes in JS but not TS, working on it
// describe('Check property that does not exist and expect error to be thrown', function() {
//     const EXPECTED_ERROR_STRING: string = "Error! BclconvertRunConfiguration object does not have attribute 'second_tile_only'"
//     // From dev.to/danywalls/testing-errors-with-jest-hkj
//     // And stackoverflow.com/questions/54649465/how-to-do-try-catch-and-finally-statements-in-typescript
//     test('Get second tile only', () => {
//         try {
//             get_attribute_from_bclconvert_run_configuration(INPUT_RUN_CONFIGURATION_OBJECT, "second_tile_only")
//         } catch (e: unknown) {
//             if (typeof e === "string"){
//                 expect(e).toEqual(EXPECTED_ERROR_STRING)
//             } else if ( e instanceof Error){
//                 expect(e.message).toEqual(EXPECTED_ERROR_STRING)
//             }
//         }
//     })
// })

// Test the bclconvert run configuration expressions
const INPUT_HEADER_SECTION_SCHEMA: SamplesheetHeader = {
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
}

const INPUT_READS_SECTION_SCHEMA: SamplesheetReads = {
    read_1_cycles: 151,
    read_2_cycles: 151
}

const INPUT_BCLCONVERT_SETTINGS_SECTION_SCHEMA: BclconvertSettings = {
    override_cycles: "Y151;I10;I10;Y151",
}

const INPUT_BCLCONVERT_DATA_SECTION_SCHEMA: Array<BclconvertDataRow> = [
    {
        "index": "GAACAATTCC",
        "index2": "TCCAACTCTA",
        "lane": 1,
        "sample_id": "PRJ220074_LPRJ220074",
        "sample_project": "Project2"
    },
    {
        "index": "TGTGGTCCGG",
        "index2": "CTAGTGCTCT",
        "lane": 1,
        "sample_id": "PRJ220075_LPRJ220075",
        "sample_project": "Project2"
    },
    {
        "sample_id": "PRJ220076_LPRJ220076",
        "index": "CTTCTAAGTC",
        "index2": "CCTGTAGAGT",
        "lane": 1,
        "sample_project": "Project2"
    },
    {
        "index2": "GGTGTCACCG",
        "index": "AATATTGCCA",
        "sample_id": "PRJ220077_LPRJ220077",
        "lane": 1,
        "sample_project": "Project2"
    }
]

const INPUT_SAMPLESHEET: Samplesheet = {
    header: INPUT_HEADER_SECTION_SCHEMA,
    reads: INPUT_READS_SECTION_SCHEMA,
    bclconvert_settings: INPUT_BCLCONVERT_SETTINGS_SECTION_SCHEMA,
    bclconvert_data: INPUT_BCLCONVERT_DATA_SECTION_SCHEMA
}

const INPUT_RUN_INFO: IFile = {
    class_: File_class.FILE,
    basename: "RunInfo.xml"
}

const EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT: BclconvertRunConfiguration = { ...INPUT_RUN_CONFIGURATION_OBJECT }
EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT.samplesheet = INPUT_SAMPLESHEET
EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT.run_info = INPUT_RUN_INFO
EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT.bcl_validate_sample_sheet_only = true

describe('Create bcl configuration object for samplesheet validation', function() {
    test('Create bcl configuration object for samplesheet validation', () => {
        expect(create_bcl_configuration_object_for_samplesheet_validation(INPUT_RUN_CONFIGURATION_OBJECT, INPUT_SAMPLESHEET, INPUT_RUN_INFO)).toMatchObject(EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT)
    })
})


const BCLCONVERT_COMMANDLINE_TOOL_INPUTS_VALIDATION: {
    bcl_input_directory: IDirectory,
    output_directory: string,
    samplesheet: IFile | null,
    bcl_validate_sample_sheet_only: boolean | null,
    fastq_compression_format: string | null
} = {
    bcl_input_directory: {
        class_: Directory_class.DIRECTORY,
        location: "path/to/input"
    },
    output_directory: "path/to/output",
    samplesheet: null,
    bcl_validate_sample_sheet_only: true,
    fastq_compression_format: null
}

const BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT = { ...BCLCONVERT_COMMANDLINE_TOOL_INPUTS_VALIDATION}
BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT.bcl_validate_sample_sheet_only = false

const BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT_FPGA = { ...BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT}
BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT_FPGA.fastq_compression_format = "dragen"

// Test getting resource requirements for bclconvert run
describe('Get resource requirements for bcl-convert samplesheet validation', function() {
    test('Get resource core requirements for bcl-convert samplesheet validation', () => {
        expect(get_resource_hints_for_bclconvert_run(BCLCONVERT_COMMANDLINE_TOOL_INPUTS_VALIDATION, "coresMin")).toEqual(1)
    })
})

describe('Get resource requirements for bcl-convert run', function() {
    test('Get resource core requirements for bcl-convert run', () => {
        expect(get_resource_hints_for_bclconvert_run(BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT, "coresMin")).toEqual(72)
    })
    test('Get resource docker requirements for bcl-convert run', () => {
        expect(get_resource_hints_for_bclconvert_run(BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT, "dockerPull")).toEqual("ghcr.io/umccr/bcl-convert:4.0.3")
    })
    test('Get resource type requirements for bcl-convert dragen run', () => {
        expect(get_resource_hints_for_bclconvert_run(BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT, "ilmn-tes-resources-type")).toEqual("standardHiCpu")
    })
})

describe('Get resource requirements for bcl-convert dragen run', function() {
    test('Get resource core requirements for bcl-convert dragen run', () => {
        expect(get_resource_hints_for_bclconvert_run(BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT_FPGA, "coresMin")).toEqual(16)
    })
    test('Get resource docker requirements for bcl-convert dragen run', () => {
        expect(get_resource_hints_for_bclconvert_run(BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT_FPGA, "dockerPull")).toEqual("699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:4.0.3")
    })
    test('Get resource type requirements for bcl-convert dragen run', () => {
        expect(get_resource_hints_for_bclconvert_run(BCLCONVERT_COMMANDLINE_TOOL_INPUTS_CONVERT_FPGA, "ilmn-tes-resources-type")).toEqual("fpga")
    })
})

const EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT_WITH_RUN_INFO: BclconvertRunConfiguration = { ...INPUT_RUN_CONFIGURATION_OBJECT }
EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT_WITH_RUN_INFO.run_info = INPUT_RUN_INFO

describe('Test add run info to bclconvert run configuration', function() {
    test('Test add run info to bclconvert run configuration', () => {
        expect(add_run_info_to_bclconvert_run_configuration(INPUT_RUN_CONFIGURATION_OBJECT, INPUT_RUN_INFO)).toMatchObject(EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT_WITH_RUN_INFO)
    })
})

const EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT_WITH_RUN_INFO_AND_SAMPLESHEET: BclconvertRunConfiguration = { ...INPUT_RUN_CONFIGURATION_OBJECT }
EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT_WITH_RUN_INFO_AND_SAMPLESHEET.run_info = INPUT_RUN_INFO
EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT_WITH_RUN_INFO_AND_SAMPLESHEET.samplesheet = INPUT_SAMPLESHEET

describe('Test add run info to bclconvert run configuration', function() {
    test('Test add run info to bclconvert run configuration', () => {
        expect(add_run_info_and_samplesheet_to_bclconvert_run_configuration(INPUT_RUN_CONFIGURATION_OBJECT, INPUT_RUN_INFO, INPUT_SAMPLESHEET)).toMatchObject(EXPECTED_OUTPUT_RUN_CONFIGURATION_OBJECT_WITH_RUN_INFO)
    })
})