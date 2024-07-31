"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
exports.is_not_null = is_not_null;
exports.get_attribute_from_optional_input = get_attribute_from_optional_input;
exports.get_optional_attribute_from_object = get_optional_attribute_from_object;
exports.get_bool_value_as_str = get_bool_value_as_str;
exports.boolean_to_int = boolean_to_int;
exports.get_optional_attribute_from_multi_type_input_object = get_optional_attribute_from_multi_type_input_object;
exports.get_source_a_or_b = get_source_a_or_b;
exports.get_first_non_null_input = get_first_non_null_input;
exports.get_attribute_list_from_object_list = get_attribute_list_from_object_list;
exports.get_str_list_as_bash_array = get_str_list_as_bash_array;
exports.get_object_attribute_list_as_bash_array = get_object_attribute_list_as_bash_array;
// Functions
function is_not_null(input_obj) {
    /*
    Determine if input object is defined and is not null
    */
    return !(input_obj === null || input_obj === undefined);
}
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
function get_optional_attribute_from_object(input_object, attribute) {
    /*
    Get attribute from object, if attribute is not defined return null
    Assume the input object is an object of key value pairs where we know the key is of type string
    stackoverflow.com/questions/56833469/typescript-error-ts7053-element-implicitly-has-an-any-type
    */
    if (input_object.hasOwnProperty(attribute)) {
        return input_object[attribute];
    }
    else {
        return null;
    }
}
function get_bool_value_as_str(input_bool) {
    if (is_not_null(input_bool) && input_bool) {
        return "true";
    }
    else {
        return "false";
    }
}
function boolean_to_int(input_bool) {
    if (is_not_null(input_bool) && String(input_bool).toLowerCase() === "true") {
        return 1;
    }
    else {
        return 0;
    }
}
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
        // Object is likely actually a str
        return object;
    }
}
function get_source_a_or_b(input_a, input_b) {
    /*
    Get the first input parameter if it is not null
    Otherwise return the second parameter
    Otherwise return null
    */
    if (is_not_null(input_a)) {
        return input_a;
    }
    else if (is_not_null(input_b)) {
        return input_b;
    }
    else {
        return null;
    }
}
function get_first_non_null_input(inputs) {
    /*
    Get first element of the array that is not null
    */
    for (var _i = 0, inputs_1 = inputs; _i < inputs_1.length; _i++) {
        var input_element = inputs_1[_i];
        if (is_not_null(input_element)) {
            return input_element;
        }
    }
    return null;
}
function get_attribute_list_from_object_list(obj_list, attribute) {
    /*
    Get attribute from list of objects
    If an object is null, it is not included in the return list
    */
    return obj_list.filter(function (x) { return x !== null; }).map(function (x) { return get_optional_attribute_from_object(x, attribute); });
}
function get_str_list_as_bash_array(input_list, item_wrap) {
    /*
    Convert a list of strings to a bash array, if the list is not defined return null
    */
    if (input_list === null) {
        return null;
    }
    if (item_wrap === null) {
        return "( ".concat(input_list.map(function (x) { return "'".concat(item_wrap).concat(x).concat(item_wrap, "'"); }).join(' '), " )");
    }
    return "( ".concat(input_list.map(function (x) { return "'".concat(x, "'"); }).join(' '), " )");
}
function get_object_attribute_list_as_bash_array(obj_list, attribute) {
    /*
    Get attribute from list of objects and convert to a bash array
    Do not include null values in the array
    */
    return get_str_list_as_bash_array(get_attribute_list_from_object_list(obj_list, attribute).filter(function (x) { return x !== null; }));
}
