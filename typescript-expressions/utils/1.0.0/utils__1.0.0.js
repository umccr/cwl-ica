"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_bool_value_as_str = exports.get_attribute_from_optional_input = exports.is_not_null = void 0;
// Functions
function is_not_null(input_obj) {
    /*
    Determine if input object is defined and is not null
    */
    return !(input_obj === null || input_obj === undefined);
}
exports.is_not_null = is_not_null;
function get_attribute_from_optional_input(input_object, attribute) {
    /*
    Get attribute from optional input -
    If input is not defined, then return null
    */
    if (input_object === null || input_object === undefined) {
        return null;
    }
    else {
        return input_object[attribute];
    }
}
exports.get_attribute_from_optional_input = get_attribute_from_optional_input;
function get_bool_value_as_str(input_bool) {
    if (is_not_null(input_bool) && input_bool) {
        return "true";
    }
    else {
        return "false";
    }
}
exports.get_bool_value_as_str = get_bool_value_as_str;
