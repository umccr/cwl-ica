
bcftools-view 1.13.0 tool
=========================

## Table of Contents
  
- [Overview](#bcftools-view-v1130-overview)  
- [Links](#related-links)  
- [Inputs](#bcftools-view-v1130-inputs)  
- [Outputs](#bcftools-view-v1130-outputs)  
- [ICA](#ica)  


## bcftools-view v(1.13.0) Overview



  
> ID: bcftools-view--1.13.0  
> md5sum: c7955367b9f13410f6bfeab5af00ff52

### bcftools-view v(1.13.0) documentation
  
Documentation for bcftools-view v1.13.0. Detail at https://samtools.github.io/bcftools/bcftools.html#view 

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/bcftools-view/1.13.0/bcftools-view__1.13.0.cwl)  

  


## bcftools-view v(1.13.0) Inputs

### apply filters



  
> ID: apply_filters
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Skip sites where FILTER column does not contain any of the strings listed in LIST. 
For example, to include only sites which have no filters set, use -f .,PASS.


### compression level



  
> ID: compression_level
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Compression level. 0 stands for uncompressed, 1 for best speed and 9 for best compression.


### drop genotypes



  
> ID: drop_genotypes
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Output compressed BCF (b), uncompressed BCF (u), compressed VCF (z), uncompressed VCF (v). 


### exclude condition



  
> ID: exclude
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Exclude sites for which EXPRESSION is true. 


### exclude types



  
> ID: exclude_types
  
**Optional:** `True`  
**Type:** `string[]`  
**Docs:**  
comma-separated list of variant types to exclude. Site is excluded if any of the ALT alleles is of the type requested. 


### force samples



  
> ID: force_samples
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Only warn about unknown subset samples


### genotype



  
> ID: genotype
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Include only sites with one or more homozygous (hom), heterozygous (het) or missing (miss) genotypes.


### header only



  
> ID: header_only
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Output the VCF header only


### include condition



  
> ID: include
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Include sites for which EXPRESSION is true.


### known



  
> ID: known
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Print known sites only (ID column is not ".")


### max ac



  
> ID: max_ac
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Maximum allele count (INFO/AC) of sites to be printed. Specifying the type of allele is optional and 
can be set to non-reference (nref, the default), 1st alternate (alt1), the least frequent (minor), 
the most frequent (major) or sum of all but the most frequent (nonmajor) alleles.


### max alleles



  
> ID: max_alleles
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Print sites with at most INT alleles listed in REF and ALT columns. 
Use -m2 -M2 -v snps to only view biallelic SNPs.


### min ac



  
> ID: min_ac
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Minimum allele count (INFO/AC) of sites to be printed. Specifying the type of allele is optional 
and can be set to non-reference (nref, the default), 1st alternate (alt1), the least frequent 
(minor), the most frequent (major) or sum of all but the most frequent (nonmajor) alleles.


### min alleles



  
> ID: min_alleles
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Print sites with at least INT alleles listed in REF and ALT columns.


### no header



  
> ID: no_header
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Suppress the header in VCF output


### no update



  
> ID: no_update
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Do not (re)calculate INFO fields for the subset (currently INFO/AC and INFO/AN)


### novel



  
> ID: novel
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Print novel sites only (ID column is ".")


### output vcf



  
> ID: output
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Name of the output vcf.
Defaults to filtered.vcf.gz


### output type



  
> ID: output_type
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Output compressed BCF (b), uncompressed BCF (u), compressed VCF (z), uncompressed VCF (v).
Use the -Ou option when piping between bcftools subcommands to speed up performance by removing 
unnecessary compression/decompression and VCF←→BCF conversion.


### regions



  
> ID: regions
  
**Optional:** `True`  
**Type:** `string[]`  
**Docs:**  
Comma-separated list of regions, see also -R, --regions-file. 
Overlapping records are matched even when the starting coordinate is outside of the region, 
unlike the -t/-T options where only the POS coordinate is checked. Note that -r cannot be 
used in combination with -R.


### regions file



  
> ID: regions_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Regions can be specified either on command line or in a VCF, BED, or tab-delimited file (the default). 


### samples



  
> ID: samples
  
**Optional:** `True`  
**Type:** `string[]`  
**Docs:**  
Comma-separated list of samples to include or exclude if prefixed with "^". 
The sample order is updated to reflect that given on the command line. 


### samples file



  
> ID: samples_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
File of sample names to include or exclude if prefixed with "^". One sample per line. 
See also the note above for the -s, --samples option.


### targets



  
> ID: targets
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Similar as -r, --regions, but the next position is accessed by streaming the whole VCF/BCF 
rather than using the tbi/csi index. 


### targets file



  
> ID: targets_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Same -t, --targets, but reads regions from a file. Note that -T cannot be used in combination with -t.


### threads



  
> ID: threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Use multithreading with INT worker threads. The option is currently used only for the compression 
of the output stream, only when --output-type is b or z. Default: 0.


### trim alt alleles



  
> ID: trim_alt_alleles
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Remove alleles not seen in the genotype fields from the ALT column. Note that if no alternate allele 
remains after trimming, the record itself is not removed but ALT is set to ".". If the option -s or -S 
is given, removes alleles not seen in the subset. INFO and FORMAT tags declared as Type=A, G or R will 
be trimmed as well.


### types



  
> ID: types
  
**Optional:** `True`  
**Type:** `string[]`  
**Docs:**  
Comma-separated list of variant types to select. Site is selected if any of the ALT alleles is of the type requested.  


### vcf



  
> ID: vcf
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
VCF output from Dragen run

  


## bcftools-view v(1.13.0) Outputs

### filtered vcf



  
> ID: bcftools-view--1.13.0/filtered_vcf  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
VCF filtered on the AF threshold
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.14a46d288c1a45b7b7413b995fdd60e3  

  
**workflow name:** bcftools-view_dev-wf  
**wfl version name:** 1.13.0  

  

