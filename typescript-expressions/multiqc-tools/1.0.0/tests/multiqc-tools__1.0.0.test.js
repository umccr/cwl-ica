"use strict";
// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
Object.defineProperty(exports, "__esModule", { value: true });
var multiqc_tools__1_0_0_1 = require("../multiqc-tools__1.0.0");
var MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE = JSON.stringify({
    "sample_names_replace": {
        "L1234567": "Ref_1_Good"
    },
    "another_cl_config_parameter": "foo"
});
var MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE = JSON.stringify({
    "another_cl_config_parameter": "foo"
});
var SAMPLE_NAME_OLD = "L13243546";
var SAMPLE_NAME_NEW = "Ref_2_Bad";
var EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE_OBJ = {
    "sample_names_replace": {
        "L1234567": "Ref_1_Good"
    },
    "another_cl_config_parameter": "foo"
};
EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE_OBJ["sample_names_replace"][SAMPLE_NAME_OLD] = SAMPLE_NAME_NEW;
var EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE = JSON.stringify(EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE_OBJ);
var EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE_OBJ = {
    "sample_names_replace": {},
    "another_cl_config_parameter": "foo"
};
EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE_OBJ["sample_names_replace"][SAMPLE_NAME_OLD] = SAMPLE_NAME_NEW;
var EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE = JSON.stringify(EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE_OBJ);
// Add samplename to multiqc cl config sample name replace
describe('Test Multiqc CL Config add samplename replace', function () {
    test('Add samplename replace to existing cl config', function () {
        expect(JSON.parse((0, multiqc_tools__1_0_0_1.add_sample_to_sample_name_replace_in_multiqc_cl_config)(MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE, SAMPLE_NAME_OLD, SAMPLE_NAME_NEW))).toEqual(JSON.parse(EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE));
    });
    test('Add samplename replace to non-existing cl config samplename replace', function () {
        expect(JSON.parse((0, multiqc_tools__1_0_0_1.add_sample_to_sample_name_replace_in_multiqc_cl_config)(MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE, SAMPLE_NAME_OLD, SAMPLE_NAME_NEW))).toEqual(JSON.parse(EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE));
    });
});
