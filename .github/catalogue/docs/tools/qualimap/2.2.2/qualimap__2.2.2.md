
qualimap 2.2.2 tool
===================

## Table of Contents
  
- [Overview](#qualimap-v222-overview)  
- [Links](#related-links)  
- [Inputs](#qualimap-v222-inputs)  
- [Outputs](#qualimap-v222-outputs)  
- [ICA](#ica)  


## qualimap v(2.2.2) Overview



  
> ID: qualimap--2.2.2  
> md5sum: c6eae8729c871bc8bf5f3ae0ee64e0e4

### qualimap v(2.2.2) documentation
  
Qualimap perform RNA-seq QC analysis on paired-end data http://qualimap.bioinfo.cipf.es/doc_html/command_line.html.

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/qualimap/2.2.2/qualimap__2.2.2.cwl)  


### Used By
  
- [dragen-transcriptome-pipeline 3.9.3](../../../workflows/dragen-transcriptome-pipeline/3.9.3/dragen-transcriptome-pipeline__3.9.3.md)  
- [dragen-transcriptome-pipeline 4.0.3](../../../workflows/dragen-transcriptome-pipeline/4.0.3/dragen-transcriptome-pipeline__4.0.3.md)  
- [dragen-transcriptome-pipeline 4.2.4](../../../workflows/dragen-transcriptome-pipeline/4.2.4/dragen-transcriptome-pipeline__4.2.4.md)  
- [dragen-wts-qc-pipeline 3.9.3](../../../workflows/dragen-wts-qc-pipeline/3.9.3/dragen-wts-qc-pipeline__3.9.3.md)  
- [dragen-wts-qc-pipeline 4.0.3](../../../workflows/dragen-wts-qc-pipeline/4.0.3/dragen-wts-qc-pipeline__4.0.3.md)  
- [dragen-wts-qc-pipeline 4.2.4](../../../workflows/dragen-wts-qc-pipeline/4.2.4/dragen-wts-qc-pipeline__4.2.4.md)  

  


## qualimap v(2.2.2) Inputs

### algorithm



  
> ID: algorithm
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Counting algorithm:
uniquely-mapped-reads(default) or proportional.


### gtf



  
> ID: gtf
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Region file in GTF, GFF or BED format. 
If GTF format is provided, counting is based on
attributes, otherwise based on feature name.


### input bam



  
> ID: input_bam
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Input mapping file in BAM format.


### java mem



  
> ID: java_mem
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Set desired Java heap memory size


### out dir



  
> ID: out_dir
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Output folder for HTML report and raw data.


### seq protocol



  
> ID: seq_protocol
  
**Optional:** `True`  
**Type:** `[ strand-specific-forward | strand-specific-reverse | non-strand-specific  ]`  
**Docs:**  
Sequencing library protocol:
strand-specific-forward, strand-specific-reverse or 
non-strand-specific (default).

  


## qualimap v(2.2.2) Outputs

### qualimap qc



  
> ID: qualimap--2.2.2/qualimap_qc  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output directory with qc files and report
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.455f07acb41144d8904a18fcb0fac0a0  

  
**workflow name:** qualimap_dev-wf  
**wfl version name:** 2.2.2  

  

