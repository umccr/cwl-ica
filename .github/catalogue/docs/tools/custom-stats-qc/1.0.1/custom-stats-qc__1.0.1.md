
custom-stats-qc 1.0.1 tool
==========================

## Table of Contents
  
- [Overview](#custom-stats-qc-v101-overview)  
- [Links](#related-links)  
- [Inputs](#custom-stats-qc-v101-inputs)  
- [Outputs](#custom-stats-qc-v101-outputs)  
- [ICA](#ica)  


## custom-stats-qc v(1.0.1) Overview



  
> ID: custom-stats-qc--1.0.1  
> md5sum: edfc6026963e978e63d0c51f4000b7e9

### custom-stats-qc v(1.0.1) documentation
  
Documentation for custom-stats-qc v1.0.1

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-stats-qc/1.0.1/custom-stats-qc__1.0.1.cwl)  


### Used By
  
- [ghif-qc 1.0.1](../../../workflows/ghif-qc/1.0.1/ghif-qc__1.0.1.md)  

  


## custom-stats-qc v(1.0.1) Inputs

### output filename



  
> ID: output_json_filename
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
output file


### output samtools stats



  
> ID: output_samtools_stats
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Output txt file from samtools stats


### precise json output



  
> ID: precise_json_output
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Output file from PRECISE calculate_coverage.py script.


### sample id



  
> ID: sample_id
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Sample identity


### sample source



  
> ID: sample_source
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Sample original source

  


## custom-stats-qc v(1.0.1) Outputs

### output file



  
> ID: custom-stats-qc--1.0.1/output_json  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
JSON output file containing custom metrics
  


### output file combined



  
> ID: custom-stats-qc--1.0.1/output_json_combined  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
JSON output file containing custom metrics comsbined with PRECISE QC implementation
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.428005f137ab409296a367db1b9f122e  

  
**workflow name:** custom-stats-qc_dev-wf  
**wfl version name:** 1.0.1  


#### Run Instances

##### ToC
  
- [Run wfr.298a81a7fffb4afba83ad0a3e12163ce](#run-wfr298a81a7fffb4afba83ad0a3e12163ce)  


##### Run wfr.298a81a7fffb4afba83ad0a3e12163ce



  
> Run Name: custom-qc  

  
**Start Time:** 2022-01-27 02:23:24 UTC  
**Duration:** 2022-01-27 02:54:45 UTC  
**End Time:** 0 days 00:31:21  


###### Reproduce Run


```bash

# Run the submission template to create the workflow input json and launch script            
cwl-ica copy-tool-submission-template --ica-workflow-run-instance-id wfr.298a81a7fffb4afba83ad0a3e12163ce

# Edit the input json file (optional)
# vim wfr.298a81a7fffb4afba83ad0a3e12163ce.template.json 

# Run the launch script
bash wfr.298a81a7fffb4afba83ad0a3e12163ce.launch.sh
                                    
```  


###### Run Inputs


```
{
    "output_json_filename": "ghifQC-comb",
    "output_samtools_stats": {
        "class": "File",
        "location": "gds://stratus-sehrish2/ghif-qc/inputs/samtools_stats.txt"
    },
    "precise_json_output": {
        "class": "File",
        "location": "gds://wfr.1f93d95ebbd74f979ecc06744f323944/PRECISE-QC/outputs/NA12878-precise.json"
    },
    "sample_id": "NA12878",
    "sample_source": "GIAB"
}
```  


###### Run Engine Parameters


```
{
    "workDirectory": "gds://wfr.298a81a7fffb4afba83ad0a3e12163ce/custom-qc",
    "outputDirectory": "gds://wfr.298a81a7fffb4afba83ad0a3e12163ce/custom-qc/outputs",
    "tmpOutputDirectory": "gds://wfr.298a81a7fffb4afba83ad0a3e12163ce/custom-qc/steps",
    "logDirectory": "gds://wfr.298a81a7fffb4afba83ad0a3e12163ce/custom-qc/logs",
    "maxScatter": 32,
    "outputSetting": "move",
    "copyOutputInstanceType": "StandardHiCpu",
    "copyOutputInstanceSize": "Medium",
    "defaultInputMode": "'Download'",
    "inputModeOverrides": {},
    "tesUseInputManifest": "'auto'",
    "cwltool": "3.0.20201203173111",
    "engine": "1.20.0-202201191609-develop"
}
```  


###### Run Outputs


```
{
    "output_json": {
        "location": "gds://wfr.298a81a7fffb4afba83ad0a3e12163ce/custom-qc/outputs/ghifQC-comb.json",
        "basename": "ghifQC-comb.json",
        "nameroot": "ghifQC-comb",
        "nameext": ".json",
        "class": "File",
        "size": 2694,
        "http://commonwl.org/cwltool#generation": 0
    },
    "output_json_combined": {
        "location": "gds://wfr.298a81a7fffb4afba83ad0a3e12163ce/custom-qc/outputs/ghifQC-comb_combined.json",
        "basename": "ghifQC-comb_combined.json",
        "nameroot": "ghifQC-comb_combined",
        "nameext": ".json",
        "class": "File",
        "size": 9487,
        "http://commonwl.org/cwltool#generation": 0
    },
    "output_dir_gds_session_id": "ssn.dd3e6a1ed7d44aa988172aa7caefe291",
    "output_dir_gds_folder_id": "fol.be527b0de738477da5cf08d9e1281311"
}
```  


###### Run Resources Usage
  

  
[![custom-qc__wfr.298a81a7fffb4afba83ad0a3e12163ce.svg](../../../../images/runs/tools/custom-stats-qc/1.0.1/custom-qc__wfr.298a81a7fffb4afba83ad0a3e12163ce.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/runs/tools/custom-stats-qc/1.0.1/custom-qc__wfr.298a81a7fffb4afba83ad0a3e12163ce.svg)  

  

