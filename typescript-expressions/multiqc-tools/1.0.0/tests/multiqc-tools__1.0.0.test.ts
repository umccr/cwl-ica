// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports

import {add_sample_to_sample_name_replace_in_multiqc_cl_config} from "../multiqc-tools__1.0.0";

const MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE = JSON.stringify(
    {
        "sample_names_replace": {
            "L1234567": "Ref_1_Good"
        },
        "another_cl_config_parameter": "foo"
    }
)

const MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE = JSON.stringify(
    {
        "another_cl_config_parameter": "foo"
    }
)

const SAMPLE_NAME_OLD: string = "L13243546"
const SAMPLE_NAME_NEW: string = "Ref_2_Bad"

let EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE_OBJ = {
    "sample_names_replace": <any>{
        "L1234567": "Ref_1_Good"

    },
    "another_cl_config_parameter": "foo"
}
EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE_OBJ["sample_names_replace"][SAMPLE_NAME_OLD] = SAMPLE_NAME_NEW

const EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE = JSON.stringify(
    EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE_OBJ
)

let EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE_OBJ = {
    "sample_names_replace": <any>{},
    "another_cl_config_parameter": "foo"
}
EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE_OBJ["sample_names_replace"][SAMPLE_NAME_OLD] = SAMPLE_NAME_NEW

const EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE = JSON.stringify(
    EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE_OBJ
)


// Add samplename to multiqc cl config sample name replace
describe('Test Multiqc CL Config add samplename replace', function() {
    test('Add samplename replace to existing cl config', () => {
        expect(
            JSON.parse(
                add_sample_to_sample_name_replace_in_multiqc_cl_config(
                    MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE,
                    SAMPLE_NAME_OLD,
                    SAMPLE_NAME_NEW
                )
            )
        ).toEqual(
                JSON.parse(
                    EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITH_SAMPLENAME_REPLACE
                )
        )
    })
    test('Add samplename replace to non-existing cl config samplename replace', () => {
        expect(
            JSON.parse(
                add_sample_to_sample_name_replace_in_multiqc_cl_config(
                    MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE,
                    SAMPLE_NAME_OLD,
                    SAMPLE_NAME_NEW
                )
            )
        ).toEqual(
            JSON.parse(
                EXPECTED_OUTPUT_MULTIQC_CL_CONFIG_STR_WITHOUT_SAMPLENAME_REPLACE
            )
        )
    })
})
