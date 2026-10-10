cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
# Training-example authors and creation date mirror codemeta.json.
s:name: Water bodies detection based on NDWI and the otsu threshold
s:description: Water bodies detection based on NDWI and otsu threshold applied to a single Sentinel-2 COG STAC item
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
    label: Water bodies detection based on NDWI and the otsu threshold
    doc: Water bodies detection based on NDWI and otsu threshold applied to a single Sentinel-2 COG STAC item
    requirements:
      - class: ScatterFeatureRequirement
    inputs:
      aoi:
        label: area of interest
        doc: area of interest as a bounding box
        type: string
      epsg:
        label: EPSG code
        doc: EPSG code
        type: string
        default: "EPSG:4326"
      bands:
        label: bands used for the NDWI
        doc: bands used for the NDWI
        type: string[]
        default: ["green", "nir"]
      item:
        doc: Reference to a STAC item
        label: STAC item reference
        type: string
    outputs:
      - id: stac_catalog
        outputSource:
          - node_stac/stac_catalog
        type: Directory
        label: Results STAC catalog
        doc: Directory containing the results STAC catalog and its referenced raster assets.
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
      node_stac:
        run: "#stac"
        in:
          item: item
          rasters:
            source: node_otsu/binary_mask_item
        out:
          - stac_catalog
        label: Catalog results
        doc: Create a STAC catalog describing the detected water bodies.
  - class: CommandLineTool
    id: crop
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
        networkAccess: true
      DockerRequirement:
        dockerPull: localhost/crop:latest
    baseCommand: ["python", "-m", "app"]
    arguments: []
    inputs:
      item:
        type: string
        inputBinding:
          prefix: --input-item
        label: STAC item
        doc: STAC item reference identifying the source acquisition.
      aoi:
        type: string
        inputBinding:
          prefix: --aoi
        label: Area of interest
        doc: Bounding box delimiting the area to process, expressed in the specified coordinate reference system.
      epsg:
        type: string
        inputBinding:
          prefix: --epsg
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
  - class: CommandLineTool
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
      DockerRequirement:
        dockerPull: localhost/norm-diff:latest
    baseCommand: ["python", "-m", "app"]
    arguments: []
    inputs:
      rasters:
        type: File[]
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
          PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
          PYTHONPATH: /app
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
      NetworkAccess:
        networkAccess: false
      DockerRequirement:
        dockerPull: localhost/otsu:latest
    baseCommand: ["python", "-m", "app"]
    arguments: []
    inputs:
      raster:
        type: File
        inputBinding:
          position: 1
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
          PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
          PYTHONPATH: /app
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
      NetworkAccess:
        networkAccess: true
      DockerRequirement:
        dockerPull: localhost/stac:latest
    baseCommand: ["python", "-m", "app"]
    arguments: []
    inputs:
      item:
        type: string
        inputBinding:
          prefix: --input-item
        label: STAC item
        doc: STAC item reference identifying the source acquisition.
      rasters:
        type: File
        inputBinding:
          prefix: --water-body
        label: Input rasters
        doc: Raster files used for normalized difference computation or catalog generation.
    outputs:
      stac_catalog:
        outputBinding:
          glob: .
        type: Directory
        label: Results STAC catalog
        doc: Directory containing the results STAC catalog and its referenced raster assets.
