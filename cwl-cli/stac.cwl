cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
# Training-example authors and creation date mirror codemeta.json.
s:name: STAC catalog
s:description: Create a STAC catalog for the water body detection results.
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
s:softwareVersion: 2.0.0

class: CommandLineTool
id: stac
requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  ResourceRequirement:
    coresMax: 1
    ramMax: 512
  NetworkAccess:
    networkAccess: true
  DockerRequirement:
    dockerPull: localhost/stac:latest
baseCommand: stac
arguments: []
inputs:
  item:
    type: string
    inputBinding:
      prefix: --item
    label: STAC item
    doc: STAC item reference identifying the source acquisition.
  raster:
    type: File
    inputBinding:
      prefix: --rasters
    label: Water index raster
    doc: Normalized difference water index raster to threshold.
outputs:
  stac_catalog:
    outputBinding:
      glob: .
    type: Directory
    label: Results STAC catalog
    doc: Directory containing the results STAC catalog and its referenced raster assets.
