cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
# Training-example authors and creation date mirror codemeta.json.
s:name: Crop a STAC item band
s:description: Crop a selected raster band to an area of interest.
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
id: crop
requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMax: 512
  NetworkAccess:
    networkAccess: true
  DockerRequirement:
    dockerPull: localhost/crop:latest
  SchemaDefRequirement:
    types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
baseCommand: crop
arguments: []
inputs:
  item:
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    inputBinding:
      prefix: --input-item
      valueFrom: $(self.value)
    label: STAC item
    doc: STAC item reference identifying the source acquisition.
  aoi:
    type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
    inputBinding:
      prefix: --aoi
      valueFrom: $(JSON.stringify(self))
    label: Area of interest
    doc: GeoJSON Polygon defining the area to crop; raster pixels outside the polygon are masked.
  epsg:
    type: string
    inputBinding:
      prefix: --epsg
      valueFrom: $(self.split(":").pop())
    label: Coordinate reference system
    doc: EPSG code of the coordinate reference system used for the area of interest.
  band:
    type: string
    inputBinding:
      prefix: --band
    label: Raster band
    doc: Name of the STAC asset band to crop.
outputs:
  cropped:
    outputBinding:
      glob: '*.tif'
    type: File



    label: Cropped raster
    doc: Raster band cropped to the area of interest.
