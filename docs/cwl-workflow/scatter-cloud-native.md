CWL can run sub-workflows in a step. 

To process a list of STAC Items and then generate a STAC catalog with several detected water bodies, the flowchart is:

``` mermaid
graph TB
A["[STAC Item URL, STAC Item URL]"]
A --> F
A --> B(("crop(green)"));
A--> C(("crop(nir)"));
subgraph scatter on STAC Items
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
end
E --> F
F(("`Create 
STAC Catalog`"))
```

Below a CWL Workflow implementing this scenario:

```yaml linenums="1"
--8<--
cwl-workflow/app-water-bodies-cloud-native.cwl
--8<--
```

The `stac` CommandLineTool is updated to manage arrays:

```yaml
item:
  type:
    type: array
    items: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    inputBinding:
      prefix: --input-item
      valueFrom: $(self.value)
rasters:
  type:
    type: array
    items: File
    inputBinding:
      prefix: --water-body
```

To run this CWL document, one would do:

```bash
--8<--
scripts/cwl-workflow-cloud-native-scatter.sh
--8<--
```

### Typed inputs

Use a YAML job document for the local CWL definitions. AOIs require a Polygon record with `type`, `coordinates`, and `bbox`; the crop command uses the supplied bounding box. STAC references use URI records with a `value` field. Workflow EPSG values are `"4326"`, and supported bands are `green`, `nir`, and `nir08`. Staged input acquisitions retain their `Directory` type.

```yaml
--8<--
cwl-workflow/typed-scatter-inputs.yaml
--8<--
```
