import { FileProperties as IFile } from "cwl-ts-auto"

export interface DragenSnvVariantCallerOptions {
	/*
	dbsnp: 
	Sets the path to the variant annotation database VCF (or *.vcf.gz) file.
	*/
	dbsnp?: IFile

	/*
	dn cnv vcf: 
	For de novo calling, filters joint structural variant VCF from the CNV calling step. If omitted, DRAGEN skips any checks with overlapping copy number variants.
	*/
	dn_cnv_vcf?: IFile

	/*
	dn input vcf: 
	For de novo calling, filters joint small variant VCF from the de novo calling step.
	*/
	dn_input_vcf?: IFile

	/*
	dn output vcf: 
	For de novo calling, specifies the file location for writing the filtered VCF file. If not specified, the input VCF is overwritten.
	*/
	dn_output_vcf?: IFile

	/*
	dn sv vcf: 
	For de novo calling, filters the joint structural variant VCF file from the SV calling step. If omitted, DRAGEN skips any checks with overlapping structural variants.
	*/
	dn_sv_vcf?: IFile

	/*
	enable joint genotyping: 
	To enable the joint genotyping caller, set to true.
	*/
	enable_joint_genotyping?: boolean

	/*
	enable methylation calling: 
	Automatically adds tags related to methylation and outputs a single BAM for methylation protocols.
	*/
	enable_methylation_calling?: boolean

	/*
	enable multi sample gvcf: 
	Enables generation of a multisample gVCF file. If set to true, requires a combined gVCF file as input.
	*/
	enable_multi_sample_gvcf?: boolean

	/*
	enable variant deduplication: 
	Enables variant deduplication. The default value is false.
	*/
	enable_variant_deduplication?: boolean

	/*
	enable vcf compression: 
	Enables compression of VCF output files. The default value is true.
	*/
	enable_vcf_compression?: boolean

	/*
	enable vcf indexing: 
	Outputs a *.tbi index file in addition to the output VCF/gVCF. The default is true.
	*/
	enable_vcf_indexing?: boolean

	/*
	enable vlrd: 
	Enables Virtual Long Read Detection.
	*/
	enable_vlrd?: boolean

	/*
	pedigree file: 
	Specifies the path to a pedigree file that describes the familial relationships between panels (specific to joint calling). Only pedigree files that contain trios are supported.
	*/
	pedigree_file?: IFile

	/*
	qc indel denovo quality threshold: 
	Sets the threshold for counting and reporting de novo INDEL variants.
	*/
	qc_indel_denovo_quality_threshold?: number

	/*
	qc snp denovo quality threshold: 
	Sets the threshold for counting and reporting de novo SNP variants.
	*/
	qc_snp_denovo_quality_threshold?: number

	/*
	variant: 
	Specifies the path to a single gVCF file. You can use the --variant option multiple times to specify paths to multiple gVCF files. Use one file per line. Up to 500 gVCFs are supported.
	*/
	variant?: IFile

	/*
	variant list: 
	Specifies the path to a file containing a list of input gVCF files that need to be combined. Use one file per line.
	*/
	variant_list?: IFile

	/*
	vc af call threshold: 
	If the AF filter is enabled using --vc-enable-af-filter=true, the option sets the allele frequency call threshold for nuclear chromosomes to emit a call in the VCF. The default value is 0.01.
	*/
	vc_af_call_threshold?: number

	/*
	vc af call threshold mito: 
	If the AF filter is enabled using --vc-enable-af-filter-mito=true, the option sets the allele frequency call threshold to emit a call in the VCF for mitochondrial variant calling. The default value is 0.01.
	*/
	vc_af_call_threshold_mito?: number

	/*
	vc af filter threshold: 
	If the AF filter is enabled using --vc-enable-af-filter=true, the option sets the allele frequency filter threshold for nuclear chromosomes to mark emitted VCF calls as filtered. The default value is 0.05.
	*/
	vc_af_filter_threshold?: number

	/*
	vc af filter threshold mito: 
	If the AF filter is enabled using --vc-enable-af-filter-mito=true, the option sets the allele frequency filter threshold to mark emitted VCF calls as filtered for mitochondrial variant calling. The default value is 0.02.
	*/
	vc_af_filter_threshold_mito?: number

	/*
	vc callability normal threshold: 
	Specifies the normal sample coverage threshold for a site to be considered callable in the somatic callable regions report. The default is 5.
	*/
	vc_callability_normal_threshold?: number

	/*
	vc callability tumor threshold: 
	Specifies the tumor sample coverage threshold for a site to be considered callable in the somatic callable regions report. The default is 50.
	*/
	vc_callability_tumor_threshold?: number

	/*
	vc clustered event penalty: 
	SQ score penalty applied to phased clustered somatic events; set to 0 to disable the penalty. The default value is 4.0 for tumor-normal and 7.0 for tumor-only.
	*/
	vc_clustered_event_penalty?: number

	/*
	vc decoy contigs: 
	Specifies the path to a comma-separated list of contigs to skip during variant calling.
	*/
	vc_decoy_contigs?: string

	/*
	vc depth annotation threshold: 
	Filters all non-PASS somatic alt variants with a depth below this threshold. The default value is 0 (no filtering).
	*/
	vc_depth_annotation_threshold?: number

	/*
	vc depth filter threshold: 
	Filters all somatic variants (alt or homref) with a depth below this threshold. The default value is 0 (no filtering).
	*/
	vc_depth_filter_threshold?: number

	/*
	vc emit ref confidence: 
	Enables base pair resolution gVCF generation or banded gVCF generation.
	*/
	vc_emit_ref_confidence?: string

	/*
	vd eh vcf: 
	Inputs the ExpansionHunter VCF file for variant deduplication. The input file can be gzipped.
	*/
	vd_eh_vcf?: IFile

	/*
	vd output match log: 
	Outputs a file that describes the variants that matched during deduplication. The default value is false.
	*/
	vd_output_match_log?: boolean

	/*
	vd small variant vcf: 
	Inputs small variant VCF file for variant deduplication. The input file can be gzipped.
	*/
	vd_small_variant_vcf?: IFile

	/*
	vd sv vcf: 
	Inputs structural variant VCF for variant deduplication. The input file can be gzipped.
	*/
	vd_sv_vcf?: IFile

    /*
    vc max callable region memory usage
    Set the maximum size of a single callable region. Default is "13GB".
    */
    vc_max_callable_region_memory_usage?: string
}
