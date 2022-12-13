cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: http://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: map_resource_requirements--0.1.0
label: map_resource_requirements v(0.1.0)
doc: |
    Documentation for map_resource_requirements v0.1.0

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            type: $(calcInstanceType(inputs.input_size))
            size: small
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: bash:5

requirements:
    InlineJavascriptRequirement:
      expressionLib:
        - |
          var calcMem = function calcMem(instanceType) {
            var mem_from_instance_type = {
                "small"  : "64m",
                "medium" : "256m",
                "large"  : "1g",
                }

            if (!(instanceType in mem_from_instance_type)) {
                return "default-mem"
                }

            return mem_from_instance_type[instanceType];
            }

          var calcInstanceType = function calcInstanceType(type) {
            var instance_type_from_mem = {
                "small"  : "Standard",
                "medium" : "StandardHiCpu",
                "large"   : "StandardHighIo"
                }

            if (!(type in instance_type_from_mem)) {
                return "Standard"
                }

            return instance_type_from_mem[type];
            }

          var calcCoresNumber = function calcCoresNumber(cores) {
            var cores_from_type = {
                "small"  : 2,
                "medium" : 3,
                "large"   : 4
                }

            if (!(cores in cores_from_type)) {
                return 2
                }

            return cores_from_type[cores];
            }

baseCommand: [echo]

inputs:
  input_size:
    label: input size
    doc: |
      The input size
    type: string?
    default: "128m"
    inputBinding:
      prefix: "--mem"
      valueFrom: $(calcMem(self))

outputs:
  output_file:
    label: output file
    doc: |
      The output file
    type: stdout

stdout: stdout.txt

successCodes:
  - 0
