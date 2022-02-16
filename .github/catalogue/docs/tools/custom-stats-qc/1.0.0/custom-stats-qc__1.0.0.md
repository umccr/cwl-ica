
custom-stats-qc 1.0.0 tool
==========================

## Table of Contents
  
- [Overview](#custom-stats-qc-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-stats-qc-v100-inputs)  
- [Outputs](#custom-stats-qc-v100-outputs)  
- [ICA](#ica)  


## custom-stats-qc v(1.0.0) Overview



  
> ID: custom-stats-qc--1.0.0  
> md5sum: 0d33056393a32a0c3033cba31f01f235

### custom-stats-qc v(1.0.0) documentation
  
A tool to extract custom QC metrics from samtools stats output and convert to json format.

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-stats-qc/1.0.0/custom-stats-qc__1.0.0.cwl)  


### Used By
  
- [ghif-qc 1.0.0](../../../workflows/ghif-qc/1.0.0/ghif-qc__1.0.0.md)  

  


## custom-stats-qc v(1.0.0) Inputs

### output filename



  
> ID: output_json_filename
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
output file


### output samtools stats



  
> ID: output_samtools_stats
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Output txt file from samtools stats


### sample id



  
> ID: sample_id
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Id of the input sample

  


## custom-stats-qc v(1.0.0) Outputs

### output file



  
> ID: custom-stats-qc--1.0.0/output_json  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
JSON output file containing custom metrics
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.428005f137ab409296a367db1b9f122e  

  
**workflow name:** custom-stats-qc_dev-wf  
**wfl version name:** 1.0.0  


#### Run Instances

##### ToC
  
- [Run wfr.eb46716d0e5c487b9f699cd5fbc2821f](#run-wfreb46716d0e5c487b9f699cd5fbc2821f)  


##### Run wfr.eb46716d0e5c487b9f699cd5fbc2821f



  
> Run Name: custom-qc  

  
**Start Time:** 2022-01-11 05:47:36 UTC  
**Duration:** 2022-01-11 06:13:22 UTC  
**End Time:** 0 days 00:25:46  


###### Reproduce Run


```bash

# Run the submission template to create the workflow input json and launch script            
cwl-ica copy-tool-submission-template --ica-workflow-run-instance-id wfr.eb46716d0e5c487b9f699cd5fbc2821f

# Edit the input json file (optional)
# vim wfr.eb46716d0e5c487b9f699cd5fbc2821f.template.json 

# Run the launch script
bash wfr.eb46716d0e5c487b9f699cd5fbc2821f.launch.sh
                                    
```  


###### Run Inputs


```
{
    "output_filename": "postprocess",
    "output_samtools_stats": {
        "class": "File",
        "location": "gds://stratus-sehrish2/ghif-qc/inputs/samtools_stats.txt"
    },
    "sample_id": "NA12878"
}
```  


###### Run Engine Parameters


```
{
    "workDirectory": "gds://wfr.eb46716d0e5c487b9f699cd5fbc2821f/custom-qc",
    "outputDirectory": "gds://wfr.eb46716d0e5c487b9f699cd5fbc2821f/custom-qc/outputs",
    "tmpOutputDirectory": "gds://wfr.eb46716d0e5c487b9f699cd5fbc2821f/custom-qc/steps",
    "logDirectory": "gds://wfr.eb46716d0e5c487b9f699cd5fbc2821f/custom-qc/logs",
    "maxScatter": 32,
    "outputSetting": "move",
    "copyOutputInstanceType": "StandardHiCpu",
    "copyOutputInstanceSize": "Medium",
    "defaultInputMode": "'Download'",
    "inputModeOverrides": {},
    "tesUseInputManifest": "'auto'",
    "cwltool": "3.0.20201203173111",
    "engine": "1.18.0-202109141250-stratus-master"
}
```  


###### Run Outputs


```
{
    "output_file": {
        "location": "gds://wfr.eb46716d0e5c487b9f699cd5fbc2821f/custom-qc/outputs/postprocess_NA12878.json",
        "basename": "postprocess_NA12878.json",
        "nameroot": "postprocess_NA12878",
        "nameext": ".json",
        "class": "File",
        "size": 1064,
        "http://commonwl.org/cwltool#generation": 0
    },
    "output_dir_gds_session_id": "ssn.f7b07b2d81c7432d8f0a9571395bc7f7",
    "output_dir_gds_folder_id": "fol.e218d7b3885047380f6208d9d142e3c5"
}
```  


###### Run Resources Usage
  

  
[![custom-qc__wfr.eb46716d0e5c487b9f699cd5fbc2821f.svg](../../../../images/runs/tools/custom-stats-qc/1.0.0/custom-qc__wfr.eb46716d0e5c487b9f699cd5fbc2821f.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/runs/tools/custom-stats-qc/1.0.0/custom-qc__wfr.eb46716d0e5c487b9f699cd5fbc2821f.svg)  

  

