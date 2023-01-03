
custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json 1.0.0 tool
=========================================================================

## Table of Contents
  
- [Overview](#custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json-v100-inputs)  
- [Outputs](#custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json-v100-outputs)  
- [ICA](#ica)  


## custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json v(1.0.0) Overview



  
> ID: custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json--1.0.0  
> md5sum: 4246ab42f46c6a90a16dec469f24836c

### custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json v(1.0.0) documentation
  
Collate a list of dragen metric csv files and output as a compressed json.
Original CWL File can be found [here](https://github.com/YinanWang16/tso500-ctdna-post-processing/blob/main/cwl/tools/tsv2json/tsv2json.cwl)

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json/1.0.0/custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json v(1.0.0) Inputs

### csv metrics files



  
> ID: csv_metrics_files
  
**Optional:** `False`  
**Type:** `File[]`  
**Docs:**  
The list of csv metrics files file


### output_prefix



  
> ID: output_prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Required, output file is then <this>.AlignCollapseFusionCaller_metrics.json.gz

  


## custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json v(1.0.0) Outputs

### metrics json gz out



  
> ID: custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json--1.0.0/metrics_json_gz_out  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output file in compressed json gz format
  

  

