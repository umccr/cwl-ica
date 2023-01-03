
tso500-ctdna-post-processing-pipeline 1.0.0 workflow
====================================================

## Table of Contents
  
- [Overview](#tso500-ctdna-post-processing-pipeline-v100-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#tso500-ctdna-post-processing-pipeline-v100-inputs)  
- [Steps](#tso500-ctdna-post-processing-pipeline-v100-steps)  
- [Outputs](#tso500-ctdna-post-processing-pipeline-v100-outputs)  
- [ICA](#ica)  


## tso500-ctdna-post-processing-pipeline v(1.0.0) Overview



  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0  
> md5sum: 14248e8747a54e0f0081f7928e4862e2

### tso500-ctdna-post-processing-pipeline v(1.0.0) documentation
  
UMCCR CWL tso500-ctdna-post-processing-pipeline v1.0.0

Original pipeline source can be found [here](https://github.com/YinanWang16/tso500-ctdna-post-processing/blob/main/cwl/workflows/umccr-cttso-post-processiong__v1.0.0.cwl).

The workflow has 6 main steps

* intermediate expressions - for collection of bam, vcf, csv and json files
* Coverage analysis
  * Create csv of exons with a list of low level coverage
  * Summary report of coverage over exons
* JSONising of dragen metrics
* Compression of json files
* Compression of vcf files
* Creation of the output directory with the select files

### Categories
  
- tso500  


## Visual Workflow Overview
  
[![tso500-ctdna-post-processing-pipeline__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.cwl)  


### Uses
  
- [custom-gzip-file 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-gzip-file/1.0.0/custom-gzip-file__1.0.0.md)  
- [bgzip 1.12.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/bgzip/1.12.0/bgzip__1.12.0.md)  
- [custom-tsv-to-json 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tsv-to-json/1.0.0/custom-tsv-to-json__1.0.0.md)  
- [get-custom-output-dir-entry-for-tso500-post-processing 2.0.1 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-custom-output-dir-entry-for-tso500-post-processing/2.0.1/get-custom-output-dir-entry-for-tso500-post-processing__2.0.1.md)  
- [custom-touch-file 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.md)  
- [custom-create-directory 2.0.1 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-create-directory/2.0.1/custom-create-directory__2.0.1.md)  
- [custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json/1.0.0/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json__1.0.0.md)  
- [custom-tar-file-list 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.md)  
- [custom-tar-file-list 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.md)  
- [custom-tar-vcf-file-list 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-vcf-file-list/1.0.0/custom-tar-vcf-file-list__1.0.0.md)  
- [get-files-from-directory 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.md)  
- [get-file-from-directory 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)  
- [get-file-from-directory 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)  
- [get-file-from-directory 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)  
- [parse-int 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.md)  
- [get-bam-file-from-directory 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-bam-file-from-directory/1.0.0/get-bam-file-from-directory__1.0.0.md)  
- [parse-file 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-file/1.0.0/parse-file__1.0.0.md)  
- [get-file-from-directory 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)  
- [get-file-from-directory 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)  
- [get-files-from-directory 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.md)  
- [parse-int 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.md)  
- [tabix 0.2.6 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/tabix/0.2.6/tabix__0.2.6.md)  
- [custom-tso500-make-exon-coverage-qc 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-exon-coverage-qc/1.0.0/custom-tso500-make-exon-coverage-qc__1.0.0.md)  
- [custom-tso500-make-region-coverage-qc 1.0.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-region-coverage-qc/1.0.0/custom-tso500-make-region-coverage-qc__1.0.0.md)  
- [mosdepth 0.3.1 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/mosdepth/0.3.1/mosdepth__0.3.1.md)  
- [multiqc 1.12.0 :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/multiqc/1.12.0/multiqc__1.12.0.md)  

  


## tso500-ctdna-post-processing-pipeline v(1.0.0) Inputs

### tso500 outputs by sample



  
> ID: tso500_outputs_by_sample
  
**Optional:** `False`  
**Type:** `file:///home/runner/work/cwl-ica/cwl-ica/schemas/tso500-outputs-by-sample/1.0.0/tso500-outputs-by-sample__1.0.0.yaml#tso500-outputs-by-sample`  
**Docs:**  
Directories and Files of UMCCR tso500 output


### tso manifest bed



  
> ID: tso_manifest_bed
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
TST500C_manifest.bed file from TSO500 resources

  


## tso500-ctdna-post-processing-pipeline v(1.0.0) Steps

### compress reporting jsons with gzip step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/compress_reporting_jsons_with_gzip_step
  
**Step Type:** workflow  
**Docs:**
  
Compress the tmb, msi and sample analysis results jsons with gzip

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-gzip-file/1.0.0/custom-gzip-file__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-gzip-file/1.0.0/custom-gzip-file__1.0.0.md)
#### Subworkflow overview
  
[![custom-gzip-file__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-gzip-file/1.0.0/custom-gzip-file__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-gzip-file/1.0.0/custom-gzip-file__1.0.0.svg)  


### compress vcf files step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/compress_vcf_files_step
  
**Step Type:** workflow  
**Docs:**
  
Compress (and index) vcf files with bgzip

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/bgzip/1.12.0/bgzip__1.12.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/bgzip/1.12.0/bgzip__1.12.0.md)
#### Subworkflow overview
  
[![bgzip__1.12.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/bgzip/1.12.0/bgzip__1.12.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/bgzip/1.12.0/bgzip__1.12.0.svg)  


### convert metric csvs into json gzip step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/convert_metric_csvs_into_json_gzip_step
  
**Step Type:** workflow  
**Docs:**
  
Convert the metric csv files into compressed jsons

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tsv-to-json/1.0.0/custom-tsv-to-json__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tsv-to-json/1.0.0/custom-tsv-to-json__1.0.0.md)
#### Subworkflow overview
  
[![custom-tsv-to-json__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tsv-to-json/1.0.0/custom-tsv-to-json__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tsv-to-json/1.0.0/custom-tsv-to-json__1.0.0.svg)  


### create custom output entry list array step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/create_custom_output_entry_list_array_step
  
**Step Type:** workflow  
**Docs:**
  
Create the array of inputs to go into custom create directory.

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-custom-output-dir-entry-for-tso500-post-processing/2.0.1/get-custom-output-dir-entry-for-tso500-post-processing__2.0.1.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-custom-output-dir-entry-for-tso500-post-processing/2.0.1/get-custom-output-dir-entry-for-tso500-post-processing__2.0.1.md)
#### Subworkflow overview
  
[![get-custom-output-dir-entry-for-tso500-post-processing__2.0.1.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-custom-output-dir-entry-for-tso500-post-processing/2.0.1/get-custom-output-dir-entry-for-tso500-post-processing__2.0.1.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-custom-output-dir-entry-for-tso500-post-processing/2.0.1/get-custom-output-dir-entry-for-tso500-post-processing__2.0.1.svg)  


### Create dummy file


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/create_dummy_file_step
  
**Step Type:** workflow  
**Docs:**
  
Intermediate step for letting multiqc-interop be placed in stream mode

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.md)
#### Subworkflow overview
  
[![custom-touch-file__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.svg)  


### create output directory


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/create_output_directory
  
**Step Type:** workflow  
**Docs:**
  
Create the output directory containing all the files listed in the previous step.

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-create-directory/2.0.1/custom-create-directory__2.0.1.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-create-directory/2.0.1/custom-create-directory__2.0.1.md)
#### Subworkflow overview
  
[![custom-create-directory__2.0.1.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-create-directory/2.0.1/custom-create-directory__2.0.1.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-create-directory/2.0.1/custom-create-directory__2.0.1.svg)  


### dragen metrics to json step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/dragen_metrics_to_json_step
  
**Step Type:** workflow  
**Docs:**
  
Collect all of the dragen metrics and convert to compressed json

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json/1.0.0/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json/1.0.0/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json__1.0.0.md)
#### Subworkflow overview
  
[![custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json/1.0.0/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json/1.0.0/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json__1.0.0.svg)  


### gather compressed metric json files into tar step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/gather_compressed_metric_json_files_into_tar_step
  
**Step Type:** workflow  
**Docs:**
  
Gather the compressed metric jsons files into a tar ball.
This is to limit the number of input files / directories into the final collection step.

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.md)
#### Subworkflow overview
  
[![custom-tar-file-list__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.svg)  


### gather compressed reporting json files into tar step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/gather_compressed_reporting_json_files_into_tar_step
  
**Step Type:** workflow  
**Docs:**
  
Zip up the compressed jsons into a tar ball.
This is to limit the number of input files / directories into the final collection step.

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.md)
#### Subworkflow overview
  
[![custom-tar-file-list__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.svg)  


### gather compressed vcf files into tar step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/gather_compressed_vcf_files_into_tar_step
  
**Step Type:** workflow  
**Docs:**
  
Gather the vcf files into a tar ball.
This is to limit the number of input files / directories into the final collection step.

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-vcf-file-list/1.0.0/custom-tar-vcf-file-list__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-vcf-file-list/1.0.0/custom-tar-vcf-file-list__1.0.0.md)
#### Subworkflow overview
  
[![custom-tar-vcf-file-list__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-vcf-file-list/1.0.0/custom-tar-vcf-file-list__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tar-vcf-file-list/1.0.0/custom-tar-vcf-file-list__1.0.0.svg)  


### get align collapse fusion caller metrics csv files intermediates step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_align_collapse_fusion_caller_metrics_csv_files_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the metrics csv files generated by dragen in the AlignCollapseFusionCaller folder
Return a compressed json file as output

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.md)
#### Subworkflow overview
  
[![get-files-from-directory__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.svg)  


### get fragment length hist csv intermediate step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_fragment_length_hist_csv_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the fragment length hist csv from the AlignCollapseFusionCaller directory

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)
#### Subworkflow overview
  
[![get-file-from-directory__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)  


### get fusion csv intermediate step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_fusion_csv_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the fusions csv file from the results folder

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)
#### Subworkflow overview
  
[![get-file-from-directory__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)  


### get msi json intermediate step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_msi_json_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the MSI json file from the MSI directory

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)
#### Subworkflow overview
  
[![get-file-from-directory__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)  


### get one val for skip rows parameter


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_one_val_for_skip_rows_parameter
  
**Step Type:** workflow  
**Docs:**
  
Get a one value for skip rows parameter

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.md)
#### Subworkflow overview
  
[![parse-int__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.svg)  


### get bam file intermediate step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_raw_bam_file_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the raw bam file from the AlignCollapseFusionCaller directory for the sample
Returns the bam file with the bam index as a secondary file

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-bam-file-from-directory/1.0.0/get-bam-file-from-directory__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-bam-file-from-directory/1.0.0/get-bam-file-from-directory__1.0.0.md)
#### Subworkflow overview
  
[![get-bam-file-from-directory__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-bam-file-from-directory/1.0.0/get-bam-file-from-directory__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-bam-file-from-directory/1.0.0/get-bam-file-from-directory__1.0.0.svg)  


### get sample analysis results intermediate step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_sample_analysis_results_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the sample analysis results json file. We need to have this as an output of a step rather than
a component of a schema for the downstream step

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-file/1.0.0/parse-file__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-file/1.0.0/parse-file__1.0.0.md)
#### Subworkflow overview
  
[![parse-file__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-file/1.0.0/parse-file__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-file/1.0.0/parse-file__1.0.0.svg)  


### get tmb json intermediate step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_tmb_json_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the tmb json file from the TMB directory

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)
#### Subworkflow overview
  
[![get-file-from-directory__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)  


### get tmb trace tsv intermediate step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_tmb_trace_tsv_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the tmb trace tsv file from the TMB Directory

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.md)
#### Subworkflow overview
  
[![get-file-from-directory__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.svg)  


### get vcf files intermediate step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_vcf_files_intermediate_step
  
**Step Type:** workflow  
**Docs:**
  
Get the vcf files from the results folder for a given sample. Returns the following files:
  * MergedSmallVariants.vcf
  * CopyNumberVariants.vcf
  * MergedSmallVariants.genome.vcf

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.md)
#### Subworkflow overview
  
[![get-files-from-directory__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/get-files-from-directory/1.0.0/get-files-from-directory__1.0.0.svg)  


### get zero val for skip rows parameter


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/get_zero_val_for_skip_rows_parameter
  
**Step Type:** workflow  
**Docs:**
  
Get a zero value for skip rows parameter

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.md)
#### Subworkflow overview
  
[![parse-int__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/expressions/parse-int/1.0.0/parse-int__1.0.0.svg)  


### index vcf files step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/index_vcf_files_step
  
**Step Type:** workflow  
**Docs:**
  
Add the tabix specific index to the vcf files

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/tabix/0.2.6/tabix__0.2.6.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/tabix/0.2.6/tabix__0.2.6.md)
#### Subworkflow overview
  
[![tabix__0.2.6.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/tabix/0.2.6/tabix__0.2.6.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/tabix/0.2.6/tabix__0.2.6.svg)  


### make exon coverage qc step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/make_exon_coverage_qc_step
  
**Step Type:** workflow  
**Docs:**
  
Provide which exons have an insufficient amount of coverage

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-exon-coverage-qc/1.0.0/custom-tso500-make-exon-coverage-qc__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-exon-coverage-qc/1.0.0/custom-tso500-make-exon-coverage-qc__1.0.0.md)
#### Subworkflow overview
  
[![custom-tso500-make-exon-coverage-qc__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-exon-coverage-qc/1.0.0/custom-tso500-make-exon-coverage-qc__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-exon-coverage-qc/1.0.0/custom-tso500-make-exon-coverage-qc__1.0.0.svg)  


### make per coverage threshold qc step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/make_per_coverage_threshold_qc_step
  
**Step Type:** workflow  
**Docs:**
  
For each region of coverage, summate how many regions had sufficient coverage of each coverage level

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-region-coverage-qc/1.0.0/custom-tso500-make-region-coverage-qc__1.0.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-region-coverage-qc/1.0.0/custom-tso500-make-region-coverage-qc__1.0.0.md)
#### Subworkflow overview
  
[![custom-tso500-make-region-coverage-qc__1.0.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-region-coverage-qc/1.0.0/custom-tso500-make-region-coverage-qc__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/custom-tso500-make-region-coverage-qc/1.0.0/custom-tso500-make-region-coverage-qc__1.0.0.svg)  


### mosdepth step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/mosdepth_step
  
**Step Type:** workflow  
**Docs:**
  
Use the tso manifest input file and report the threshold of coverage over each region of interest

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/mosdepth/0.3.1/mosdepth__0.3.1.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/mosdepth/0.3.1/mosdepth__0.3.1.md)
#### Subworkflow overview
  
[![mosdepth__0.3.1.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/mosdepth/0.3.1/mosdepth__0.3.1.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/mosdepth/0.3.1/mosdepth__0.3.1.svg)  


### run dragen multiqc on align collapse fusion caller dir step


  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/run_dragen_multiqc_on_align_collapse_fusion_caller_dir_step
  
**Step Type:** workflow  
**Docs:**
  
Run the dragen and dragen fastqc modules on the align collapse fusion caller directory

#### Links
  
[CWL File Path](../../../../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/multiqc/1.12.0/multiqc__1.12.0.cwl)  
[CWL File Help Page :construction:](file:/home/runner/work/cwl-ica/cwl-ica/tools/multiqc/1.12.0/multiqc__1.12.0.md)
#### Subworkflow overview
  
[![multiqc__1.12.0.svg](../../../../images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/multiqc/1.12.0/multiqc__1.12.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/tso500-ctdna-post-processing-pipeline/1.0.0/file:/home/runner/work/cwl-ica/cwl-ica/tools/multiqc/1.12.0/multiqc__1.12.0.svg)  


## tso500-ctdna-post-processing-pipeline v(1.0.0) Outputs

### tso500 post processing output directory



  
> ID: tso500-ctdna-post-processing-pipeline--1.0.0/post_processing_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Post processing output directory for tso500
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [collab-illumina-dev_workflows](#project-collab-illumina-dev_workflows)  


### Project: development_workflows


> wfl id: wfl.8c296420b9934b1eb582a61e27bb598a  

  
**workflow name:** tso500-ctdna-post-processing-pipeline_dev-wf  
**wfl version name:** 1.0.0  


### Project: collab-illumina-dev_workflows


> wfl id: wfl.fb0b7f1dbe164fceb8d6db7e83384647  

  
**workflow name:** tso500-ctdna-post-processing-pipeline_clb-ilmn-dev_wf  
**wfl version name:** 1.0.0  

  

