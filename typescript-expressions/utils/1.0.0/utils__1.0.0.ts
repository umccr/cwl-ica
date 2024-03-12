// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports

// Backward compatibility with --target es5
import {type} from "os";

declare global {
    interface Set<T> {
    }

    interface Map<K, V> {
    }

    interface WeakSet<T> {
    }

    interface WeakMap<K extends object, V> {
    }
}

// Functions
export function is_not_null(input_obj: any): boolean {
    /*
    Determine if input object is defined and is not null
    */
    return !(input_obj === null || input_obj === undefined);
}

export function get_attribute_from_optional_input(input_object: any, attribute: string){
    /*
    Get attribute from optional input -
    If input is not defined, then return null
    */

    if (input_object === null || input_object === undefined){
        return null
    } else {
        return get_optional_attribute_from_object(input_object, attribute)
    }
}


export function get_optional_attribute_from_object(input_object: {[key: string]: any}, attribute: string){

    /*
    Get attribute from object, if attribute is not defined return null
    Assume the input object is an object of key value pairs where we know the key is of type string
    stackoverflow.com/questions/56833469/typescript-error-ts7053-element-implicitly-has-an-any-type
    */
    if (input_object.hasOwnProperty(attribute)){
        return input_object[attribute]
    } else {
        return null
    }

}

export function get_bool_value_as_str(input_bool: boolean | null): string {
    if (is_not_null(input_bool) && input_bool){
        return "true"
    } else {
        return "false"
    }
}

export function boolean_to_int(input_bool: boolean | string | null | undefined): Number {
    if (is_not_null(input_bool) && String(input_bool).toLowerCase() === "true"){
        return 1
    } else {
        return 0
    }
}

export function get_optional_attribute_from_multi_type_input_object(object: any, attribute: string){
    /*
    Get attribute from optional input
    */

    if (object === null || object === undefined){
        return null
    } else if (typeof object === "object") {
        // Get attribute from optional input
        return get_attribute_from_optional_input(object, attribute)
    } else {
        // Object is likely actually a str
        return object
    }
}

export function get_source_a_or_b(input_a: any, input_b: any): any | null {
    /*
    Get the first input parameter if it is not null
    Otherwise return the second parameter
    Otherwise return null
    */
    if (is_not_null(input_a)){
        return input_a
    } else if (is_not_null(input_b)){
        return input_b
    } else {
        return null
    }
}

export function get_first_non_null_input(inputs: any[]): any | null {
    /*
    Get first element of the array that is not null
    */
    for (var input_element of inputs){
        if (is_not_null(input_element)){
            return input_element
        }
    }
    return null
}
