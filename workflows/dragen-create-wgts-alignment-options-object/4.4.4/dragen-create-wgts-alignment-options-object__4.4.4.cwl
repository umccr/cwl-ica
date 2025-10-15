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
id: dragen-create-wgts-alignment-options-object--4.4.4
label: dragen-create-wgts-alignment-options-object v(4.4.4)
doc: |
  Documentation for dragen-create-wgts-alignment-options-object
  v4.4.4

requirements:
  SubworkflowFeatureRequirement: { }
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs
  ScatterFeatureRequirement: { }
  MultipleInputFeatureRequirement: { }
  StepInputExpressionRequirement: { }
  SchemaDefRequirement:
    types:
      # I/O Schema
      - $import: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml

inputs:
  # Inputs
  alignment_options:
    label: alignment options
    doc: |
      Alignment input options
    type: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml#dragen-wgts-alignment-options

steps:
  # Purely for the purposes of packing cwl correctly, we also need to manually parse every sub-schema that is imported
  # This step does not actually run anything
  parse_qc_coverage:
    # Never
    when: |
      ${
        return false;
      }
    in:
      dragen_qc_coverage:
        source: alignment_options
        valueFrom: |
          ${
            if (self.dragen_qc_coverage) {
              return self.dragen_qc_coverage;
            } else {
              return null;
            };
          }
    out: [ ]
    run: ../../../expressions/dragen-parse-qc-coverage/1.0.0/dragen-parse-qc-coverage__1.0.0.cwl

  # Option coercion steps
  coerce_mapper_options_step:
    in:
      mapper_options:
        source: alignment_options
        valueFrom: |
          ${
            if (!self.mapper) {
              return {};
            } else {
              return self.mapper;
            }
          }
    out:
      - id: mapper_options_output
    run: ../../dragen-create-mapper-options-object/4.4.4/dragen-create-mapper-options-object__4.4.4.cwl
  coerce_aligner_options_step:
    in:
      aligner_options:
        source: alignment_options
        valueFrom: |
          ${
            if (!self.aligner) {
              return {};
            } else {
              return self.aligner;
            }
          }
    out:
      - id: aligner_options_output
    run: ../../dragen-create-aligner-options-object/4.4.4/dragen-create-aligner-options-object__4.4.4.cwl
  coerce_alignment_options:
    in:
      dragen_wgts_alignment_options:
        source:
          - alignment_options
          - coerce_mapper_options_step/mapper_options_output
          - coerce_aligner_options_step/aligner_options_output
        valueFrom: |
          ${
            /*
              self[0] - alignment_options
              self[1] - mapper_options
              self[2] - aligner_options
            */
            /* check alignment options are empty */
            if (!self[0]) {
              return {
                "mapper": self[1],
                "aligner": self[2]
              }
            }
            /* alignment options are non empty */
            else {
              /* check mapper options are empty */
              if (!self[0].mapper){
                var mapper = self[1];
              } else {
                var mapper = self[0].mapper;
              }
              /* check aligner options are empty */
              if (!self[0].aligner){
                var aligner = self[2];
              } else {
                var aligner = self[0].aligner;
              }
              /* Merge object */
              return dragen_merge_options([
                self[0],
                {
                  "mapper": mapper,
                  "aligner": aligner
                }
              ]);
            }
          }
    out:
      - id: dragen_wgts_alignment_options_output
    run: ../../../expressions/dragen-wgts-parse-alignment-schema/4.4.4/dragen-wgts-parse-alignment-schema__4.4.4.cwl

outputs:
  alignment_options_output:
    label: alignment options output
    doc: |
      Output file, of varying format depending on the command run
    outputSource: coerce_alignment_options/dragen_wgts_alignment_options_output
    type: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml#dragen-wgts-alignment-options
