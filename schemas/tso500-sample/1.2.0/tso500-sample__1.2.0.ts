import { FastqListRow } from "../../fastq-list-row/1.0.0/fastq-list-row__1.0.0"

export enum SampleType {
	"DNA" = "DNA",
	"RNA" = "RNA"
}

export interface Tso500Sample {
	/*
	fastq list rows: 
	The 'fastq list rows' of the sample
	*/
	fastq_list_rows: FastqListRow[]

	/*
	pair id: 
	The 'pair id' of the sample.
	If a sample has a complementary DNA or RNA sample, the pair ids of the two samples should have the same
	unique pair id.
	*/
	pair_id: string

	/*
	sample id: 
	The id of the tso500 sample - this must match the Sample_ID column in the samplesheet.
	This is used to recreate the fastq files.
	*/
	sample_id: string

	/*
	sample name: 
	This must match the rgsm value in the fastq list rows.
	It does not need to match the Sample_Name column in the sample sheet
	*/
	sample_name: string

	/*
	sample type: 
	The 'type' of the sample
	*/
	sample_type: SampleType
}
