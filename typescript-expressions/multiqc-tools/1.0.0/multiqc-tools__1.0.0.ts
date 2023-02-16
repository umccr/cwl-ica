// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports

// Backward compatibility with --target es5
import {FastqListRow} from "../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0";

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
export function add_sample_to_sample_name_replace_in_multiqc_cl_config(multiqc_cl_config: string, sample_name_old: string, sample_name_new: string): string {
    /*
    Get the normal RGSM value and then add _normal to it
    */
    if (multiqc_cl_config === undefined || multiqc_cl_config === null || multiqc_cl_config == ""){
        multiqc_cl_config = "{}"
    }

    let multiqc_cl_config_json: any = JSON.parse(multiqc_cl_config)

    if (multiqc_cl_config_json["sample_names_replace"] !== null && multiqc_cl_config_json["sample_names_replace"] !== undefined){
        multiqc_cl_config_json["sample_names_replace"][sample_name_old] = sample_name_new
    } else {
        multiqc_cl_config_json["sample_names_replace"] = <any>{}
        multiqc_cl_config_json["sample_names_replace"][sample_name_old] = sample_name_new
    }

    return <string>JSON.stringify(multiqc_cl_config_json)
}