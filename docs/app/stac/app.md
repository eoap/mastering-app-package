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

The `stac` script is a command-line tool for creating a SpatioTemporal Asset Catalog (STAC) catalog containing detected water bodies.

It takes the STAC Item URLs and corresponding water body GeoTIFFs as input, creates STAC Items for each water body, and organizes them into a STAC Catalog. 

The script utilizes the `click`, `pystac`, `rio_stac`, and `loguru` libraries. 

Here's an overview of what the script does:

* It defines a command-line interface using the `click` library. The script expects multiple input STAC Item URLs and corresponding water body GeoTIFFs as arguments.

* The `to_stac` function is the main entry point. It creates a new STAC catalog and iterates through the provided STAC Item URLs and water body GeoTIFFs.

* For each input pair (STAC Item URL and GeoTIFF), it reads the STAC Item, creates a directory with the same name as the item's ID, and copies the water body GeoTIFF into that directory.

* It uses the `rio_stac` library to create a STAC Item for the water body. This includes specifying the source GeoTIFF, input date/time, asset roles, asset href, and more.

* The created STAC Items are added to the STAC catalog.

* After processing all input pairs, it saves the STAC catalog to the root directory, specifying it as a self-contained catalog with the catalog type set to `pystac.CatalogType.SELF_CONTAINED`.

The script will create a STAC catalog containing the detected water bodies and save it in the current directory. 

The script is executable as a command-line tool as its usage is:

```
Usage: app.py [OPTIONS]

  Creates a STAC catalog with the water bodies

Options:
  --input-item TEXT  STAC Item URL  [required]
  --water-body TEXT  Water body geotiff  [required]
  --help             Show this message and exit.
```

The Python code is provided here:

```python linenums="1" title="water-bodies/command-line-tools/stac/app.py"
--8<--
water-bodies/command-line-tools/stac/app.py
--8<--
```