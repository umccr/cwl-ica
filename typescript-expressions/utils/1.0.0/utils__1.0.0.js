"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_optional_attribute_from_multi_type_input_object = exports.boolean_to_int = exports.get_bool_value_as_str = exports.get_optional_attribute_from_object = exports.get_attribute_from_optional_input = exports.is_not_null = void 0;
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
        return get_optional_attribute_from_object(input_object, attribute);
    }
}
exports.get_attribute_from_optional_input = get_attribute_from_optional_input;
function get_optional_attribute_from_object(input_object, attribute) {
    /*
    Get attribute from object, if attribute is not defined return null
    */
    if (input_object.hasOwnProperty(attribute)) {
        return input_object[attribute];
    }
    else {
        return null;
    }
}
exports.get_optional_attribute_from_object = get_optional_attribute_from_object;
function get_bool_value_as_str(input_bool) {
    if (is_not_null(input_bool) && input_bool) {
        return "true";
    }
    else {
        return "false";
    }
}
exports.get_bool_value_as_str = get_bool_value_as_str;
function boolean_to_int(input_bool) {
    if (is_not_null(input_bool) && String(input_bool).toLowerCase() === "true") {
        return 1;
    }
    else {
        return 0;
    }
}
exports.boolean_to_int = boolean_to_int;
function get_optional_attribute_from_multi_type_input_object(object, attribute) {
    /*
    Get attribute from optional input
    */
    if (object === null || object === undefined) {
        return null;
    }
    else if (typeof object === "object") {
        // Get attribute from optional input
        return get_attribute_from_optional_input(object, attribute);
    }
    else {
        // Object is likely actually an str
        return object;
    }
}
exports.get_optional_attribute_from_multi_type_input_object = get_optional_attribute_from_multi_type_input_object;
