// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports

// Backward compatibility with --target es5
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
        return input_object[attribute]
    }

}

export function get_bool_value_as_str(input_bool: boolean | null): string {
    if (is_not_null(input_bool) && input_bool){
        return "true"
    } else {
        return "false"
    }
}
