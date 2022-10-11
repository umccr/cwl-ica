// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports

import {get_bool_value_as_str, get_attribute_from_optional_input, is_not_null} from "../utils__1.0.0";
import {
    FileProperties as IFile,
    File_class
} from "cwl-ts-auto"

const FALSE = false
const TRUE = true
const NULL = null
const UNDEFINED = undefined
const NOT_NULL = "This string is not null"

const NOT_NULL_FILE: IFile = {
    class_: File_class.FILE,
    location: "/path/to/bar"
}

// Test get value as str
describe('Test get_bool_value_as_str', function() {
    test('We expect get_bool_value_as_str(NULL) to be "false"', () => {
        expect(get_bool_value_as_str(NULL)).toEqual("false")
    })
    test('We expect get_bool_value_as_str(FALSE) to be "false"', () => {
        expect(get_bool_value_as_str(FALSE)).toEqual("false")
    })
    test('We expect get_bool_value_as_str(TRUE) to be "true"', () => {
        expect(get_bool_value_as_str(TRUE)).toEqual("true")
    })
})

// get_attribute_from_optional_input test
describe('Test get_attribute_from_optional_input utils', function() {
    test('We expect get_attribute_from_optional_input(UNDEFINED) to be null', () => {
        expect(get_attribute_from_optional_input(UNDEFINED, "location")).toEqual(NULL)
    })
    test('We expect get_attribute_from_optional_input(UNDEFINED) to be false', () => {
        expect(get_attribute_from_optional_input(NOT_NULL_FILE, "location")).toEqual(NOT_NULL_FILE["location"])
    })
})


// is_not_null test
describe('Test is_not_null utils', function() {
    test('We expect is_not_null(NULL) to be false', () => {
        expect(is_not_null(NULL)).toEqual(false)
    })
    test('We expect is_not_null(UNDEFINED) to be false', () => {
        expect(is_not_null(UNDEFINED)).toEqual(false)
    })
    test('We expect is_not_null(NOT_NULL) to be true', () => {
        expect(is_not_null(NOT_NULL)).toEqual(true)
    })
})

