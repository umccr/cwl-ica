export interface DragenTmbOptions {
	/*
	enable tmb: 
	Enable TMB (Tumor Mutation Burden) analysis.
	*/
	enable_tmb?: boolean

	/*
	tmb enable proxi filter: 
	Enable proximity filter for TMB (default=true).
	*/
	tmb_enable_proxi_filter?: boolean

	/*
	tmb vaf threshold: 
	Variant mininum allele frequency for usable variants (default=0.05)
	*/
	tmb_vaf_threshold?: number

	/*
	vc callability tumor thresh: 
	Required read coverage to use a site (default=50).
	*/
	vc_callability_tumor_thresh?: number
}
