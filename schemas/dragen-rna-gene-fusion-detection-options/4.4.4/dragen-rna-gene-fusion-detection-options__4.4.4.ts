export interface DragenRnaGeneFusionDetectionOptions {
	/*
	Enable RNA Quantification: 
	Enable RNA quantification. This option is only available when the
	*/
	enable_rna_quantification?: boolean

	/*
	rna quantification bias: 
	GC bias correction estimates the effect of transcript %GC on sequencing coverage and
	accounts for the effect when estimating expression.
	To disable GC bias correction, set to "false".
	*/
	rna_quanitification_bias?: boolean
}
