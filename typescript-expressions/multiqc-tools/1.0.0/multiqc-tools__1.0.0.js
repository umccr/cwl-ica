"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
exports.add_sample_to_sample_name_replace_in_multiqc_cl_config = void 0;
// Functions
function add_sample_to_sample_name_replace_in_multiqc_cl_config(multiqc_cl_config, sample_name_old, sample_name_new) {
    /*
    Get the normal RGSM value and then add _normal to it
    */
    if (multiqc_cl_config === undefined || multiqc_cl_config === null || multiqc_cl_config == "") {
        multiqc_cl_config = "{}";
    }
    var multiqc_cl_config_json = JSON.parse(multiqc_cl_config);
    if (multiqc_cl_config_json["sample_names_replace"] !== null && multiqc_cl_config_json["sample_names_replace"] !== undefined) {
        multiqc_cl_config_json["sample_names_replace"][sample_name_old] = sample_name_new;
    }
    else {
        multiqc_cl_config_json["sample_names_replace"] = {};
        multiqc_cl_config_json["sample_names_replace"][sample_name_old] = sample_name_new;
    }
    return JSON.stringify(multiqc_cl_config_json);
}
exports.add_sample_to_sample_name_replace_in_multiqc_cl_config = add_sample_to_sample_name_replace_in_multiqc_cl_config;
