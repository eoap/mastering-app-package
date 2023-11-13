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

```yaml linenums="1" hl_lines="18-21 33-43"
--8<--
cwl-workflow/app-water-bodies-cloud-native.cwl:8:58
--8<--
```

The `stac` CommandLineTool is updated to manage arrays:

```yaml linenums="200" hl_lines="19-23 25-29"
--8<--
cwl-workflow/app-water-bodies-cloud-native.cwl:200:234
--8<--
```

To run this CWL document, one would do:

```bash
--8<--
scripts/cwl-workflow-cloud-native-scatter.sh
--8<--
```