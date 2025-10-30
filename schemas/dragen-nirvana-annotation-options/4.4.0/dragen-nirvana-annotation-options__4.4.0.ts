import { FileProperties as IFile } from "cwl-ts-auto"

export interface DragenNirvanaAnnotationOptions {
	/*
	enable variant annotation: 
	Enable Nirvana variant annotation on the output vcf/gvcf files.
	The default is false.
	*/
	enable_variant_annotation?: boolean

	/*
	variant annotation assembly: 
	The reference genome assembly used for Nirvana variant annotation.
	One of 'GRCh37' / 'GRCh38'
	*/
	variant_annotation_assembly?: string

	/*
	variant annotation data: 
	Tarball containing Nirvana data. 
	If not provided, but enable_variant_annotation is true, the data will be downloaded from Illumina's servers
	*/
	variant_annotation_data?: IFile
}
