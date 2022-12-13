export interface BclconvertDataRow {
	/*
	index: 
	The Index 1 (i7) index adapter sequence.
	*/
	index: string

	/*
	index2: 
	The Index 2 (i5) Index adapter sequence.
	*/
	index2?: string

	/*
	lane: 
	When specified, FASTQ files are created only for the samples with the specified lane number. 
	Only one valid integer is allowed, as defined by the RunInfo.xml.
	*/
	lane: number

	/*
	override cycles: 
	Per-sample override cycles settings
	*/
	override_cycles?: string

	/*
	sample_id: 
	The sample ID.
	*/
	sample_id: string

	/*
	sample_name: 
	If present, and both --sample-name-column-enabled true and 
	--bcl-sampleproject-subdirectories true command lines are used, 
	then output FASTQ files to subdirectories based upon Sample_Project and Sample_ID, 
	and name fastq files by Sample_Name
	*/
	sample_name?: string

	/*
	sample_project: 
	Can only contain alphanumeric characters, dashes, and underscores. 
	Duplicate data strings with different cases (eg, sampleProject and SampleProject) are not allowed. 
	If these data strings are used, analysis fails. 
	This column is not used unless you are using the command line option --bcl-sampleproject-subdirectories. 
	See [Command Line Options](https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/CommandLineOptions.htm) 
	for more information on command line options.
	*/
	sample_project?: string
}
