cwlVersion: v1.2

class: CommandLineTool
id: stac
requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      PYTHONPATH: /app
  ResourceRequirement:
    coresMax: 1
    ramMax: 512
  NetworkAccess:
    networkAccess: true
hints:
  DockerRequirement:
    dockerPull: localhost/stac:latest 
baseCommand: stac
arguments: []
inputs:
  item:
    type: string
    inputBinding:
      prefix: --item
  raster:
    type: File
    inputBinding:
      prefix: --rasters
outputs:
  stac_catalog:
    outputBinding:
      glob: .
    type: Directory