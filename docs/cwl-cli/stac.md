### Goal 

Wrap the `stac` step as a Common Workflow Language CommandLineTool and execute it with a CWL runner.

### Lab

This step has a dedicated lab available at /workspace/mastering-app-package/practice-labs/CommandLineTools/stac.ipynb

### CWL CommandLineTool wrapping the step

The CWL document below shows the `stac` step wrapped as a CWL CommandLineTool:

```yaml linenums="1" hl_lines="9-12 49-53"
--8<--
cwl-cli/stac.cwl
--8<--
```

### Steps

Run the CWL document using the `cwltool` CWL runner to execute the `stac` step with:


```bash linenums="1" hl_lines="9-12 49-53"
--8<--
scripts/cwl-cli-stac.sh
--8<--
```

```
sh -x ${WORKSPACE}/scripts/cwl-cli-stac.sh
```

### Expected outcome

The folder `/workspace/mastering-app-package/runs` contains: 

``` hl_lines="6"
(base) jovyan@coder-fbrito:~/runs$ tree .
.
├── crop_green.tif
├── crop_nir.tif
├── norm_diff.tif
├── otsu.tif
└── p371fwrs
    ├── S2B_10TFK_20210713_0_L2A
    │   ├── S2B_10TFK_20210713_0_L2A.json
    │   └── otsu.tif
    └── catalog.json

2 directories, 7 files
```

Line #6 shows the folder created by the execution.