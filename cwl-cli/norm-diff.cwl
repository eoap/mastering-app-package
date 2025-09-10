cwlVersion: v1.2

class: CommandLineTool
id: norm_diff
requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      PYTHONPATH: /app
  ResourceRequirement:
    coresMax: 1
    ramMax: 512
  NetworkAccess:
    networkAccess: false
hints:
  DockerRequirement:
    dockerPull: localhost/norm-diff:latest
baseCommand: ["python", "-m", "app"]
arguments: []
inputs:
  rasters:
    type: File[]
    inputBinding:
      position: 1
outputs:
  ndwi:
    outputBinding:
      glob: '*.tif'
    type: File