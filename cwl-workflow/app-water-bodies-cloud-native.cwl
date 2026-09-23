$namespaces:
  s: "https://schema.org/"
"@type": "s:SoftwareApplication"
s:name: "Water bodies detection based on NDWI and otsu threshold"
s:description: "Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items"
s:dateCreated: "2026-09-23"
s:license:
  "@type": "s:CreativeWork"
  s:identifier: "CC-BY-NC-SA-1.0"
  s:name: "Creative Commons Attribution Non Commercial Share Alike 1.0 Generic"
  s:url: "https://spdx.org/licenses/CC-BY-NC-SA-1.0.html"
s:keywords:
  - "Water cycle"
s:operatingSystem:
  - "Linux"
s:softwareVersion: "1.4.1"
s:softwareHelp:
  - "@type": "s:CreativeWork"
    s:name: "Documentation"
    s:url: "https://eoap.github.io/mastering-app-package"
s:publisher:
  "@type": "s:Organization"
  s:name: "Terradue Srl"
  s:email: "info@terradue.com"
  s:identifier: "https://ror.org/0069cx113"
s:author:
  - "@type": "s:Role"
    s:roleName: "Software"
    s:additionalType: "https://credit.niso.org/contributor-roles/software/"
    s:author:
      "@type": "s:Person"
      s:givenName: "Fabrice"
      s:familyName: "Brito"
      s:email: "info@terradue.com"
      s:identifier: "https://orcid.org/0009-0000-1342-9736"
      s:affiliation:
        "@type": "s:Organization"
        s:name: "Terradue Srl"
        s:email: "info@terradue.com"
        s:identifier: "https://ror.org/0069cx113"

cwlVersion: v1.2
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
    inputs:
      aoi:
        label: area of interest
        doc: area of interest as a bounding box
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
      epsg:
        label: EPSG code
        doc: EPSG code
        type:
          type: enum
          symbols: ["4326"]
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
          items:
            type: enum
            symbols: ["green", "nir", "nir08"]
        default: ["green", "nir"]
    outputs:
      - id: stac_catalog
        label: Water bodies STAC catalog
        doc: Directory containing the output STAC catalog, items, and water body rasters.
        outputSource:
          - step_stac/stac_catalog
        type: Directory
    steps:
      step_water_bodies:
        run: "#detect_water_body"
        label: Detect water bodies
        doc: Detect water bodies independently for each input STAC item.
        in:
          item: stac_items
          aoi: aoi
          epsg: epsg
          bands: bands
        out:
          - detected_water_body
        scatter: item
        scatterMethod: dotproduct
      step_stac:
        run: "#stac"
        label: Create STAC catalog
        doc: Package the detected water body rasters in a STAC catalog.
        in:
          item: stac_items
          rasters:
            source: step_water_bodies/detected_water_body
        out:
          - stac_catalog
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
    inputs:
      aoi:
        doc: area of interest as a bounding box
        label: Area of interest
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
      epsg:
        doc: EPSG code
        label: EPSG code
        type:
          type: enum
          symbols: ["4326"]
        default: "4326"
      bands:
        doc: bands used for the NDWI
        label: NDWI bands
        type:
          type: array
          items:
            type: enum
            symbols: ["green", "nir", "nir08"]
      item:
        doc: STAC item
        label: Source STAC item
        type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    outputs:
      - id: detected_water_body
        label: Detected water body
        doc: Binary GeoTIFF mask identifying water in the area of interest.
        outputSource:
          - step_otsu/binary_mask_item
        type: File
    steps:
      step_crop:
        run: "#crop"
        label: Crop spectral bands
        doc: Crop each requested band to the area of interest.
        in:
          item: item
          aoi: aoi
          epsg: epsg
          band: bands
        out:
          - cropped
        scatter: band
        scatterMethod: dotproduct
      step_normalized_difference:
        run: "#norm_diff"
        label: Calculate NDWI
        doc: Calculate the normalized difference from the ordered green and near-infrared rasters.
        in:
          rasters:
            source: step_crop/cropped
        out:
          - norm_diff_raster
      step_otsu:
        run: "#otsu"
        label: Apply Otsu threshold
        doc: Convert the NDWI raster into a binary water body mask using Otsu thresholding.
        in:
          raster:
            source: step_normalized_difference/norm_diff_raster
        out:
          - binary_mask_item
  - class: CommandLineTool
    id: crop
    label: "Crop Spectral Bands"
    doc: "Crop each requested spectral band to the area of interest."
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
      SchemaDefRequirement:
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
      DockerRequirement:
        dockerPull: localhost/crop:latest
    baseCommand: crop
    inputs:
      item:
        type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
        label: Source STAC item
        doc: URL of the source STAC item.
        inputBinding:
          prefix: --input-item
          valueFrom: $(self.value)
      aoi:
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
        label: Area of interest
        doc: GeoJSON polygon defining the area of interest.
        inputBinding:
          prefix: --aoi
          valueFrom: $(JSON.stringify(self))
      epsg:
        type:
          type: enum
          symbols: ["4326"]
        label: EPSG code
        doc: Coordinate reference system of the area of interest.
        inputBinding:
          prefix: --epsg
          valueFrom: $(self.split(":").pop())
      band:
        type:
          type: enum
          symbols: ["green", "nir", "nir08"]
        label: Spectral band
        doc: Common name of the spectral band to crop.
        inputBinding:
          prefix: --band
    outputs:
      cropped:
        outputBinding:
          glob: '*.tif'
        label: Cropped band
        doc: GeoTIFF containing the selected band cropped to the area of interest.
        type: File
  - class: CommandLineTool
    id: norm_diff
    label: "Normalized Difference Calculation"
    doc: "Calculate the normalized difference water index (NDWI) from the green and near-infrared spectral band rasters."
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
        label: Spectral band rasters
        doc: Ordered green and near-infrared GeoTIFFs used to calculate NDWI.
        inputBinding:
          position: 1
    outputs:
      norm_diff_raster:
        outputBinding:
          glob: '*.tif'
        label: NDWI raster
        doc: GeoTIFF containing the normalized difference water index.
        type: File
  - class: CommandLineTool
    id: otsu
    label: "Otsu Thresholding"
    doc: "Apply Otsu thresholding to the NDWI raster to generate a binary water body mask."
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
      DockerRequirement:
        dockerPull: localhost/otsu:latest
    baseCommand: otsu
    arguments: []
    inputs:
      raster:
        type: File
        label: NDWI raster
        doc: Normalized difference water index raster to threshold.
        inputBinding:
          position: 1
          prefix: --raster
    outputs:
      binary_mask_item:
        outputBinding:
          glob: '*.tif'
        label: Water body mask
        doc: Binary GeoTIFF mask produced by Otsu thresholding of the NDWI raster.
        type: File
  - class: CommandLineTool
    id: stac
    label: "STAC Generation"
    doc: "Generate a STAC catalog for the water bodies using the source STAC items and the binary water body masks."
    requirements:
      SchemaDefRequirement:
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
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
      DockerRequirement:
        dockerPull: localhost/stac:latest
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
        label: Source STAC items
        doc: Source STAC item URLs in the same order as the water body masks.
      rasters:
        type:
          type: array
          items: File
          inputBinding:
            prefix: --rasters
        label: Water body rasters
        doc: Binary water body masks in the same order as the source STAC items.
    outputs:
      stac_catalog:
        outputBinding:
          glob: .
        label: Water bodies STAC catalog
        doc: Directory containing the output STAC catalog, items, and water body rasters.
        type: Directory
