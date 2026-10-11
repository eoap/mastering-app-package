### Step purpose 

Purpose: produce a STAC Catalog with a STAC Item describing the detected water body result. 

This step is highlighted below:

``` mermaid
graph TB
style F stroke:#f66,stroke-width:3px
subgraph Process STAC item
  A[STAC Item] -.-> B
  A[STAC Item] -.-> C
  A[STAC Item] == STAC Item URL ==> F
subgraph scatter on bands
  B["crop(green)"];
  C["crop(nir)"];
end
  B["crop(green)"] -.-> D[Normalized difference];
  C["crop(nir)"] -.-> D[Normalized difference];
  D -.-> E[Otsu threshold]
end
  E == otsu.tif ==> F[Create STAC Catalog]
  F == "catalog.json/item.json/asset otsu.tif" ==> G[(storage)]
```

### Code

Pairs source STAC items with masks using repeated --item and --rasters options in corresponding order. It accepts item URLs, local files, and staged catalog directories. Item counts must match raster counts, and IDs must be unique directory names. Each raster is copied into its item directory, with projection and raster metadata derived by rio-stac. The output catalog.json and item directories form a self-contained STAC catalog with relative asset links.

The installed console interface is:

```text
Usage: stac [OPTIONS]

  Generate a STAC catalog for the water bodies using the source STAC items and
  the binary water body masks.

Options:
  --item TEXT     Source STAC item URLs in the same order as the water body
                  masks.  [default: (item); required]
  --rasters FILE  Binary water body masks in the same order as the source STAC
                  items.  [default: (rasters); required]
  --help          Show this message and exit.
```

The processing implementation is:

```python linenums="1" title="stac_impl.py"
--8<--
water-bodies/command-line-tools/stac/src/stac/stac_impl.py
--8<--
```
