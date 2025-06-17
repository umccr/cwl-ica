import { DragenAlignerOptions } from "../../dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4"
import { DragenMapperOptions } from "../../dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4"
import { DragenQcCoverage } from "../../dragen-qc-coverage/1.0.0/dragen-qc-coverage__1.0.0"

export enum OutputFormat {
	"SAM" = "SAM",
	"BAM" = "BAM",
	"CRAM" = "CRAM"
}

export interface DragenWgtsAlignmentOptions {
	/*
	aligner: 
	Specifies any options under the [Aligner] configuration section
	*/
	aligner?: DragenAlignerOptions

	/*
	append read index to name: 
	By default, DRAGEN names both mate ends of pairs the same. When set to true, DRAGEN appends /1 and /2 to the two ends.
	*/
	append_read_index_to_name?: boolean

	/*
	: 
	Enables the flagging of duplicate output alignment records.
	*/
	enable_duplicate_marking?: boolean

	/*
	enable sampling: 
	Automatically detects paired-end parameters by running a sample through the mapper/aligner.
	*/
	enable_sampling?: boolean

	/*
	filter flags from output: 
	Filters output alignments with any bits set in val present in the flags field. Hex and decimal values accepted.
	*/
	filter_flags_from_output?: boolean

	/*
	generate md tags: 
	Generates MD tags with alignment output records. The default value is false.
	*/
	generate_md_tags?: boolean

	/*
	generate sa tags: 
	Generates SA:Z tags for records that have chimeric or supplemental alignments.
	*/
	generate_sa_tags?: boolean

	/*
	generate zs tags: 
	Generate ZS tags for alignment output records. The default value is false.
	*/
	generate_zs_tags?: boolean

	/*
	input qname suffix delimiter: 
	Controls the delimiter used for append-read-index-to-name and for detecting matching pair names with BAM input.
	*/
	input_qname_suffix_delimiter?: string

	/*
	mapper: 
	Specifies any options under the [Mapper] configuration section
	*/
	mapper?: DragenMapperOptions

	/*
	output format: 
	Sets the format of the output file from the map/align stage. The following values are valid
	*/
	output_format?: OutputFormat

	/*
	preserve bqsr tags: 
	Determines whether to preserve BI and BD flags from the input BAM file, which can cause problems with hard clipping.
	*/
	preserve_bqsr_tags?: boolean

	/*
	preserve map align order: 
	Produces output file that preserves original order of reads in the input file.
	*/
	preserve_map_align_order?: boolean

	/*
	qc coverage: 
	Up to three regions can be specified for coverage region reports.
	*/
	qc_coverage?: DragenQcCoverage[]

	/*
	ref sequence filter: 
	Outputs only reads mapping to the reference sequence.
	*/
	ref_sequence_filter?: boolean

	/*
	remove duplicates: 
	If true, the option removes duplicate alignment records instead of only flagging them.
	*/
	remove_duplicates?: boolean

	/*
	sample size: 
	Specifies number of reads to sample when enable-sampling is true.
	*/
	sample_size?: number

	/*
	strip input qname suffixes: 
	Determines whether to strip read-index suffixes (eg, /1 and /2) from input QNAMEs. If set to false, the option preserves entire name.
	*/
	strip_input_qname_suffixes?: boolean
}
