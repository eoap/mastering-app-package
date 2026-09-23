cwlVersion: v1.2

class: CommandLineTool
id: crop
requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PYTHONPATH: /app
    ResourceRequirement:
      coresMax: 1
      ramMax: 512
    NetworkAccess:
      networkAccess: true
    SchemaDefRequirement:
      types:
        - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
        - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
hints:
  DockerRequirement:
    dockerPull: localhost/crop:latest
baseCommand: crop
arguments: []
inputs:
  item:
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URL
    inputBinding:
        prefix: --input-item
  aoi:
    type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
    inputBinding:
        prefix: --aoi
  epsg:
    type: string
    inputBinding:
        prefix: --epsg
        valueFrom: $(self.split(":").pop())
  band:
    type: string
    inputBinding:
        prefix: --band
outputs:
  cropped:
    outputBinding:
        glob: '*.tif'
    type: File



