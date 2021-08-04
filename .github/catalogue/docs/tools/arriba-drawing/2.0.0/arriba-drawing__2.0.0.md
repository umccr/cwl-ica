
arriba-drawing 2.0.0 tool
=========================

## Table of Contents
  
- [Overview](#arriba-drawing-v200-overview)  
- [Links](#related-links)  
- [Inputs](#arriba-drawing-v200-inputs)  
- [Outputs](#arriba-drawing-v200-outputs)  
- [ICA](#ica)  


## arriba-drawing v(2.0.0) Overview



  
> ID: arriba-drawing--2.0.0  
> md5sum: 87ee5552c7c0e3aad1a74d5b3a75dc4b

### arriba-drawing v(2.0.0) documentation
  
Documentation for arriba-drawing v2.0.0

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/arriba-drawing/2.0.0/arriba-drawing__2.0.0.cwl)  


### Used By
  
- [dragen-transcriptome-pipeline 3.7.5](../../../workflows/dragen-transcriptome-pipeline/3.7.5/dragen-transcriptome-pipeline__3.7.5.md)  
- [dragen-transcriptome-pipeline 3.8.4](../../../workflows/dragen-transcriptome-pipeline/3.8.4/dragen-transcriptome-pipeline__3.8.4.md)  

  


## arriba-drawing v(2.0.0) Inputs

### annotation



  
> ID: annotation
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Gene annotation in GTF format


### alignment



  
> ID: bam_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
BAM file containing normal alignments from STAR


### cytobands



  
> ID: cytobands
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Coordinates of the Giemsa staining bands. This information is used to draw ideograms


### fusions



  
> ID: fusions
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
File containing fusion predictions from Arriba


### output



  
> ID: output
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Output file in PDF format containing the visualizations of the gene fusions


### protein domains



  
> ID: protein_domains
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
GFF3 file containing the genomic coordinates of protein domains

  


## arriba-drawing v(2.0.0) Outputs

### output PDF



  
> ID: arriba-drawing--2.0.0/output_pdf  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output pdf file with fusion drawing
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.7620a30e5df3446091c73d3fa10db084  

  
**workflow name:** arriba-drawing_dev-wf  
**wfl version name:** 2.0.0  

  

