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

Crops a selected STAC asset to a GeoJSON Polygon or bounding box. The asset must have a data role and matching eo:bands or bands common_name. Relative asset paths are resolved against the item; staged catalogs select their first item. Planetary Computer URLs are signed when needed. The geometry is transformed into the raster CRS and rasterio masks pixels outside it. Remote reads use bounded retries and timeouts. The output crop_<band>.tif retains the source datatype and nodata value and uses LZW-compressed COG format.

The installed console interface is:

```text
Usage: crop [OPTIONS]

  Crop each requested spectral band to the area of interest.

Options:
  --input-item TEXT         URL of the source STAC item.  [default: (item);
                            required]
  --aoi TEXT                GeoJSON polygon defining the area of interest.
                            [default: (aoi); required]
  --epsg [4326]             Coordinate reference system of the area of
                            interest.  [default: (epsg); required]
  --band [green|nir|nir08]  Common name of the spectral band to crop.
                            [default: (band); required]
  --help                    Show this message and exit.
```

The processing implementation is:

```python linenums="1" title="crop_impl.py"
--8<--
water-bodies/command-line-tools/crop/src/crop/crop_impl.py
--8<--
```
