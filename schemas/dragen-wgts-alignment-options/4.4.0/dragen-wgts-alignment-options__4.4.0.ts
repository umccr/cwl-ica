import { DragenAlignerOptions } from "../../dragen-aligner-options/4.4.0/dragen-aligner-options__4.4.0"
import { DragenMapperOptions } from "../../dragen-mapper-options/4.4.0/dragen-mapper-options__4.4.0"
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
	down sampler normal subsample: 
	Specify the fraction of reads to keep as a subsample of normal input data. The default value is 1.0 (100%).
	*/
	down_sampler_normal_subsample?: number

	/*
	down sampler random seed: 
	Specify the random seed for different runs of the same input data. The default value is 42.
	*/
	down_sampler_random_seed?: boolean

	/*
	down sampler reads: 
	Use only this many RNA fragments for quantification, fusion, variant calling and output to BAM.
	Please note the the entire input dataset is still used for the generation of trimming, fastqc, and mapping metrics.
	*/
	down_sampler_reads?: number

	/*
	down sampler tumor subsample: 
	Specify the fraction of reads to keep as a subsample of tumor input data. The default value is 1.0 (100%).
	*/
	down_sampler_tumor_subsample?: number

	/*
	: 
	Enables the deterministic sort of output alignment records. The default value is true.
	*/
	enable_deterministic_sort?: boolean

	/*
	enable down sampler: 
	Enables the down-sampling of input reads. The default value is false.
	*/
	enable_down_sampler?: boolean

	/*
	: 
	Enables the flagging of duplicate output alignment records.
	*/
	enable_duplicate_marking?: boolean

	/*
	enable fractional down sampler: 
	Subsample a random, fractional percentage of reads from an input file using the fractional downsampler. 
	You can use downsampling to subsample data sets in order to simulate different amounts of sequencing. 
	DRAGEN randomly subsamples reads from primary analysis without any modification (e.g. no trimming, no filtering, etc.).
	*/
	enable_fractional_down_sampler?: boolean

	/*
	enable sampling: 
	Automatically detects paired-end parameters by running a sample through the mapper/aligner.
	*/
	enable_sampling?: boolean

	/*
	fastq offset: 
	Specifies the FASTQ offset to use for the input FASTQ files. The default value is 33.
	*/
	fastq_offset?: number

	/*
	filter flags from output: 
	Filters output alignments with any bits set in val present in the flags field. Hex and decimal values accepted.
	*/
	filter_flags_from_output?: number

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
	Sets the format of the output file from the map/align stage.
	The following values are valid:
	  * SAM
	  * BAM
	  * CRAM
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
	rna ann sj min len: 
	Discard splice junctions which have length less than this value, during the generation of splice junctions
	from an annotations file (GTF/GFF/SJ.out.tab)
	Set to 0 to disable. Default is 6
	*/
	rna_ann_sj_min_len?: number

	/*
	rna library type: 
	Specifies the type of RNA-seq library. The following are the available values:
	IU - Paired-end unstranded library.
	ISR - Paired-end stranded library in which read2 matches the transcript strand (eg, Illumina Stranded Total RNA Prep).
	ISF - Paired-end stranded library in which read1 matches the transcript strand.
	U - Single-end unstranded library.
	SR - Single-end stranded library in which reads are in reverse orientation to the transcript strand (eg, Illumina Stranded Total RNA Prep).
	SF - Single-end stranded library in which reads match the transcript strand.
	A -  DRAGEN examines the first reads pairs in the data set to automatically detect the correct library type. For polya tail trimming, the library type is assumed to be unstranded. Autodetect is the default value.
	*/
	rna_library_type?: string

	/*
	rna mapq unique: 
	Some downstream tools, such as Cufflinks, expect the MAPQ value to be a unique value
	for all uniquely mapped reads.
	*/
	rna_mapq_unique?: number

	/*
	rrna filter contigs: 
	Sets the name of the rRNA sequences to use for filtering.
	If you do not specify a value, the default gl000220 is used for human genome alignments
	with the reference autodetect feature.
	gl000220 is an unplaced contig included in hg19 and hg38 genomes,
	which include a full copy of the rRNA repeat.
	For other genomes, you must include a rRNA decoy contig when creating a hash table.
	*/
	rrna_filter_contig?: string

	/*
	rrna filter enable: 
	Enables the removal of rRNA reads from the output alignment records.
	*/
	rrna_filter_enable?: boolean

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
