import { Samplesheet } from "../../samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3"
import { FileProperties as IFile } from "cwl-ts-auto"
import { DirectoryProperties as IDirectory } from "cwl-ts-auto"

export interface BclconvertRunConfiguration {
	/*
	bcl_conversion_threads: 
	Specifies number of threads used for conversion per tile.
	Must be between 1 and available hardware threads,
	inclusive.
	*/
	bcl_conversion_threads?: number

	/*
	bcl_num_compression_threads: 
	Specifies number of CPU threads used for compression of
	output FASTQ files. Must be between 1 and available
	hardware threads, inclusive.
	*/
	bcl_num_compression_threads?: number

	/*
	bcl_num_decompression_threads: 
	Specifies number of CPU threads used for decompression
	of input base call files. Must be between 1 and available
	hardware threads, inclusive.
	*/
	bcl_num_decompression_threads?: number

	/*
	bcl num parallel tiles: 
	Specifies number of tiles being converted to FASTQ files in
	parallel. Must be between 1 and available hardware threads,
	inclusive.
	*/
	bcl_num_parallel_tiles?: number

	/*
	bcl_only_lane: 
	Convert only the specified lane number. The value must
	be less than or equal to the number of lanes specified in the
	RunInfo.xml. Must be a single integer value.
	*/
	bcl_only_lane?: number

	/*
	bcl_only_matched_reads: 
	Disable outputting unmapped reads to FASTQ files marked as Undetermined.
	*/
	bcl_only_matched_reads?: boolean

	/*
	bcl sampleproject subdirectories: 
	true — Allows creation of Sample_Project subdirectories
	as specified in the sample sheet. This option must be set to true for
	the Sample_Project column in the data section to be used.
	Default set to false.
	*/
	bcl_sampleproject_subdirectories?: boolean

	/*
	bcl validate sample sheet only: 
	Only validate RunInfo.xml & SampleSheet files (produce no FASTQ files)
	*/
	bcl_validate_sample_sheet_only?: boolean

	/*
	exclude_tiles: 
	Do not convert tiles that match a set of regular expressions, even if included in --tiles.
	*/
	exclude_tiles?: string

	/*
	fastq compression format: 
	Required for dragen ora compression to specify the type of compression.
	Use dragen for regular dragen ora compression or dragen-interleaved for dragen ora paired compression
	*/
	fastq_compression_format?: string

	/*
	fastq gzip compression level: 
	Set fastq output compression level 0-9 (default 1)
	*/
	fastq_gzip_compression_level?: number

	/*
	first_tile_only: 
	true — Only process the first tile of the first swath of the
	top surface of each lane specified in the sample sheet.
	false — Process all tiles in each lane, as specified in the sample
	sheet. Default is false
	*/
	first_tile_only?: boolean

	/*
	no lane splitting: 
	Consolidates FASTQ files across lanes.
	Each sample is provided into the same file on a per-read basis.
	*  Must be true or false.
	*  Only allowed when Lane column is excluded from the sample sheet.
	*/
	no_lane_splitting?: boolean

	/*
	num unknown barcodes reported: 
	Num of Top Unknown Barcodes to output (1000 by default)
	*/
	num_unknown_barcodes_reported?: number

	/*
	ora reference: 
	Required to output compressed FASTQ.ORA files. 
	Specify the path to the directory that contains the compression reference and index file.
	*/
	ora_reference?: IDirectory

	/*
	output directory: 
	A required command-line option that indicates the path to
	demultuplexed fastq output. The directory must not exist, unless -f,
	force is specified
	*/
	output_directory: string

	/*
	output legacy stats: 
	Also output stats in legacy (bcl2fastq) format (false by default)
	*/
	output_legacy_stats?: boolean

	/*
	run info: 
	Overrides the path to the RunInfo.xml file.
	*/
	run_info?: IFile

	/*
	sample name column enabled: 
	Use Sample_Name Sample Sheet column for *.fastq file names in Sample_Project subdirectories 
	(requires bcl-sampleproject-subdirectories true as well).
	*/
	sample_name_column_enabled?: boolean

	/*
	samplesheet: 
	samplesheet file
	*/
	samplesheet?: Samplesheet | IFile

	/*
	shared thread odirect output: 
	Uses experimental shared-thread file output code, which
	requires O_DIRECT mode. Must be true or false.
	This file output method is optimized for sample counts
	greater than 100,000. It is not recommended for lower
	sample counts or using a distributed file system target such
	as GPFS or Lustre. Default is false
	*/
	shared_thread_odirect_output?: boolean

	/*
	strict_mode: 
	true — Abort the program if any filter, locs, bcl, or bci lane
	files are missing or corrupt.
	false — Continue processing if any filter, locs, bcl, or bci lane files
	are missing. Return a warning message for each missing or corrupt
	file.
	*/
	strict_mode?: boolean

	/*
	tiles: 
	Only converts tiles that match a set of regular expressions.
	*/
	tiles?: string
}
