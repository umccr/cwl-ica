
dragen-wgs-qc-pipeline 3.9.3 workflow
=====================================

## Table of Contents
  
- [Overview](#dragen-wgs-qc-pipeline-v393-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-wgs-qc-pipeline-v393-inputs)  
- [Steps](#dragen-wgs-qc-pipeline-v393-steps)  
- [Outputs](#dragen-wgs-qc-pipeline-v393-outputs)  
- [ICA](#ica)  


## dragen-wgs-qc-pipeline v(3.9.3) Overview



  
> ID: dragen-wgs-qc-pipeline--3.9.3  
> md5sum: 5b3d7bf6ce146befa5eda34e202699cf

### dragen-wgs-qc-pipeline v(3.9.3) documentation
  
Documentation for dragen-wgs-qc-pipeline v3.9.3

### Categories
  
- dragen  


## Visual Workflow Overview
  
[![dragen-wgs-qc-pipeline__3.9.3.svg](../../../../images/workflows/dragen-wgs-qc-pipeline/3.9.3/dragen-wgs-qc-pipeline__3.9.3.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/dragen-wgs-qc-pipeline/3.9.3/dragen-wgs-qc-pipeline__3.9.3.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/dragen-wgs-qc-pipeline/3.9.3/dragen-wgs-qc-pipeline__3.9.3.cwl)  


### Uses
  
- [dragen-alignment-pipeline 3.9.3](../../dragen-alignment-pipeline/3.9.3/dragen-alignment-pipeline__3.9.3.md)  
- [somalier-extract 0.2.13 :construction:](../../../tools/somalier-extract/0.2.13/somalier-extract__0.2.13.md)  

  


## dragen-wgs-qc-pipeline v(3.9.3) Inputs

### Row of fastq lists



  
> ID: fastq_list_rows
  
**Optional:** `False`  
**Type:** `fastq-list-row[]`  
**Docs:**  
The row of fastq lists.
Each row has the following attributes:
  * RGID
  * RGLB
  * RGSM
  * Lane
  * Read1File
  * Read2File (optional)


### output directory



  
> ID: output_directory
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The directory where all output files are placed


### output file prefix



  
> ID: output_file_prefix
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The prefix given to all output files


### reference fasta



  
> ID: reference_fasta
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
FastA file with genome sequence


### reference tar



  
> ID: reference_tar
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to ref data tarball


### sites somalier



  
> ID: sites_somalier
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
gzipped vcf file. Required for somalier sites

  


## dragen-wgs-qc-pipeline v(3.9.3) Steps

### run dragen alignment step


  
> ID: dragen-wgs-qc-pipeline--3.9.3/run_dragen_step
  
**Step Type:** workflow  
**Docs:**
  
Runs the alignment step on a dragen fpga
Takes in a fastq list and corresponding mount paths from the predefined mount paths
All other options available at the top of the workflow

#### Links
  
[CWL File Path](../../../../../../workflows/dragen-alignment-pipeline/3.9.3/dragen-alignment-pipeline__3.9.3.cwl)  
[CWL File Help Page](../../dragen-alignment-pipeline/3.9.3/dragen-alignment-pipeline__3.9.3.md)
#### Subworkflow overview
  
[![dragen-alignment-pipeline__3.9.3.svg](../../../../images/workflows/dragen-alignment-pipeline/3.9.3/dragen-alignment-pipeline__3.9.3.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/dragen-alignment-pipeline/3.9.3/dragen-alignment-pipeline__3.9.3.svg)  


### somalier


  
> ID: dragen-wgs-qc-pipeline--3.9.3/run_somalier_step
  
**Step Type:** tool  
**Docs:**
  
Runs the somalier extract function to call the fingerprint on the germline bam file

#### Links
  
[CWL File Path](../../../../../../tools/somalier-extract/0.2.13/somalier-extract__0.2.13.cwl)  
[CWL File Help Page :construction:](../../../tools/somalier-extract/0.2.13/somalier-extract__0.2.13.md)  


## dragen-wgs-qc-pipeline v(3.9.3) Outputs

### dragen alignment output directory



  
> ID: dragen-wgs-qc-pipeline--3.9.3/dragen_alignment_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all alignment output files and qc metrics
  


### dragen bam out



  
> ID: dragen-wgs-qc-pipeline--3.9.3/dragen_bam_out  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The output alignment file
  


### dragen QC report out



  
> ID: dragen-wgs-qc-pipeline--3.9.3/multiqc_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The dragen multiQC output
  


### somalier output directory



  
> ID: dragen-wgs-qc-pipeline--3.9.3/somalier_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output directory from somalier step
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [production_workflows](#project-production_workflows)  


### Project: development_workflows


> wfl id: wfl.ff6ca1789f4e4eb0982ea3e01407aca8  

  
**workflow name:** dragen-wgs-qc-pipeline_dev-wf  
**wfl version name:** 3.9.3  


#### Run Instances

##### ToC
  
- [Run wfr.8bb7083dc6e74a2f9c21edd65e627a2e](#run-wfr8bb7083dc6e74a2f9c21edd65e627a2e)  


##### Run wfr.8bb7083dc6e74a2f9c21edd65e627a2e



  
> Run Name: Dragen-3.9-WGS-QC  

  
**Start Time:** 2021-09-17 01:44:34 UTC  
**Duration:** 2021-09-17 04:09:45 UTC  
**End Time:** 0 days 02:25:10  


###### Reproduce Run


```bash

# Run the submission template to create the workflow input json and launch script            
cwl-ica copy-workflow-submission-template --ica-workflow-run-instance-id wfr.8bb7083dc6e74a2f9c21edd65e627a2e

# Edit the input json file (optional)
# vim wfr.8bb7083dc6e74a2f9c21edd65e627a2e.template.json 

# Run the launch script
bash wfr.8bb7083dc6e74a2f9c21edd65e627a2e.launch.sh
                                    
```  


###### Run Inputs


```
{
    "fastq_list_rows": [
        {
            "lane": 1,
            "read_1": {
                "class": "File",
                "location": "gds://umccr-fastq-data-dev/210708_A00130_0166_AH7KTJDSX2/WGS_TsqNano/VCCC/MDX210176_L2100746_S6_L001_R1_001.fastq.gz"
            },
            "read_2": {
                "class": "File",
                "location": "gds://umccr-fastq-data-dev/210708_A00130_0166_AH7KTJDSX2/WGS_TsqNano/VCCC/MDX210176_L2100746_S6_L001_R2_001.fastq.gz"
            },
            "rgid": "GCAATGCA.AACGTTCC.1.210708_A00130_0166_AH7KTJDSX2.MDX210176_L2100746",
            "rglb": "L2100746",
            "rgsm": "MDX210176"
        }
    ],
    "output_directory": "L2100746_dragen",
    "output_file_prefix": "L2100746",
    "reference_fasta": {
        "class": "File",
        "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/hg38.fa"
    },
    "reference_tar": {
        "class": "File",
        "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/hg38_alt_ht_3_7_5.tar.gz"
    },
    "sites_somalier": {
        "class": "File",
        "location": "gds://umccr-refdata-dev/somalier/sites.hg38.vcf.gz"
    }
}
```  


###### Run Engine Parameters


```
{
    "workDirectory": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC",
    "outputDirectory": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC/outputs",
    "tmpOutputDirectory": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC/steps",
    "logDirectory": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC/logs",
    "maxScatter": 32,
    "outputSetting": "move",
    "copyOutputInstanceType": "StandardHiCpu",
    "copyOutputInstanceSize": "Medium",
    "defaultInputMode": "'Download'",
    "inputModeOverrides": {},
    "tesUseInputManifest": "'auto'",
    "cwltool": "3.0.20201203173111",
    "engine": "1.17.0-202107161017-stratus-master"
}
```  


###### Run Outputs


```
{
    "dragen_alignment_output_directory": {
        "location": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC/outputs/L2100746_dragen",
        "basename": "L2100746_dragen",
        "nameroot": "",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "dragen_bam_out": {
        "location": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC/outputs/L2100746_dragen/L2100746.bam",
        "basename": "L2100746.bam",
        "nameroot": "L2100746",
        "nameext": ".bam",
        "class": "File",
        "size": 150833829028,
        "secondaryFiles": [
            {
                "basename": "L2100746.bam.bai",
                "location": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC/outputs/L2100746_dragen/L2100746.bam.bai",
                "class": "File",
                "nameroot": "L2100746.bam",
                "nameext": ".bai",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "multiqc_output_directory": {
        "location": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC/outputs/L2100746_dragen_alignment_multiqc",
        "basename": "L2100746_dragen_alignment_multiqc",
        "nameroot": "",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "somalier_output_directory": {
        "location": "gds://wfr.8bb7083dc6e74a2f9c21edd65e627a2e/Dragen-3.9-WGS-QC/outputs/L2100746_dragen_somalier",
        "basename": "L2100746_dragen_somalier",
        "nameroot": "",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "output_dir_gds_session_id": "ssn.464051c4a76343ac95117c07e7c7e265",
    "output_dir_gds_folder_id": "fol.46d901daf3a14a84796c08d973f0874d"
}
```  


###### Run Resources Usage
  

  
[![Dragen-3.9-WGS-QC__wfr.8bb7083dc6e74a2f9c21edd65e627a2e.svg](../../../../images/runs/workflows/dragen-wgs-qc-pipeline/3.9.3/Dragen-3.9-WGS-QC__wfr.8bb7083dc6e74a2f9c21edd65e627a2e.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/runs/workflows/dragen-wgs-qc-pipeline/3.9.3/Dragen-3.9-WGS-QC__wfr.8bb7083dc6e74a2f9c21edd65e627a2e.svg)  


### Project: production_workflows


> wfl id: wfl.23f61cb1baab412a8c37dc93bed6c2af  

  
**workflow name:** dragen-wgs-qc-pipeline_prod-wf  
**wfl version name:** 3.9.3--aecc72e  

  

