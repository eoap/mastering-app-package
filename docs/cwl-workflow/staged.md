The non-Cloud native Workflow chains the `crop`, `norm_diff`, `otsu` and `stac` steps taking a staged EO acquisition as a STAC Catalog in a directory as input parameters:

* a local STAC Catalog in a directory
* a bounding box area of interest (AOI)
* the EPSG code of the bounding box area of interest
* a list of common band names (["green", "nir08"])

``` mermaid
graph TB
S[(local storage)]
S -- STAC Catalog --> B(("crop(green)"));
S --  STAC Catalog --> C(("crop(nir)"));
S -- STAC Catalog --> F
P[bands]
Q[EPSG code]
R[AOI]
subgraph scatter on bands
  P --> B(("crop(green)"))
  P --> C(("crop(nir08)"))
  Q --> B(("crop(green)"))
  Q --> C(("crop(nir08)"))
  R --> B(("crop(green)"))
  R --> C(("crop(nir08)"))
end
B(("crop(green)")) --> D
C(("crop(nir08)")) --> D
D(("`Normalized 
difference`"));
D --> E(("`Otsu
 threshold`"))
E --> F(("`Create 
STAC Catalog`"))
```

The CWL Workflow is shown below and the lines highlighted show the changes to manage a staged STAC Catalog instead of an URL to a STAC Item:

```yaml linenums="1" hl_lines="32 90 180" title="app-water-body.cwl"
--8<--
cwl-workflow/app-water-body.cwl
--8<--
```

