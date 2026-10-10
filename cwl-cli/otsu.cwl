cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
# Training-example authors and creation date mirror codemeta.json.
s:name: Otsu threshold
s:description: Detect water bodies by applying the Otsu threshold to a water index raster.
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
id: otsu
requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024
    ramMax: 1024
  NetworkAccess:
    networkAccess: false
  DockerRequirement:
    dockerPull: localhost/otsu:latest
baseCommand: otsu
arguments: []
inputs:
  raster:
    type: File
    inputBinding:
      position: 1
      prefix: --raster
    label: Water index raster
    doc: Normalized difference water index raster to threshold.
outputs:
  binary_mask_item:
    outputBinding:
      glob: '*.tif'
    type: File
    label: Water body mask
    doc: Binary raster mask identifying detected water bodies.
