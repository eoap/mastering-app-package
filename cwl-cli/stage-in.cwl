cwlVersion: v1.2

class: CommandLineTool
id: stage-in
label: "Stage In"
doc: "Stage in a reference file from a URL"
inputs:
  reference:
    label: "Reference URL"
    doc: "The URL of the reference file to stage in"
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URL
    inputBinding:
      prefix: --reference
      valueFrom: $(self.value)
outputs:
  staged:
    label: "Staged Directory"
    doc: "The directory where the reference file has been staged in"
    type: Directory
    outputBinding:
      glob: .
baseCommand: stage-in
requirements:
  DockerRequirement:
    dockerPull: localhost/stage:latest
  NetworkAccess:
    networkAccess: true
  SchemaDefRequirement:
      types:
        - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
