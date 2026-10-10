cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
# Training-example authors and creation date mirror codemeta.json.
s:name: Normalized difference
s:description: Compute the normalized difference water index from cropped raster
  bands.
s:dateCreated: '2022-09-01'
s:license:
  s:name: Creative Commons Attribution-ShareAlike 4.0 International
  s:url: https://creativecommons.org/licenses/by-sa/4.0/
  s:identifier: CC-BY-SA-4.0
s:softwareHelp:
  s:name: Mastering Earth Observation Application Packaging with CWL
  s:url: https://eoap.github.io/mastering-app-package
s:publisher:
  s:name: EO Application Packaging
  s:identifier: https://github.com/eoap
s:author:
- s:givenName: Jane
  s:familyName: Doe
  s:email: jane.doe@acme.earth
  s:affiliation:
    s:name: ACME
- s:givenName: John
  s:familyName: Doe
  s:email: john.doe@acme.earth
  s:affiliation:
    s:name: ACME
s:softwareRequirements:
- container runtime
- cwl runner
s:softwareVersion: 1.1.0

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