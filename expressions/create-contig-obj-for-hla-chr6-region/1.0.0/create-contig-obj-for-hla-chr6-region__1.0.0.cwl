cwlVersion: v1.1
class: ExpressionTool

# Extensions
$namespaces:
    s: https://schema.org/
    #../../../schemas/contig/1.0.0/contig__1.0.0.yaml#contig: ../../../schemas/contig/1.0.0/contig__1.0.0.yaml#contig

$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: create-contig-obj-for-hla-chr6-region--1.0.0
label: create-contig-obj-for-hla-chr6-region v(1.0.0)
doc: |
    Documentation for create-contig-obj-for-hla-chr6-region
    v1.0.0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_hla_regions_obj_from_genome_version = function(genome_version){
          /*
          Returns the chromsomal HLA region contig object on the genome version we have
          */

          if (genome_version === "hg38") {
            return {
              "chromosome":"chr6",
              "start":29942470,
              "end":31357179
            };
          } else if (genome_version === "GRCh37") {
            return {
              "chromosome":"6",
              "start":29910247,
              "end":31324989
            };
          } else {
            return null;
          }
        }
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/contig/1.0.0/contig__1.0.0.yaml

inputs:
  genome_version:
    label: genome version
    doc: |
      The genome version, hg38 and GRCh37 have different hla-chr6 regions
    type:
      - type: enum
        symbols:
          - hg38
          - GRCh37

outputs:
  contig:
    label: contig
    doc: |
      The output contig object
    type: ../../../schemas/contig/1.0.0/contig__1.0.0.yaml#contig


expression: >-
  ${
    return {"contig": (get_hla_regions_obj_from_genome_version(inputs.genome_version))};
  }
