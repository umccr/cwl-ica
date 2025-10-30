import { FileProperties as IFile } from "cwl-ts-auto"

export interface DragenSvCallerOptions {
	/*
	enable csv: 
	Enables the structural variant caller.
	The default value is false.
	*/
	enable_sv?: boolean

	/*
	sv call regions bed: 
	A bed file containing the regions to be used for structural variant calling.
	*/
	sv_call_regions_bed?: IFile
}
