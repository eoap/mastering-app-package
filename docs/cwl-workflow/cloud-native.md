
The Cloud native Workflow chains the `crop`, `norm_diff`, `otsu` and `stac` steps taking a single STAC item as input parameters:

* a SpatioTemporal Asset Catalog (STAC) Item
* a bounding box area of interest (AOI)
* the EPSG code of the bounding box area of interest
* a list of common band names (["green", "nir"])

``` mermaid
graph TB
A[STAC Item URL]
A --> B(("crop(green)"));
A--> C(("crop(nir)"));
A[STAC Item URL] --> F
P[bands]
Q[EPSG code]
R[AOI]
subgraph scatter on bands
  P --> B(("crop(green)"))
  P --> C(("crop(nir)"))
  Q --> B(("crop(green)"))
  Q --> C(("crop(nir)"))
  R --> B(("crop(green)"))
  R --> C(("crop(nir)"))
end
B(("crop(green)")) --> D
C(("crop(nir)")) --> D
D(("`Normalized 
difference`"));
D --> E(("`Otsu
 threshold`"))
E --> F(("`Create 
STAC Catalog`"))
```

The CWL Workflow is shown below and the lines highlighted chain the steps:

```yaml linenums="1" hl_lines="8-71" title="app-water-body-cloud-native.cwl"
--8<--
cwl-workflow/app-water-body-cloud-native.cwl
--8<--
```
