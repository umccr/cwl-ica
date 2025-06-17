export interface DragenCnvCallerOptions {
	/*
	cnv bypass contig check: 
	Bypass contig check for self normalization.
	*/
	cnv_bypass_contig_check?: boolean

	/*
	enable cnv: 
	Enables copy number variant (CNV).
	*/
	enable_cnv?: boolean
}
