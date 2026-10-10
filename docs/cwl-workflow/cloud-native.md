
The Cloud native Workflow chains the `crop`, `norm_diff`, `otsu` and `stac` steps taking a single STAC item as input parameters:

* a STAC item URI record with a `value` field
* a GeoJSON Polygon area of interest (AOI), with `coordinates` and `bbox`
* the EPSG enum value `"4326"`
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

```yaml linenums="1" title="app-water-body-cloud-native.cwl"
--8<--
cwl-workflow/app-water-body-cloud-native.cwl
--8<--
```


### Typed inputs

Use a YAML job document for the local CWL definitions. AOIs require a Polygon record with `type`, `coordinates`, and `bbox`; the crop command uses the supplied bounding box. STAC references use URI records with a `value` field. Workflow EPSG values are `"4326"`, and supported bands are `green`, `nir`, and `nir08`. Staged input acquisitions retain their `Directory` type.

```yaml
--8<--
cwl-workflow/typed-cloud-native-inputs.yaml
--8<--
```
