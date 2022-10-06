"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.add_run_info_and_samplesheet_to_bclconvert_run_configuration = exports.add_run_info_to_bclconvert_run_configuration = exports.get_resource_hints_for_bclconvert_run = exports.create_bcl_configuration_object_for_samplesheet_validation = exports.get_attribute_from_bclconvert_run_configuration = void 0;
// Functions
function get_attribute_from_bclconvert_run_configuration(bclconvert_run_configuration, attribute) {
    var bclconvert_run_configuration_keys = [
        "bcl_conversion_threads",
        "bcl_num_compression_threads",
        "bcl_num_decompression_threads",
        "bcl_num_parallel_tiles",
        "bcl_only_lane",
        "bcl_only_matched_reads",
        "bcl_sampleproject_subdirectories",
        "bcl_validate_sample_sheet_only",
        "exclude_tiles",
        "fastq_compression_format",
        "fastq_gzip_compression_level",
        "first_tile_only",
        "no_lane_splitting",
        "num_unknown_barcodes_reported",
        "ora_reference",
        "output_directory",
        "output_legacy_stats",
        "run_info",
        "sample_name_column_enabled",
        "samplesheet",
        "shared_thread_odirect_output",
        "strict_mode",
        "tiles"
    ];
    /*
    Given a BclconvertRunConfiguration object and an attribute name, return the attribute of the object
    Best option for collecting all of the keys was stackoverflow.com/questions/43909566/get-keys-of-a-typescript-interface-as-array-of-strings
    Bit of WET typing but best option I can see
    */
    // Confirm this is a genuine property of the interface
    if (!bclconvert_run_configuration_keys.includes(attribute)) {
        throw new Error("Error! BclconvertRunConfiguration object does not have attribute '".concat(attribute, "'"));
    }
    // If not in this object, return null
    if (!bclconvert_run_configuration.hasOwnProperty(attribute)) {
        return null;
    }
    // Otherwise access and return property
    return bclconvert_run_configuration[attribute];
}
exports.get_attribute_from_bclconvert_run_configuration = get_attribute_from_bclconvert_run_configuration;
function create_bcl_configuration_object_for_samplesheet_validation(bclconvert_run_configuration, samplesheet, run_info) {
    /*
    Only need the samplesheet and the run info, set bcl_validate_sample_sheet_only to true and
    also remove ora reference if provided since we do not want to mount unnecessary data onto the task
    */
    return {
        samplesheet: samplesheet,
        run_info: run_info,
        bcl_validate_sample_sheet_only: true,
        ora_reference: bclconvert_run_configuration["ora_reference"],
        bcl_conversion_threads: bclconvert_run_configuration["bcl_conversion_threads"],
        bcl_num_compression_threads: bclconvert_run_configuration["bcl_num_compression_threads"],
        bcl_num_decompression_threads: bclconvert_run_configuration["bcl_num_decompression_threads"],
        bcl_num_parallel_tiles: bclconvert_run_configuration["bcl_num_parallel_tiles"],
        bcl_only_lane: bclconvert_run_configuration["bcl_only_lane"],
        bcl_only_matched_reads: bclconvert_run_configuration["bcl_only_matched_reads"],
        bcl_sampleproject_subdirectories: bclconvert_run_configuration["bcl_sampleproject_subdirectories"],
        exclude_tiles: bclconvert_run_configuration["exclude_tiles"],
        fastq_gzip_compression_level: bclconvert_run_configuration["fastq_gzip_compression_level"],
        first_tile_only: bclconvert_run_configuration["first_tile_only"],
        fastq_compression_format: bclconvert_run_configuration["fastq_compression_format"],
        no_lane_splitting: bclconvert_run_configuration["no_lane_splitting"],
        num_unknown_barcodes_reported: bclconvert_run_configuration["num_unknown_barcodes_reported"],
        output_directory: bclconvert_run_configuration["output_directory"],
        output_legacy_stats: bclconvert_run_configuration["output_legacy_stats"],
        sample_name_column_enabled: bclconvert_run_configuration["sample_name_column_enabled"],
        shared_thread_odirect_output: bclconvert_run_configuration["shared_thread_odirect_output"],
        strict_mode: bclconvert_run_configuration["strict_mode"],
        tiles: bclconvert_run_configuration["tiles"]
    };
}
exports.create_bcl_configuration_object_for_samplesheet_validation = create_bcl_configuration_object_for_samplesheet_validation;
function get_resource_hints_for_bclconvert_run(inputs, resource_name) {
    /*
    Collect resource requirements for bclconvert run based on bclconvert run configuration
    */
    // Confirm input resource name is one of the available resource requirements
    var available_resource_requirements = [
        "ilmn-tes-resources-tier",
        "ilmn-tes-resources-type",
        "ilmn-tes-resources-size",
        "coresMin",
        "ramMin",
        "dockerPull"
    ];
    // Set resource requirements by run time
    var resource_requirements_by_run_type = {
        "validation": {
            "ilmn-tes-resources-tier": "standard",
            "ilmn-tes-resources-type": "standard",
            "ilmn-tes-resources-size": "medium",
            "coresMin": 1,
            "ramMin": 4000,
            "dockerPull": "ghcr.io/umccr/bcl-convert:4.0.3"
        },
        "convert_cpu": {
            "ilmn-tes-resources-tier": "standard",
            "ilmn-tes-resources-type": "standardHiCpu",
            "ilmn-tes-resources-size": "large",
            "coresMin": 72,
            "ramMin": 64000,
            "dockerPull": "ghcr.io/umccr/bcl-convert:4.0.3"
        },
        "convert_fpga": {
            "ilmn-tes-resources-tier": "standard",
            "ilmn-tes-resources-type": "fpga",
            "ilmn-tes-resources-size": "medium",
            "coresMin": 16,
            "ramMin": 240000,
            "dockerPull": "699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:4.0.3"
        }
    };
    if (available_resource_requirements.indexOf(resource_name) === -1) {
        throw new Error("Resource name parameter must be one of ".concat(available_resource_requirements.join(", "), " but got '").concat(resource_name, "'"));
    }
    if (inputs.bcl_validate_sample_sheet_only) {
        return resource_requirements_by_run_type["validation"][resource_name];
    }
    else if (inputs.fastq_compression_format === "dragen" || inputs.fastq_compression_format === "dragen-interleaved") {
        return resource_requirements_by_run_type["convert_fpga"][resource_name];
    }
    else {
        return resource_requirements_by_run_type["convert_cpu"][resource_name];
    }
}
exports.get_resource_hints_for_bclconvert_run = get_resource_hints_for_bclconvert_run;
function add_run_info_to_bclconvert_run_configuration(bclconvert_run_configuration, run_info) {
    var bclconvert_run_configuration_out = __assign({}, bclconvert_run_configuration);
    if (bclconvert_run_configuration_out.run_info === undefined || bclconvert_run_configuration_out.run_info === null) {
        bclconvert_run_configuration_out.run_info = run_info;
    }
    return bclconvert_run_configuration_out;
}
exports.add_run_info_to_bclconvert_run_configuration = add_run_info_to_bclconvert_run_configuration;
function add_run_info_and_samplesheet_to_bclconvert_run_configuration(bclconvert_run_configuration, run_info, samplesheet) {
    var bclconvert_run_configuration_out = __assign({}, bclconvert_run_configuration);
    if (bclconvert_run_configuration_out.run_info === undefined || bclconvert_run_configuration_out.run_info === null) {
        bclconvert_run_configuration_out.run_info = run_info;
    }
    if (bclconvert_run_configuration_out.samplesheet === undefined || bclconvert_run_configuration_out.samplesheet === null) {
        bclconvert_run_configuration_out.samplesheet = samplesheet;
    }
    return bclconvert_run_configuration_out;
}
exports.add_run_info_and_samplesheet_to_bclconvert_run_configuration = add_run_info_and_samplesheet_to_bclconvert_run_configuration;
