// Author: Alexis Lucattini
// For assistance on generation of typescript expression tests
// In CWL, visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript

// Imports
import {
    dragen_merge_options,
    dragen_to_config_toml,
    filter_object_by_keys, generate_fastq_list_csv, get_dragen_wgts_dna_alignment_stage_options_from_pipeline,
    json_to_toml,
    toml_to_json
} from "../dragen-tools__4.4.0";

// Data imports
// Read in the file data/dragen_default_config.cfg
import fs from 'fs';
import path from 'path';
import {
    DragenWgtsAlignmentOptions
} from "../../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4";
import {DragenReference} from "../../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0";
import {FileProperties as IFile} from "cwl-ts-auto/dist/FileProperties";
import {DragenInputSequenceType} from "../dragen-tools_custom_input_interfaces";

const config_file_path = path.join(__dirname, 'data', 'dragen_default_config.cfg');
const config_file_data = fs.readFileSync(config_file_path, 'utf8');

const config_json_file_path = path.join(__dirname, 'data', 'dragen_default_config.json');
const config_json_file_data = fs.readFileSync(config_json_file_path, 'utf8');

const config_thin_file_path = path.join(__dirname, 'data', 'dragen_default_config.thin.cfg');
const config_thin_file_data = fs.readFileSync(config_thin_file_path, 'utf8');

const fastq_list_row_json = path.join(__dirname, 'data', 'fastq_list_row.json');
const fastq_list_row_data = JSON.parse(fs.readFileSync(fastq_list_row_json, 'utf8'));
const fastq_list_row_expected_contents_file = path.join(__dirname, 'data', 'fastq_list_row_expected.csv');
const fastq_list_row_expected_contents_data = fs.readFileSync(fastq_list_row_expected_contents_file, 'utf-8');


// Toml to JSON conversion test
describe('Test toml file', function () {
    test('Compare full default cfg to expected output json', () => {
        expect(toml_to_json(config_file_data)).toEqual(JSON.parse(config_json_file_data))
    })
})

// JSON to TOML conversion test
describe('Test json file', function () {
    test('Compare output json to shrinked toml', () => {
        expect(dragen_to_config_toml(JSON.parse(config_json_file_data))).toEqual(config_thin_file_data)
    })
})


const dragen_merge_list = [
    {
        "enable_cnv": true,
        "dbsnp": null,
        "enable_methylation_calling": null,
        "enable_variant_deduplication": null,
        "enable_vcf_compression": null,
        "enable_vcf_indexing": null,
        "vd_eh_vcf": null,
        "vd_output_match_log": null,
        "vd_small_variant_vcf": null,
        "vd_sv_vcf": null
    },
    {
        "enable_vcf_compression": true,
        "enable_vcf_indexing": true,
        "dbsnp": null,
        "enable_cnv": null,
        "enable_methylation_calling": null,
        "enable_variant_deduplication": null,
        "vd_eh_vcf": null,
        "vd_output_match_log": null,
        "vd_small_variant_vcf": null,
        "vd_sv_vcf": null
    }
];

const expected_output = {
    "dbsnp": null,
    "enable_cnv": true,
    "enable_methylation_calling": null,
    "enable_variant_deduplication": null,
    "enable_vcf_compression": true,
    "enable_vcf_indexing": true,
    "vd_eh_vcf": null,
    "vd_output_match_log": null,
    "vd_small_variant_vcf": null,
    "vd_sv_vcf": null,
}

describe('Test merge file', function () {
    test('Compare output json to shrinked toml', () => {
        expect(dragen_merge_options(dragen_merge_list)).toEqual(expected_output)
    })
})

const merge_filter_object_1 = {
    "enable_vcf_indexing": true,
    "fastq_offset": 33,
    "filter_flags_from_output": 0,
    "generate_zs_tags": false,
    "ht_anchor_bin_bits": 0,
    "ht_cost_coeff_seed_freq": 0.5,
}

const merge_filter_object_2 = {
    "enable_cnv": true,
    "enable_vcf_compression": true,
    "enable_vcf_indexing": false,
}

const expected_filter_output = {
    "enable_vcf_indexing": true
}

describe('Test filter', function () {
    test('Test filtering object keys to subset', () => {
        expect(filter_object_by_keys(merge_filter_object_1, merge_filter_object_2)).toEqual(expected_filter_output)
    })
})


