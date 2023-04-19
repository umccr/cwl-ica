// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports


// Dummy Test
import {
    get_genomes_dir_name, get_genomes_dir_path,
    get_genomes_parent_dir, get_germline_input_dir,
    get_name_root_from_tarball,
    get_num_threads, get_scratch_input_dir,
    get_scratch_mount, get_scratch_working_dir, get_scratch_working_parent_dir, get_somatic_input_dir
} from "../umccrise__2.0.0";

describe('This is a dummy test', function() {
    test('This test always passes', () => {
        expect(0).toEqual(0)
    })
})

// get_num_threads
const THREAD_INPUTS = {
    threads: 2
}
const THREAD_EMPTY_INPUTS = {
    threads: null
}
const THREAD_RUNTIME = {
    cores: 6
}

describe('Test get_num_threads', function() {
    test('Test with threads set', () => {
        expect(get_num_threads(THREAD_INPUTS["threads"], THREAD_RUNTIME["cores"])).toEqual(THREAD_INPUTS["threads"])
    })
    test('Test with threads unset', () => {
        expect(get_num_threads(THREAD_EMPTY_INPUTS["threads"], THREAD_RUNTIME["cores"])).toEqual(THREAD_RUNTIME["cores"])
    })
})

// get_scratch_mount
const EXPECTED_SCRATCH_MOUNT_VALUE = "/scratch"
describe('Test get_scratch_mount', function() {
    test('Test get_scratch_mount', () => {
        expect(get_scratch_mount()).toEqual(EXPECTED_SCRATCH_MOUNT_VALUE)
    })
})

// get_name_root_from_tarball
const INPUT_GENOMES_BASENAME = "refdata.tar.gz"
const EXPECTED_OUTPUT_GENOMES_NAMEROOT = "refdata"
describe('Test get_name_root_from_tarball', function() {
    test('Test get_name_root_from_tarball', () => {
        expect(get_name_root_from_tarball(INPUT_GENOMES_BASENAME)).toEqual(EXPECTED_OUTPUT_GENOMES_NAMEROOT)
    })
})

// get_genomes_parent_dir
const EXPECTED_OUTPUT_GENOMES_PARENT_DIR = "/scratch/genome_dir"
describe('Test get_genomes_parent_dir', function() {
    test('Test get_genomes_parent_dir', () => {
        expect(get_genomes_parent_dir()).toEqual(EXPECTED_OUTPUT_GENOMES_PARENT_DIR)
    })
})

// get_scratch_working_parent_dir
const EXPECTED_OUTPUT_WORKING_PARENT_DIR = "/scratch/working_dir"
describe('Test get_scratch_working_parent_dir', function() {
    test('Test get_scratch_working_parent_dir', () => {
        expect(get_scratch_working_parent_dir()).toEqual(EXPECTED_OUTPUT_WORKING_PARENT_DIR)
    })
})

// get_scratch_working_dir
const INPUT_OUTPUT_DIRECTORY_NAME = "test-output-directory"
const EXPECTED_OUTPUT_WORKING_DIR = `/scratch/working_dir/${INPUT_OUTPUT_DIRECTORY_NAME}`
describe('Test get_scratch_working_dir', function() {
    test('Test get_scratch_working_dir', () => {
        expect(get_scratch_working_dir(INPUT_OUTPUT_DIRECTORY_NAME)).toEqual(EXPECTED_OUTPUT_WORKING_DIR)
    })
})

// get_scratch_input_dir
const EXPECTED_OUTPUT_INPUT_DIR = "/scratch/inputs"
describe('Test get_scratch_input_dir', function() {
    test('Test get_scratch_input_dir', () => {
        expect(get_scratch_input_dir()).toEqual(EXPECTED_OUTPUT_INPUT_DIR)
    })
})

// get_somatic_input_dir
const INPUT_DRAGEN_SOMATIC_DIRECTORY_BASENAME = "dragen_somatic_output"
const EXPECTED_SOMATIC_INPUT_DIRECTORY_OUTPUT = `/scratch/inputs/somatic/${INPUT_DRAGEN_SOMATIC_DIRECTORY_BASENAME}`
describe('Test get_somatic_input_dir', function() {
    test('Test get_somatic_input_dir', () => {
        expect(get_somatic_input_dir(INPUT_DRAGEN_SOMATIC_DIRECTORY_BASENAME)).toEqual(EXPECTED_SOMATIC_INPUT_DIRECTORY_OUTPUT)
    })
})

// get_germline_input_dir
const INPUT_DRAGEN_GERMLINE_DIRECTORY_BASENAME = "dragen_germline_output"
const EXPECTED_DRAGEN_GERMLINE_INPUT_DIRECTORY_OUTPUT = `/scratch/inputs/germline/${INPUT_DRAGEN_GERMLINE_DIRECTORY_BASENAME}`
describe('Test get_germline_input_dir', function() {
    test('Test get_germline_input_dir', () => {
        expect(get_germline_input_dir(INPUT_DRAGEN_GERMLINE_DIRECTORY_BASENAME)).toEqual(EXPECTED_DRAGEN_GERMLINE_INPUT_DIRECTORY_OUTPUT)
    })
})

// get_genomes_dir_name
const INPUT_GET_GENOMES_DIR_NAME = "refdata.tar.gz"
const EXPECTED_GET_GENOMES_DIR_NAME_OUTPUT = "refdata"
describe('Test get_genomes_dir_name', function() {
    test('Test get_genomes_dir_name', () => {
        expect(get_genomes_dir_name(INPUT_GET_GENOMES_DIR_NAME)).toEqual(EXPECTED_GET_GENOMES_DIR_NAME_OUTPUT)
    })
})

// get_genomes_dir_path
const INPUT_GET_GENOMES_DIR_PATH = "refdata.tar.gz"
const EXPECTED_GET_GENOMES_DIR_PATH_OUTPUT = "/scratch/genome_dir/refdata"
describe('Test get_genomes_dir_path', function() {
    test('Test get_genomes_dir_path', () => {
        expect(get_genomes_dir_path(INPUT_GET_GENOMES_DIR_PATH)).toEqual(EXPECTED_GET_GENOMES_DIR_PATH_OUTPUT)
    })
})
