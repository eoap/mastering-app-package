### Step purpose 

Purpose: to calculate the normalized difference of the "green" or "nir" bands.

This step is highlighted below:

``` mermaid
graph TB
style D stroke:#f66,stroke-width:3px
subgraph Process STAC item
  A[STAC Item] -.-> B
  A[STAC Item] -.-> C
  A[STAC Item] -.-> F
subgraph scatter on bands
  B["crop(green)"];
  C["crop(nir)"];
end
  B["crop(green)"] == crop_green.tif ==> D[Normalized difference];
  C["crop(nir)"] == crop_green.tif ==> D[Normalized difference];
  D == norm_diff.tif ==> E[Otsu threshold]
end
  E -.-> F[Create STAC Catalog]
  F -.-> G[(storage)]
```

### Code

Computes (first - second) / (first + second) from exactly two rasters supplied with repeated --rasters options. Dimensions, transforms, and coordinate systems must match. The output norm_diff.tif is a float32, LZW-compressed COG; zero denominators produce nonfinite values handled by the threshold step.

The installed console interface is:

```text
Usage: norm_diff [OPTIONS]

  Calculate the normalized difference water index (NDWI) from the green and
  near-infrared spectral band rasters.

Options:
  --rasters FILE  Ordered green and near-infrared GeoTIFFs used to calculate
                  NDWI.  [default: (rasters); required]
  --help          Show this message and exit.
```

The processing implementation is:

```python linenums="1" title="norm_diff_impl.py"
--8<--
water-bodies/command-line-tools/norm_diff/src/norm_diff/norm_diff_impl.py
--8<--
```
