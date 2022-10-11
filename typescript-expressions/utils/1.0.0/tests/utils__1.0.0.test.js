"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
var utils__1_0_0_1 = require("../utils__1.0.0");
var cwl_ts_auto_1 = require("cwl-ts-auto");
var FALSE = false;
var TRUE = true;
var NULL = null;
var UNDEFINED = undefined;
var NOT_NULL = "This string is not null";
var NOT_NULL_FILE = {
    class_: cwl_ts_auto_1.File_class.FILE,
    location: "/path/to/bar"
};
// Test get value as str
describe('Test get_bool_value_as_str', function () {
    test('We expect get_bool_value_as_str(NULL) to be "false"', function () {
        expect((0, utils__1_0_0_1.get_bool_value_as_str)(NULL)).toEqual("false");
    });
    test('We expect get_bool_value_as_str(FALSE) to be "false"', function () {
        expect((0, utils__1_0_0_1.get_bool_value_as_str)(FALSE)).toEqual("false");
    });
    test('We expect get_bool_value_as_str(TRUE) to be "true"', function () {
        expect((0, utils__1_0_0_1.get_bool_value_as_str)(TRUE)).toEqual("true");
    });
});
// get_attribute_from_optional_input test
describe('Test get_attribute_from_optional_input utils', function () {
    test('We expect get_attribute_from_optional_input(UNDEFINED) to be null', function () {
        expect((0, utils__1_0_0_1.get_attribute_from_optional_input)(UNDEFINED, "location")).toEqual(NULL);
    });
    test('We expect get_attribute_from_optional_input(UNDEFINED) to be false', function () {
        expect((0, utils__1_0_0_1.get_attribute_from_optional_input)(NOT_NULL_FILE, "location")).toEqual(NOT_NULL_FILE["location"]);
    });
});
// is_not_null test
describe('Test is_not_null utils', function () {
    test('We expect is_not_null(NULL) to be false', function () {
        expect((0, utils__1_0_0_1.is_not_null)(NULL)).toEqual(false);
    });
    test('We expect is_not_null(UNDEFINED) to be false', function () {
        expect((0, utils__1_0_0_1.is_not_null)(UNDEFINED)).toEqual(false);
    });
    test('We expect is_not_null(NOT_NULL) to be true', function () {
        expect((0, utils__1_0_0_1.is_not_null)(NOT_NULL)).toEqual(true);
    });
});
