cwlVersion: v1.2

class: CommandLineTool
id: norm_diff
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
    networkAccess: false
hints:
  DockerRequirement:
    dockerPull: localhost/norm-diff:latest
baseCommand: norm_diff
arguments: []
inputs:
  rasters:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --rasters
    inputBinding:
      position: 1
outputs:
  ndwi:
    outputBinding:
      glob: '*.tif'
    type: File