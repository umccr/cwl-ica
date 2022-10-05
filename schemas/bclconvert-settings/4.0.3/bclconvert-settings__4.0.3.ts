export interface BclconvertSettings {
	/*
	adapter_behavior: 
	Defines whether fastqs are masked or trimmed of Read 1 and/or Read 2 adapter sequence(s). 
	When AdapterRead1 or AdapterRead2 is not specified, this setting cannot be specified.
	*	mask — masks the identified Read 1 and/or Read 2 sequence(s) with N.
	* trim - trims the identified Read 1 and/or Read 2 sequence(s)
	*/
	adapter_behavior?: string

	/*
	adapter_read_1: 
	The sequence of the Read 1 adapter to be masked or trimmed.
	To trim multiple adapters, separate the sequences with a plus sign (+) to indicate 
	independent adapters that must be independently assessed for masking or trimming for each read.
	Allowed characters: A, T, C, G.
	*/
	adapter_read_1?: string

	/*
	adapter_read_2: 
	The sequence of the Read 2 adapter to be masked or trimmed.
	To trim multiple adapters, separate the sequences with a plus sign (+) to indicate independent adapters 
	that must be independently assessed for masking or trimming for each read.
	Allowed characters: A, T, C, G.
	*/
	adapter_read_2?: string

	/*
	adapter_stringency: 
	The minimum match rate that triggers masking or trimming. 
	This value is calculated as MatchCount / (MatchCount+MismatchCount). 
	Accepted values are 0.5–1. 
	The default value of 0.9 indicates that only reads with ≥ 90% sequence identity with the adapter are trimmed.
	*/
	adapter_stringency?: number

	/*
	barcode_mismatches_index_1: 
	Allow mismatch of length x in the i7 index sequence
	*/
	barcode_mismatches_index_1?: number

	/*
	barcode_mismatches_index_2: 
	Allow mismatch of length x in the i5 index sequence
	*/
	barcode_mismatches_index_2?: number

	/*
	create_fastq_for_index_reads: 
	If set to 1, output FASTQ files for index reads as well as genomic reads.
	*/
	create_fastq_for_index_reads?: boolean

	/*
	fastq compression format: 
	Beta feature, compress BCL files:
	  If the value is gzip, output FASTQ.GZ.
	  If the value is dragen, output FASTQ.ORA not interleaving paired reads. (dragen-only)
	  If the value is dragen-interleaved, output FASTQ.ORA interleaving paired reads in a single FASTQ.ORA file 
	  for a higher compression rate.
	*/
	fastq_compression_format?: string

	/*
	find adapter with indels: 
	Use single-indel-detection adapter trimming (for matching default bcl2fastq2 behavior)
	*/
	find_adapter_with_indels?: boolean

	/*
	mask_short_reads: 
	Reads trimmed below this point become masked out.
	*/
	mask_short_reads?: number

	/*
	minimum_adapter_overlap: 
	Do not trim any bases unless the adapter matches are greater than or equal to the number of bases specified. 
	At least one AdapterRead1 or AdapterRead2 must be specified to use MinimumAdapterOverlap.
	Allowed characters: 1, 2, 3.
	*/
	minimum_adapter_overlap?: number

	/*
	minimum_trimmed_read_length: 
	Make sure that all trimmed reads are at least x base pairs long after adapter trimming 
	by appending Ns to any read shorter than x base pairs.
	*/
	minimum_trimmed_read_length?: number

	/*
	no lane splitting: 
	If set to true, output all lanes of a flow cell to the same FASTQ files consecutively.
	*/
	no_lane_splitting?: boolean

	/*
	override_cycles: 
	String used to specify UMI cycles and mask out cycles of a read.
	*/
	override_cycles?: string

	/*
	trim_umi: 
	If set to 0, UMI sequences are not trimmed from output FASTQ reads. 
	The UMI is still placed in sequence header.
	*/
	trim_umi?: boolean
}
