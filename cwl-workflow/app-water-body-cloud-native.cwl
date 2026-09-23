$namespaces:
  s: "https://schema.org/"
"@type": "s:SoftwareApplication"
s:name: "Water bodies detection based on NDWI and otsu threshold"
s:description: "Water bodies detection based on NDWI and otsu threshold applied to a single Sentinel-2 COG STAC item"
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
s:softwareVersion: "1.0.0"
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
    label: Water bodies detection based on NDWI and the otsu threshold
    doc: Water bodies detection based on NDWI and otsu threshold applied to a single Sentinel-2 COG STAC item
    requirements:
      - class: SchemaDefRequirement
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
      - class: ScatterFeatureRequirement
    inputs:
      aoi:
        label: area of interest
        doc: GeoJSON polygon defining the area of interest.
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
      epsg:
        label: EPSG code
        doc: EPSG code
        type:
          type: enum
          symbols: ["4326"]
        default: "4326"
      bands:
        label: bands used for the NDWI
        doc: bands used for the NDWI
        type:
          type: array
          items:
            type: enum
            symbols: ["green", "nir", "nir08"]
        default: ["green", "nir"]
      item:
        doc: Reference to a STAC item
        label: STAC item reference
        type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    outputs:
      - id: stac_catalog
        label: Water bodies STAC catalog
        doc: Directory containing the output STAC catalog, items, and water body rasters.
        outputSource:
          - node_stac/stac_catalog
        type: Directory
    steps:
      node_crop:
        label: Crop spectral bands
        doc: Crop each requested band to the area of interest.
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
      node_normalized_difference:
        label: Calculate NDWI
        doc: Calculate the normalized difference from the ordered green and near-infrared rasters.
        run: "#norm_diff"
        in:
          rasters:
            source: node_crop/cropped
        out:
          - ndwi
      node_otsu:
        label: Apply Otsu threshold
        doc: Convert the NDWI raster into a binary water body mask using Otsu thresholding.
        run: "#otsu"
        in:
          raster:
            source: node_normalized_difference/ndwi
        out:
          - binary_mask_item
      node_stac:
        label: Create STAC catalog
        doc: Package the detected water body raster in a STAC catalog.
        run: "#stac"
        in:
          item: item
          rasters:
            source: node_otsu/binary_mask_item
        out:
          - stac_catalog
  - class: CommandLineTool
    id: crop
    label: Crop Spectral Bands
    doc: Crop each requested spectral band to the area of interest.
    requirements:
      SchemaDefRequirement:
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
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
        dockerPull: localhost/crop:latest
    baseCommand: crop
    arguments: []
    inputs:
      item:
        label: Source STAC item
        doc: URL of the source STAC item.
        type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
        inputBinding:
          prefix: --input-item
          valueFrom: $(self.value)
      aoi:
        label: Area of interest
        doc: GeoJSON polygon defining the area of interest.
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Polygon
        inputBinding:
          prefix: --aoi
          valueFrom: $(JSON.stringify(self))
      epsg:
        label: EPSG code
        doc: Coordinate reference system of the area of interest.
        type:
          type: enum
          symbols: ["4326"]
        inputBinding:
          prefix: --epsg
          valueFrom: $(self.split(":").pop())
      band:
        label: Spectral band
        doc: Common name of the spectral band to crop.
        type:
          type: enum
          symbols: ["green", "nir", "nir08"]
        inputBinding:
          prefix: --band
    outputs:
      cropped:
        label: Cropped band
        doc: GeoTIFF containing the selected band cropped to the area of interest.
        outputBinding:
          glob: '*.tif'
        type: File
  - class: CommandLineTool
    id: norm_diff
    label: Normalized Difference Calculation
    doc: Calculate the normalized difference water index (NDWI) from the green and near-infrared spectral band rasters.
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
        label: Spectral band rasters
        doc: Ordered green and near-infrared GeoTIFFs used to calculate NDWI.
        type:
          type: array
          items: File
          inputBinding:
            prefix: --rasters
        inputBinding:
          position: 1
    outputs:
      ndwi:
        label: NDWI raster
        doc: GeoTIFF containing the normalized difference water index.
        outputBinding:
          glob: '*.tif'
        type: File
  - class: CommandLineTool
    id: otsu
    label: Otsu Thresholding
    doc: Apply Otsu thresholding to the NDWI raster to generate a binary water body mask.
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
        label: NDWI raster
        doc: Normalized difference water index raster to threshold.
        type: File
        inputBinding:
          position: 1
          prefix: --raster
    outputs:
      binary_mask_item:
        label: Water body mask
        doc: Binary GeoTIFF mask produced by Otsu thresholding of the NDWI raster.
        outputBinding:
          glob: '*.tif'
        type: File
  - class: CommandLineTool
    id: stac
    label: STAC Generation
    doc: Generate a STAC catalog for the water bodies using the source STAC items and the binary water body masks.
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
        label: Source STAC item
        doc: URL of the source STAC item.
        type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
        inputBinding:
          prefix: --item
          valueFrom: $(self.value)
      rasters:
        label: Water body raster
        doc: Binary water body mask for the source STAC item.
        type: File
        inputBinding:
          prefix: --rasters
    outputs:
      stac_catalog:
        label: Water bodies STAC catalog
        doc: Directory containing the output STAC catalog, items, and water body rasters.
        outputBinding:
          glob: .
        type: Directory
