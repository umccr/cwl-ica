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

export function get_optional_attribute_from_object(input_object: object, attribute: string){
    /*
    Get attribute from object, if attribute is not defined return null
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
        // Object is likely actually an str
        return object
    }
}