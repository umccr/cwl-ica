
arriba-drawing 2.3.0 tool
=========================

## Table of Contents
  
- [Overview](#arriba-drawing-v230-overview)  
- [Links](#related-links)  
- [Inputs](#arriba-drawing-v230-inputs)  
- [Outputs](#arriba-drawing-v230-outputs)  
- [ICA](#ica)  


## arriba-drawing v(2.3.0) Overview



  
> ID: arriba-drawing--2.3.0  
> md5sum: 41a6ca144a31223e32ba97bab30c8a33

### arriba-drawing v(2.3.0) documentation
  
Documentation for arriba-drawing v2.3.0

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/arriba-drawing/2.3.0/arriba-drawing__2.3.0.cwl)  


### Used By
  
- [dragen-transcriptome-pipeline 3.9.3](../../../workflows/dragen-transcriptome-pipeline/3.9.3/dragen-transcriptome-pipeline__3.9.3.md)  
- [dragen-transcriptome-pipeline 4.0.3](../../../workflows/dragen-transcriptome-pipeline/4.0.3/dragen-transcriptome-pipeline__4.0.3.md)  

  


## arriba-drawing v(2.3.0) Inputs

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


### color 1



  
> ID: color_1
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
color 1. Default #e5a5a5


### color 2



  
> ID: color_2
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
color 2. Default #a7c4e5


### coverage range



  
> ID: coverage_range
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Coverage range. Default 0.


### cytobands



  
> ID: cytobands
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Coordinates of the Giemsa staining bands. This information is used to draw ideograms


### fixed scale



  
> ID: fixed_scale
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Fixed scale. Default 0.


### font family



  
> ID: font_family
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Font family. Default Helvetica.


### font size



  
> ID: font_size
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Font size. Default 1.


### fusions



  
> ID: fusions
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
File containing fusion predictions from Arriba


### merge domains overlapping



  
> ID: merge_domains_overlapping_by
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Merge domains overlapping. Default 0.9


### optimize domain colors



  
> ID: optimize_domain_colors
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Optimize domain colors. Default false.


### output



  
> ID: output
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Output file in PDF format containing the visualizations of the gene fusions


### pdf width



  
> ID: pdf_width
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
PDF width. Default 11.692


### print exon labels



  
> ID: print_exon_labels
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Print exon labels. Default true


### protein domains



  
> ID: protein_domains
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
GFF3 file containing the genomic coordinates of protein domains


### render 3d effect



  
> ID: render_3d_effect
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Render 3d effect. Default true


### sample name



  
> ID: sample_name
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Sample name


### squish introns



  
> ID: squish_introns
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Squish introns. Default true


### transcript selection



  
> ID: transcript_selection
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Transcript selection. Default coverage

  


## arriba-drawing v(2.3.0) Outputs

### output PDF



  
> ID: arriba-drawing--2.3.0/output_pdf  

  
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
**wfl version name:** 2.3.0  

  

