

### Stage-in

From the OGC Best Practice for Earth Observation Application Package:

**An Application input argument that requires staged EO product files SHALL be defined as an argument that points to a folder where a STAC Catalog, named catalog.json, contains a list of one or more STAC Items and associated STAC Assets referencing the files.**

This translates to:

* Plug a **stage-in step** for all workflow steps having inputs of type `Directory`
* Workflow steps having inputs of type `Directory` will find a STAC catalog.json file

### Stage-out

From the OGC Best Practice for Earth Observation Application Package:

**An Application that creates EO product files to be stage-out SHALL generate a valid STAC Catalog, named catalog.json, and include the STAC Item(s) and corresponding STAC Assets pointing to the results of the processing.**

**The STAC Catalog created by the Application SHALL include metadata elements for each STAC Item with at least their spatial (geometry, box) and temporal (datetime) properties.**

This translates to:

* Workflow steps that have an output of type `Directory` produce a STAC catalog
* Plug a **stage-out step** for all workflow outputs of type Directory

### Applying the stage-in/out to the water bodies

The concepts above mapped to the Water Body Detection application are depicted below.

``` mermaid
graph TB
style AA stroke:#f66,stroke-width:3px
style BB stroke:#f66,stroke-width:3px
subgraph stage-in
A[STAC Item] -- STAC Item URL --> AA[Stage-in]
AA[Stage-in] -- catalog.json/item.json/assets blue, red,  nir ... --> AB[(local storage)]
end
subgraph Process STAC item
AB[(storage)] -- Staged STAC Catalog --> B
AB[(storage)] -- Staged STAC Catalog --> C
AB[(storage)] -- Staged STAC Catalog --> F
subgraph scatter on bands
B["crop(green)"];
C["crop(nir)"];
end
B["crop(green)"] -.-> D[Normalized difference];
C["crop(nir)"] -.-> D[Normalized difference];
D -.-> E[Otsu threshold]
end
E -.-> F[Create STAC Catalog]
F -.-> G[(storage)]

subgraph stage-out

G -- "catalog.json/item.json/asset otsu.tif" --> BB[Stage-out] 
BB --> H[("Remote 
 storage")]
end
```