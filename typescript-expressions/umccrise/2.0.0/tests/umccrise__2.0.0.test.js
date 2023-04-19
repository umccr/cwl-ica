"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
// Dummy Test
var umccrise__2_0_0_1 = require("../umccrise__2.0.0");
describe('This is a dummy test', function () {
    test('This test always passes', function () {
        expect(0).toEqual(0);
    });
});
// get_num_threads
var THREAD_INPUTS = {
    threads: 2
};
var THREAD_EMPTY_INPUTS = {
    threads: null
};
var THREAD_RUNTIME = {
    cores: 6
};
describe('Test get_num_threads', function () {
    test('Test with threads set', function () {
        expect((0, umccrise__2_0_0_1.get_num_threads)(THREAD_INPUTS["threads"], THREAD_RUNTIME["cores"])).toEqual(THREAD_INPUTS["threads"]);
    });
    test('Test with threads unset', function () {
        expect((0, umccrise__2_0_0_1.get_num_threads)(THREAD_EMPTY_INPUTS["threads"], THREAD_RUNTIME["cores"])).toEqual(THREAD_RUNTIME["cores"]);
    });
});
// get_scratch_mount
var EXPECTED_SCRATCH_MOUNT_VALUE = "/scratch";
describe('Test get_scratch_mount', function () {
    test('Test get_scratch_mount', function () {
        expect((0, umccrise__2_0_0_1.get_scratch_mount)()).toEqual(EXPECTED_SCRATCH_MOUNT_VALUE);
    });
});
// get_name_root_from_tarball
var INPUT_GENOMES_BASENAME = "refdata.tar.gz";
var EXPECTED_OUTPUT_GENOMES_NAMEROOT = "refdata";
describe('Test get_name_root_from_tarball', function () {
    test('Test get_name_root_from_tarball', function () {
        expect((0, umccrise__2_0_0_1.get_name_root_from_tarball)(INPUT_GENOMES_BASENAME)).toEqual(EXPECTED_OUTPUT_GENOMES_NAMEROOT);
    });
});
// get_genomes_parent_dir
var EXPECTED_OUTPUT_GENOMES_PARENT_DIR = "/scratch/genome_dir";
describe('Test get_genomes_parent_dir', function () {
    test('Test get_genomes_parent_dir', function () {
        expect((0, umccrise__2_0_0_1.get_genomes_parent_dir)()).toEqual(EXPECTED_OUTPUT_GENOMES_PARENT_DIR);
    });
});
// get_scratch_working_parent_dir
var EXPECTED_OUTPUT_WORKING_PARENT_DIR = "/scratch/working_dir";
describe('Test get_scratch_working_parent_dir', function () {
    test('Test get_scratch_working_parent_dir', function () {
        expect((0, umccrise__2_0_0_1.get_scratch_working_parent_dir)()).toEqual(EXPECTED_OUTPUT_WORKING_PARENT_DIR);
    });
});
// get_scratch_working_dir
var INPUT_OUTPUT_DIRECTORY_NAME = "test-output-directory";
var EXPECTED_OUTPUT_WORKING_DIR = "/scratch/working_dir/".concat(INPUT_OUTPUT_DIRECTORY_NAME);
describe('Test get_scratch_working_dir', function () {
    test('Test get_scratch_working_dir', function () {
        expect((0, umccrise__2_0_0_1.get_scratch_working_dir)(INPUT_OUTPUT_DIRECTORY_NAME)).toEqual(EXPECTED_OUTPUT_WORKING_DIR);
    });
});
// get_scratch_input_dir
var EXPECTED_OUTPUT_INPUT_DIR = "/scratch/inputs";
describe('Test get_scratch_input_dir', function () {
    test('Test get_scratch_input_dir', function () {
        expect((0, umccrise__2_0_0_1.get_scratch_input_dir)()).toEqual(EXPECTED_OUTPUT_INPUT_DIR);
    });
});
// get_somatic_input_dir
var INPUT_DRAGEN_SOMATIC_DIRECTORY_BASENAME = "dragen_somatic_output";
var EXPECTED_SOMATIC_INPUT_DIRECTORY_OUTPUT = "/scratch/inputs/somatic/".concat(INPUT_DRAGEN_SOMATIC_DIRECTORY_BASENAME);
describe('Test get_somatic_input_dir', function () {
    test('Test get_somatic_input_dir', function () {
        expect((0, umccrise__2_0_0_1.get_somatic_input_dir)(INPUT_DRAGEN_SOMATIC_DIRECTORY_BASENAME)).toEqual(EXPECTED_SOMATIC_INPUT_DIRECTORY_OUTPUT);
    });
});
// get_germline_input_dir
var INPUT_DRAGEN_GERMLINE_DIRECTORY_BASENAME = "dragen_germline_output";
var EXPECTED_DRAGEN_GERMLINE_INPUT_DIRECTORY_OUTPUT = "/scratch/inputs/germline/".concat(INPUT_DRAGEN_GERMLINE_DIRECTORY_BASENAME);
describe('Test get_germline_input_dir', function () {
    test('Test get_germline_input_dir', function () {
        expect((0, umccrise__2_0_0_1.get_germline_input_dir)(INPUT_DRAGEN_GERMLINE_DIRECTORY_BASENAME)).toEqual(EXPECTED_DRAGEN_GERMLINE_INPUT_DIRECTORY_OUTPUT);
    });
});
// get_genomes_dir_name
var INPUT_GET_GENOMES_DIR_NAME = "refdata.tar.gz";
var EXPECTED_GET_GENOMES_DIR_NAME_OUTPUT = "refdata";
describe('Test get_genomes_dir_name', function () {
    test('Test get_genomes_dir_name', function () {
        expect((0, umccrise__2_0_0_1.get_genomes_dir_name)(INPUT_GET_GENOMES_DIR_NAME)).toEqual(EXPECTED_GET_GENOMES_DIR_NAME_OUTPUT);
    });
});
// get_genomes_dir_path
var INPUT_GET_GENOMES_DIR_PATH = "refdata.tar.gz";
var EXPECTED_GET_GENOMES_DIR_PATH_OUTPUT = "/scratch/genome_dir/refdata";
describe('Test get_genomes_dir_path', function () {
    test('Test get_genomes_dir_path', function () {
        expect((0, umccrise__2_0_0_1.get_genomes_dir_path)(INPUT_GET_GENOMES_DIR_PATH)).toEqual(EXPECTED_GET_GENOMES_DIR_PATH_OUTPUT);
    });
});
