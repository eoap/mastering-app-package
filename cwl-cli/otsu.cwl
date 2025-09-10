cwlVersion: v1.2

class: CommandLineTool
id: otsu
requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      PATH: /opt/conda/envs/env_otsu/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      PYTHONPATH: /app
  ResourceRequirement:
    coresMax: 1
    ramMax: 512
  NetworkAccess:
    networkAccess: false
hints:
  DockerRequirement:
    dockerPull: localhost/otsu:latest 
baseCommand: ["python", "-m", "app"]
arguments: []
inputs:
  raster:
    type: File
    inputBinding:
      position: 1
outputs:
  binary_mask_item:
    outputBinding:
      glob: '*.tif'
    type: File