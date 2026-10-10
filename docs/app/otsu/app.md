### Step purpose 

Purpose: to apply the Otsu threshold to the normalized difference. 

This step is highlighted below:

``` mermaid
graph TB
style E stroke:#f66,stroke-width:3px
subgraph Process STAC item
  A[STAC Item] -.-> B
  A[STAC Item] -.-> C
  A[STAC Item] -.-> F
subgraph scatter on bands
  B["crop(green)"];
  C["crop(nir)"];
end
  B["crop(green)"] -.-> D[Normalized difference];
  C["crop(nir)"] -.-> D[Normalized difference];
  D == norm_diff.tif ==> E[Otsu threshold]
end
  E == otsu.tif ==> F[Create STAC Catalog]
  F -.-> G[(storage)]
```

### Code

Reads the raster supplied with --raster and computes the Otsu threshold from finite pixel values. Pixels above the threshold become 1; other pixels, including nonfinite values, become 0. An input with no finite values fails. The output otsu.tif retains the spatial metadata and uses uint8, LZW-compressed COG format without a nodata value.

The installed console interface is:

```text
Usage: otsu [OPTIONS]

  Apply Otsu thresholding to the NDWI raster to generate a binary water body
  mask.

Options:
  --raster FILE  Normalized difference water index raster to threshold.
                 [default: (raster); required]
  --help         Show this message and exit.
```

The processing implementation is:

```python linenums="1" title="otsu_impl.py"
--8<--
water-bodies/command-line-tools/otsu/src/otsu/otsu_impl.py
--8<--
```
