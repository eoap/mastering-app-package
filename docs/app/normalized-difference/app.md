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

The `norm_diff` script is a command-line tool for performing a normalized difference between two raster images. 

It uses the `click`, `rasterio`, and `numpy` libraries to perform the calculation and save the result as a GeoTIFF file. 

Here's an overview of what the script does:

* It defines a command-line interface using the `click` library, with two arguments for providing the file paths of the two raster images that you want to calculate the normalized difference for.

* The `normalized_difference` function is the main entry point. It opens the two input raster files specified as arguments.

* It reads the data from the first raster (specified by `rasters[0]`) using `rasterio`, and it also copies the metadata (e.g., `projection`, `geotransform`) of this raster to be used for the output.

* It then opens the second raster (specified by `rasters[1]`) and reads its data.

* It updates the data type in the metadata to `"float32"` because the normalized difference result will be a floating-point image.

* It creates an output raster named "norm_diff.tif" using `rasterio`. This output raster will have the same metadata as the first input raster, but it will be of data type `float32`.

* It calculates the normalized difference between the two input arrays `(array1 - array2) / (array1 + array2)` and writes it to the output raster using `dst_dataset.write()`.

The script is executable as a command-line tool as its usage is:

```
Usage: app.py [OPTIONS] RASTERS...

  Performs a normalized difference

Options:
  --help  Show this message and exit.
```

The Python code is provided here:

```python linenums="1" title="water-bodies/command-line-tools/norm_diff/app.py"
--8<--
water-bodies/command-line-tools/norm_diff/app.py
--8<--
```