export interface DragenMafConversionOptions {
	/*
	enable maf output: 
	Enables Mutation Annotation Format (MAF) output.
	The default value is false.
	*/
	enable_maf_output?: boolean

	/*
	maf transcript source: 
	Specifies desired transcript source for Mutation Annotation Format (MAF) output.
	One of 'Refseq' or 'Ensembl'.
	*/
	maf_transcript_source: string
}
