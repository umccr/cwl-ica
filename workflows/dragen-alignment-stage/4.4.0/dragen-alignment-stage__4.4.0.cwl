cwlVersion: v1.2
class: Workflow

# Extensions
$namespaces:
    s: https://schema.org/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-alignment-stage--4.4.0
label: dragen-alignment-stage v(4.4.0)
doc: |
    Documentation for dragen-alignment-stage v4.4.0

requirements:
    InlineJavascriptRequirement:
      expressionLib:
        - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SubworkflowFeatureRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml
        - $import: ../../../schemas/bam-output/1.0.0/bam-output__1.0.0.yaml
        - $import: ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml
        - $import: ../../../schemas/cram-output/1.0.0/cram-output__1.0.0.yaml
        - $import: ../../../schemas/dragen-wgts-dna-options-alignment-stage/4.4.0/dragen-wgts-dna-options-alignment-stage__4.4.0.yaml

inputs:
  dragen_options:
    type:
      - ../../../schemas/dragen-wgts-dna-options-alignment-stage/4.4.0/dragen-wgts-dna-options-alignment-stage__4.4.0.yaml#dragen-wgts-dna-options-alignment-stage


steps:
  # Check if the input data is a bam or cram file, we first need to set the RGSM to the output prefix
  run_rename_rgsm_step:
    when: |
      ${
        return inputs.run_condition;
      }
    in:
      run_condition:
        source: dragen_options
        valueFrom: |
          ${
            if (self.bam_input || self.cram_input){
              return true;
            } else {
              return false;
            }
          }
      rgsm:
        source: dragen_options
        valueFrom: |
          ${
            /* Does run_validation pass */
            if (self.bam_input || self.cram_input){
              return self.output_prefix;
            }
            /* Otherwise just return nothing, this step wont run anyway */
            return "";
          }
      alignment_file:
        source: dragen_options
        valueFrom: |
          ${
            /* Does run_validation pass */
            if (self.bam_input || self.cram_input){
              if (self.bam_input){
                return self.bam_input;
              }
              return self.cram_input;
            }
            /*
              Otherwise we need to make up a bam_input record just to validate the inputs
              since the **when** condition isnt evaluated until the input objects are validated
            */
            return {
              "class": "File",
              "location": "https://example.com/empty.bam",
              "basename": "empty.bam",
              "secondaryFiles": [
                 {
                    "class": "File",
                    "location": "https://example.com/empty.bam.bai",
                    "basename": "empty.bam.bai"
                 }
              ]
            };
          }
    out:
      - id: alignment_file_out_renamed
    run: ../../../tools/rename-rgsm-in-alignment-header/1.0.0/rename-rgsm-in-alignment-header__1.0.0.cwl


  # Run dragen alignment pipeline
  run_dragen_alignment_step:
    in:
      dragen_options:
        source:
          - run_rename_rgsm_step/alignment_file_out_renamed
          - dragen_options
        valueFrom: |
          ${
            /* Check if output format is set and if not, set BAM as default */
            if (!self[1].output_format){
              self[1].output_format = "BAM";
            }
            /* If run rename rgsm step was never run, just return the alignment options as is */
            if (self[0] === null){
              return self[1];
            }
            /* Otherwise merge */
            /* Initialise the object */
            var renamed_object = {};
            /* Coerce into sequence_data format */
            if (self[0].hasOwnProperty("class") && self[0].class === "File") {
              /* Determine if we have a cram or a bam file */
              if (self[0].nameext == ".bam"){
                renamed_object["bam_input"] = self[0];
              } else if (self[0].nameext == ".cram"){
                renamed_object["cram_input"] = self[0];
              }
            }
            return dragen_merge_options([self[1], renamed_object]);
          }
    run: ../../../tools/dragen-alignment-step/4.4.0/dragen-alignment-step__4.4.0.cwl
    out:
      - id: output_directory
      - id: output_alignment_file


outputs:
  output_directory:
    type: Directory
    outputSource: run_dragen_alignment_step/output_directory
    doc: |
      The output directory of the DRAGEN alignment pipeline.
  output_alignment_file:
    type:
      - ../../../schemas/bam-output/1.0.0/bam-output__1.0.0.yaml#bam-output
      - ../../../schemas/cram-output/1.0.0/cram-output__1.0.0.yaml#cram-output
    outputSource: run_dragen_alignment_step/output_alignment_file
    doc: |
      The output BAM / CRAM file of the DRAGEN alignment pipeline.
