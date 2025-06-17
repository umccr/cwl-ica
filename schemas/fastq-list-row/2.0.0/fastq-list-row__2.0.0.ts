import { FileProperties as IFile } from "cwl-ts-auto"

export interface FastqListRow {
	/*
	lane: 
	The lane that the sample was run on
	*/
	lane: number

	/*
	read 1: 
	The path to R1 of a sample
	*/
	read_1: IFile | string

	/*
	read 2: 
	The path to R2 of a sample
	*/
	read_2?: IFile | string

	/*
	rgcn: 
	The read-group center name
	*/
	rgcn?: string

	/*
	rgds: 
	The read-group description
	*/
	rgds?: string

	/*
	rgdt: 
	The read-group date
	*/
	rgdt?: string

	/*
	rgid: 
	The read-group id of the sample.
	Often an index
	*/
	rgid: string

	/*
	rglb: 
	The read-group library of the sample.
	*/
	rglb: string

	/*
	rgpl: 
	The read-group platform
	*/
	rgpl?: string

	/*
	rgsm: 
	The read-group sample name
	*/
	rgsm: string
}
