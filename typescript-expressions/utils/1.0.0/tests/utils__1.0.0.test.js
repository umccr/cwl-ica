"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
require("jest");
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
var NOT_NULL_FILE2 = {
    class_: cwl_ts_auto_1.File_class.FILE,
    location: "far"
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
    test('We expect get_attribute_from_optional_input(UNDEFINED, "location") to be null', function () {
        expect((0, utils__1_0_0_1.get_attribute_from_optional_input)(UNDEFINED, "location")).toEqual(NULL);
    });
    test('We expect get_attribute_from_optional_input(NOT_NULL_FILE, "location") to equal NOT_NULL_FILE["location"]', function () {
        expect((0, utils__1_0_0_1.get_attribute_from_optional_input)(NOT_NULL_FILE, "location")).toEqual(NOT_NULL_FILE["location"]);
    });
});
// get_optional_attribute_from_object test
describe('Test get_optional_attribute_from_object utils', function () {
    test('We expect get_optional_attribute_from_object(NOT_NULL_FILE) to be null', function () {
        expect((0, utils__1_0_0_1.get_optional_attribute_from_object)(NOT_NULL_FILE, "nameroot")).toEqual(NULL);
    });
    test('We expect get_optional_attribute_from_object(UNDEFINED) to be false', function () {
        expect((0, utils__1_0_0_1.get_optional_attribute_from_object)(NOT_NULL_FILE, "location")).toEqual(NOT_NULL_FILE["location"]);
    });
});
// get_optional_attribute_from_object test
describe('Test get_optional_attribute_from_object utils', function () {
    test('We expect get_optional_attribute_from_object(UNDEFINED) to be null', function () {
        expect((0, utils__1_0_0_1.get_optional_attribute_from_multi_type_input_object)(UNDEFINED, "nameroot")).toEqual(NULL);
    });
    test('We expect get_optional_attribute_from_object("just_a_string", "nameroot") to be "just_a_string"', function () {
        expect((0, utils__1_0_0_1.get_optional_attribute_from_multi_type_input_object)("just_a_string", "nameroot")).toEqual("just_a_string");
    });
    test('We expect get_optional_attribute_from_object(NOT_NULL_FILE, "location") to be "location"', function () {
        expect((0, utils__1_0_0_1.get_optional_attribute_from_multi_type_input_object)(NOT_NULL_FILE, "location")).toEqual(NOT_NULL_FILE["location"]);
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
// boolean_to_int Test
describe('Test boolean_to_int utils', function () {
    test('We expect boolean_to_int(NULL) to be 0', function () {
        expect((0, utils__1_0_0_1.boolean_to_int)(NULL)).toEqual(0);
    });
    test('We expect boolean_to_int(UNDEFINED) to be 0', function () {
        expect((0, utils__1_0_0_1.boolean_to_int)(UNDEFINED)).toEqual(0);
    });
    test('We expect boolean_to_int(TRUE) to be 1', function () {
        expect((0, utils__1_0_0_1.boolean_to_int)(TRUE)).toEqual(1);
    });
    test('We expect boolean_to_int(FALSE) to be 0', function () {
        expect((0, utils__1_0_0_1.boolean_to_int)(FALSE)).toEqual(0);
    });
    test('We expect boolean_to_int("true") to be 1', function () {
        expect((0, utils__1_0_0_1.boolean_to_int)("true")).toEqual(1);
    });
    test('We expect boolean_to_int("false") to be 0', function () {
        expect((0, utils__1_0_0_1.boolean_to_int)("false")).toEqual(0);
    });
});
// get_source_a_or_b Test
describe('Test get_source_a_or_b utils', function () {
    test('We expect get_source_a_or_b("foo", "bar) to be "foo"', function () {
        expect((0, utils__1_0_0_1.get_source_a_or_b)("foo", "bar")).toEqual("foo");
    });
    test('We expect get_source_a_or_b(null, "bar") to be "bar', function () {
        expect((0, utils__1_0_0_1.get_source_a_or_b)(null, "bar")).toEqual("bar");
    });
    test('We expect get_source_a_or_b("foo", null) to be "foo"', function () {
        expect((0, utils__1_0_0_1.get_source_a_or_b)("foo", null)).toEqual("foo");
    });
});
// get first non null input element Test
describe('Test get_first_non_null_input utils', function () {
    test('We expect get_first_non_null_input(["foo", "bar"]) to be "foo"', function () {
        expect((0, utils__1_0_0_1.get_first_non_null_input)(["foo", "bar"])).toEqual("foo");
    });
    test('We expect get_first_non_null_input([null, "bar"]) to be "bar', function () {
        expect((0, utils__1_0_0_1.get_first_non_null_input)([null, "bar"])).toEqual("bar");
    });
    test('We expect get_first_non_null_input(["foo", null]) to be "foo"', function () {
        expect((0, utils__1_0_0_1.get_first_non_null_input)(["foo", null])).toEqual("foo");
    });
});
// get_object_attribute_list_as_bash_array element Test
describe('Test get_object_attribute_list_as_bash_array utils', function () {
    test('We expect get_object_attribute_list_as_bash_array', function () {
        expect((0, utils__1_0_0_1.get_object_attribute_list_as_bash_array)([NOT_NULL_FILE, NOT_NULL_FILE2], "location")).toEqual("( '/path/to/bar' 'far' )");
    });
    test('We expect get_object_attribute_list_as_bash_array', function () {
        expect((0, utils__1_0_0_1.get_object_attribute_list_as_bash_array)([NOT_NULL_FILE, NOT_NULL_FILE2, NULL], "location")).toEqual("( '/path/to/bar' 'far' )");
    });
});