describe('Test alignment options', function () {
    test('alignment options to toml', () => {
        const input_self = [
            "L2301197",
            {
                "name": "hg38",
                "structure": "linear",
                "tarball": {
                    "class": "File",
                    "location": "file:///ces/scheduler/run/f2518f31-0334-468c-9c9d-4f02df342244/data/92bc8608-9393-44b4-bf16-fb0c5a12269a/fil.16b42f68112b42775bef08dd94aa0ada/chm13_v2-cnv.graph.hla.methyl_cg.rna-11-r5.0-1.tar.gz",
                    "size": 32324168044,
                    "basename": "chm13_v2-cnv.graph.hla.methyl_cg.rna-11-r5.0-1.tar.gz",
                    "nameroot": "chm13_v2-cnv.graph.hla.methyl_cg.rna-11-r5.0-1.tar",
                    "nameext": ".gz"
                }
            },
            {
                "class": "File",
                "location": "file:///ces/scheduler/run/f2518f31-0334-468c-9c9d-4f02df342244/data/92bc8608-9393-44b4-bf16-fb0c5a12269a/fil.3f573b26c22c4507077908dcb063a68d/ora_reference_v2.tar.gz",
                "size": 2398461386,
                "basename": "ora_reference_v2.tar.gz",
                "nameroot": "ora_reference_v2.tar",
                "nameext": ".gz"
            },
            {
                "fastq_list_rows": [
                    {
                        "rgid": "L2301197",
                        "rglb": "L2301197",
                        "rgsm": "L2301197",
                        "lane": 1,
                        "read_1": {
                            "class": "File",
                            "location": "file:///ces/scheduler/run/f2518f31-0334-468c-9c9d-4f02df342244/data/ea19a3f5-ec7c-4940-a474-c31cd91dbad4/fil.611b6f99dda240e0c65f08dcd12b7923/MDX230428_L2301197_S7_L004_R1_001.fastq.ora",
                            "size": 8156709208,
                            "basename": "MDX230428_L2301197_S7_L004_R1_001.fastq.ora",
                            "nameroot": "MDX230428_L2301197_S7_L004_R1_001.fastq",
                            "nameext": ".ora"
                        },
                        "read_2": {
                            "class": "File",
                            "location": "file:///ces/scheduler/run/f2518f31-0334-468c-9c9d-4f02df342244/data/ea19a3f5-ec7c-4940-a474-c31cd91dbad4/fil.7cf1ce7bb9d948c8850f08dcd0cf93fc/MDX230428_L2301197_S7_L004_R2_001.fastq.ora",
                            "size": 11780760311,
                            "basename": "MDX230428_L2301197_S7_L004_R2_001.fastq.ora",
                            "nameroot": "MDX230428_L2301197_S7_L004_R2_001.fastq",
                            "nameext": ".ora"
                        },
                        "rgcn": null,
                        "rgds": null,
                        "rgdt": null,
                        "rgpl": null
                    }
                ]
            },
            {
                "enable_duplicate_marking": true,
                "aligner": {
                    "aln_min_score": null,
                    "clip_pe_overhang": null,
                    "dedup_min_qual": null,
                    "en_alt_hap_aln": null,
                    "en_chimeric_aln": null,
                    "gap_ext_pen": null,
                    "gap_open_pen": null,
                    "global": null,
                    "hard_clip_tags": null,
                    "hard_clips": null,
                    "map_orientations": null,
                    "mapq_floor_1snp": null,
                    "mapq_max": null,
                    "mapq_strict_sjs": null,
                    "match_n_score": null,
                    "match_score": null,
                    "max_rescues": null,
                    "min_overhang": null,
                    "min_score_coeff": null,
                    "mismatch_pen": null,
                    "no_noncan_motifs": null,
                    "no_unclip_score": null,
                    "no_unpaired": null,
                    "pe_max_penalty": null,
                    "pe_orientation": null,
                    "rescue_sigmas": null,
                    "sec_aligns": null,
                    "sec_aligns_hard": null,
                    "sec_phred_delta": null,
                    "sec_score_delta": null,
                    "supp_aligns": null,
                    "supp_as_sec": null,
                    "supp_min_score_adj": null,
                    "unclip_score": null,
                    "unpaired_pen": null
                },
                "append_read_index_to_name": null,
                "enable_deterministic_sort": null,
                "enable_down_sampler": null,
                "enable_sampling": null,
                "fastq_offset": null,
                "filter_flags_from_output": null,
                "generate_md_tags": null,
                "generate_sa_tags": null,
                "generate_zs_tags": null,
                "input_qname_suffix_delimiter": null,
                "mapper": {
                    "ann_sj_max_indel": null,
                    "edit_chain_limit": null,
                    "edit_mode": null,
                    "edit_read_len": null,
                    "edit_seed_num": null,
                    "map_orientations": null,
                    "max_intron_bases": null,
                    "min_intron_bases": null,
                    "seed_density": null
                },
                "output_format": null,
                "preserve_bqsr_tags": null,
                "preserve_map_align_order": null,
                "qc_coverage": null,
                "ref_sequence_filter": null,
                "remove_duplicates": null,
                "rna_library_type": null,
                "rna_mapq_unique": null,
                "rrna_filter_contig": null,
                "rrna_filter_enable": null,
                "sample_size": null,
                "strip_input_qname_suffixes": null
            },
            "/opt/instance-identity",
            "{\"fastq_offset\":33,\"enable_deterministic_sort\":true,\"filter_flags_from_output\":0,\"generate_zs_tags\":false,\"repeat_genotype_enable\":false,\"repeat_genotype_specs\":null,\"rna_mapq_unique\":0,\"rna_ann_sj_min_len\":6,\"rna_library_type\":\"A\",\"rna_quantification_gc_bias\":true,\"rna_quantification_fld_max\":1000,\"rna_quantification_fld_mean\":250,\"rna_quantification_fld_sd\":25,\"rna_quantification_tlen_min\":500,\"vc_max_alternate_alleles\":6,\"vc_emit_zero_coverage_intervals\":true,\"enable_vcf_indexing\":true,\"vc_decoy_contigs\":[\"NC_007605\",\"hs37d5\",\"chrUn_KN707*v1_decoy\",\"chrUn_JTFH0100*v1_decoy\",\"KN707*.1\",\"JTFH0100*.1\",\"chrEBV\",\"CMV\",\"HBV\",\"HCV*\",\"HIV*\",\"KSHV\",\"HTLV*\",\"MCV\",\"SV40\",\"HPV*\"],\"sv_filtered_contigs\":[\"*_random\",\"chrUn_*\",\"*_alt\",\"HLA-*\",\"GL*\"],\"ht_ref_seed_interval\":1,\"ht_max_ext_seed_len\":0,\"ht_max_seed_freq\":16,\"ht_pri_max_seed_freq\":0,\"ht_max_seed_freq_len\":98,\"ht_target_seed_freq\":4,\"ht_soft_seed_freq_cap\":12,\"ht_max_dec_factor\":1,\"ht_cost_coeff_seed_len\":1,\"ht_cost_coeff_seed_freq\":0.5,\"ht_cost_penalty\":0,\"ht_cost_penalty_incr\":0.7,\"ht_rand_hit_hifreq\":1,\"ht_rand_hit_extend\":8,\"ht_repair_strategy\":0,\"ht_anchor_bin_bits\":0,\"ht_min_repair_prob\":0.2,\"ht_max_table_chunks\":0,\"ht_size\":\"0GB\",\"ht_mem_limit\":\"0GB\",\"mapper\":{\"edit_mode\":0,\"edit_seed_num\":6,\"edit_read_len\":100,\"edit_chain_limit\":29,\"map_orientations\":0,\"min_intron_bases\":20,\"max_intron_bases\":200000,\"ann_sj_max_indel\":10},\"aligner\":{\"mismatch_pen\":4,\"gap_open_pen\":6,\"gap_ext_pen\":1,\"pe_orientation\":0,\"pe_max_penalty\":255,\"mapq_max\":60,\"sec_phred_delta\":0,\"sec_aligns_hard\":-1,\"supp_as_sec\":0,\"hard_clips\":6,\"hard_clip_tags\":1,\"dedup_min_qual\":15,\"no_unpaired\":0,\"sec_score_delta\":0,\"en_chimeric_aln\":1,\"en_alt_hap_aln\":1,\"mapq_floor_1snp\":0,\"mapq_strict_sjs\":0,\"no_noncan_motifs\":0,\"min_overhang\":6}}"
        ]
    })
})


describe("Test Fastq List rows", function(){
    test("Test Fastq List Rows to Csv", () => {
        expect(generate_fastq_list_csv(fastq_list_row_data).contents).toEqual(fastq_list_row_expected_contents_data)
    })
})