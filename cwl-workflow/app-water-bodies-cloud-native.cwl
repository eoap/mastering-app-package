cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.4.1
# Training-example authors and creation date mirror codemeta.json.
s:name: Water bodies detection based on NDWI and otsu threshold
s:description: Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items
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
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  - class: Workflow
    id: water-bodies
    label: Water bodies detection based on NDWI and otsu threshold
    doc: Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items
    requirements:
      - class: ScatterFeatureRequirement
      - class: SubworkflowFeatureRequirement
      - class: SchemaDefRequirement
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
          - $import: eoap-types.yaml
    inputs:
      aoi:
        label: area of interest
        doc: GeoJSON Polygon defining the area to crop; raster pixels outside the polygon are masked.
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
      epsg:
        label: EPSG code
        doc: EPSG code
        type: 'eoap-types.yaml#EPSGCode'
        default: "4326"
      stac_items:
        label: Sentinel-2 STAC items
        doc: list of Sentinel-2 COG STAC items
        type:
          type: array
          items: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      bands:
        label: bands used for the NDWI
        doc: bands used for the NDWI
        type:
          type: array
          items: 'eoap-types.yaml#SpectralBand'
        default: ["green", "nir"]
    outputs:
      - id: stac_catalog
        outputSource:
          - node_stac/stac_catalog
        type: Directory
        label: Results STAC catalog
        doc: Directory containing the results STAC catalog and its referenced raster assets.
    steps:
      node_water_bodies:
        run: "#detect_water_body"
        in:
          item: stac_items
          aoi: aoi
          epsg: epsg
          bands: bands
        out:
          - detected_water_body
        scatter: item
        scatterMethod: dotproduct
        label: Process acquisitions
        doc: Run water body detection for each input STAC item.
      node_stac:
        run: "#stac"
        in:
          item: stac_items
          rasters:
            source: node_water_bodies/detected_water_body
        out:
          - stac_catalog
        label: Catalog results
        doc: Create a STAC catalog describing the detected water bodies.
  - class: Workflow
    id: detect_water_body
    label: Water body detection based on NDWI and otsu threshold
    doc: Water body detection based on NDWI and otsu threshold
    requirements:
      - class: ScatterFeatureRequirement
      - class: SchemaDefRequirement
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
          - $import: eoap-types.yaml
    inputs:
      aoi:
        doc: GeoJSON Polygon defining the area to crop; raster pixels outside the polygon are masked.
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
        label: Area of interest
      epsg:
        doc: EPSG code
        type: 'eoap-types.yaml#EPSGCode'
        default: "4326"
        label: Coordinate reference system
      bands:
        doc: bands used for the NDWI
        type:
          type: array
          items: 'eoap-types.yaml#SpectralBand'
        label: NDWI bands
      item:
        doc: STAC item
        type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
        label: STAC item
    outputs:
      - id: detected_water_body
        outputSource:
          - node_otsu/binary_mask_item
        type: File
        label: Detected water body
        doc: Binary raster mask produced by the nested water body detection workflow.
    steps:
      node_crop:
        run: "#crop"
        in:
          item: item
          aoi: aoi
          epsg: epsg
          band: bands
        out:
          - cropped
        scatter: band
        scatterMethod: dotproduct
        label: Crop bands
        doc: Crop the selected bands to the area of interest.
      node_normalized_difference:
        run: "#norm_diff"
        in:
          rasters:
            source: node_crop/cropped
        out:
          - ndwi
        label: Compute NDWI
        doc: Compute the normalized difference water index from the cropped bands.
      node_otsu:
        run: "#otsu"
        in:
          raster:
            source: node_normalized_difference/ndwi
        out:
          - binary_mask_item
        label: Detect water bodies
        doc: Apply the Otsu threshold to produce a binary water body mask.
  - class: CommandLineTool
    id: crop
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
        dockerPull: localhost/crop:latest
      SchemaDefRequirement:
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
          - $import: eoap-types.yaml
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
        type: 'eoap-types.yaml#EPSGCode'
        inputBinding:
          prefix: --epsg
          valueFrom: $(self.split(":").pop())
        label: Coordinate reference system
        doc: EPSG code of the coordinate reference system used for the area of interest.
      band:
        type: 'eoap-types.yaml#SpectralBand'
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
  - class: CommandLineTool
    id: norm_diff
    requirements:
      InlineJavascriptRequirement: {}
      EnvVarRequirement:
        envDef:
          PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement:
        coresMax: 1
        ramMin: 2048
        ramMax: 2048
      NetworkAccess:
        networkAccess: false
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
        label: Input rasters
        doc: Raster files used for normalized difference computation or catalog generation.
    outputs:
      ndwi:
        outputBinding:
          glob: '*.tif'
        type: File
        label: Normalized difference water index
        doc: Water index raster computed from the input bands.
  - class: CommandLineTool
    id: otsu
    requirements:
      InlineJavascriptRequirement: {}
      EnvVarRequirement:
        envDef:
          PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
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
  - class: CommandLineTool
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
      SchemaDefRequirement:
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
    baseCommand: stac
    arguments: []
    inputs:
      item:
        type:
          type: array
          items: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
          inputBinding:
            prefix: --item
            valueFrom: $(self.value)
        label: STAC item
        doc: STAC item reference identifying the source acquisition.
      rasters:
        type:
          type: array
          items: File
          inputBinding:
            prefix: --rasters
        label: Input rasters
        doc: Raster files used for normalized difference computation or catalog generation.
    outputs:
      stac_catalog:
        outputBinding:
          glob: .
        type: Directory
        label: Results STAC catalog
        doc: Directory containing the results STAC catalog and its referenced raster assets.
