### Step purpose 

Purpose: to crop a particular band defined as a common band name (such as the "green" or "nir" band) from a satellite image acquired by either Sentinel-2 or Landsat-9. 

This step is highlighted below:

``` mermaid
graph TB
style B stroke:#f66,stroke-width:3px
style C stroke:#f66,stroke-width:3px
subgraph Process STAC item
  A[STAC Item] == STAC Item URL ==> B
  A[STAC Item] == STAC Item URL ==> C
  A[STAC Item] -.-> F
subgraph scatter on bands
  B["crop(green)"];
  C["crop(nir)"];
end
  B["crop(green)"] == crop_green.tif ==> D[Normalized difference];
  C["crop(nir)"] == crop_green.tif ==> D[Normalized difference];
  D -.-> E[Otsu threshold]
end
  E -.-> F[Create STAC Catalog]
  F -.-> G[(storage)]
```

### Code

The `crop.py` script is a command-line tool that takes as input

* a SpatioTemporal Asset Catalog (STAC) Item
* a bounding box area of interest (AOI), an EPSG code
* a common band name as input

and then crops the specified band from the asset associated with the common band name to the specified AOI. 

It uses various Python libraries like `pystac`, `rasterio`, `pyproj`, `shapely`, and `loguru`.

Here is an overview of the script's functionality:

* It defines a function `aoi2box` to convert an AOI expressed as a bounding box string into a list of floats.

* It defines a function `get_asset` to retrieve the asset of a STAC Item that is defined with a common band name. It iterates through the assets and checks if a band has the specified common name.

* It defines a command-line interface using `click`, with options for providing the input STAC Item URL, AOI, EPSG code, and common band name.

* The `crop` function is the main entry point. It reads the STAC Item specified by the input URL and retrieves the asset associated with the common band name. It then crops the asset to the specified AOI using the rasterio library.

* It transforms the bounding box coordinates to match the EPSG code provided.

* It performs the cropping using the `rasterio.mask.mask` function.

* It writes the cropped image to a GeoTIFF file with a filename like "crop_bandname.tif."

The script is executable as a command-line tool as its usage is:

```
Usage: app.py [OPTIONS]

  Crops a STAC Item asset defined with its common band name

Options:
  --input-item TEXT  STAC Item URL or staged STAC catalog  [required]
  --aoi TEXT         Area of interest expressed as a bounding box  [required]
  --epsg TEXT        EPSG code  [required]
  --band TEXT        Common band name  [required]
  --help             Show this message and exit.
```

To use this script, you would typically run it from the command line, providing the necessary input options such as the STAC Item URL, AOI, EPSG code, and common band name: 

```
python app.py \
  --input-item "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
  --aoi "-121.399,39.834,-120.74,40.472" \
  --epsg "EPSG:4326" \
  --band "green" 
```

It will then crop the specified band from the STAC asset and save it as a GeoTIFF file.

The Python code is provided here:

```python linenums="1" title="water-bodies/command-line-tools/crop/app.py"
--8<--
water-bodies/command-line-tools/crop/app.py
--8<--
```