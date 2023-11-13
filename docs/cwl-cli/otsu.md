### Goal 

Wrap the `crop` step as a Common Workflow Language CommandLineTool and exectute it with a CWL runner.

### CWL CommandLineTool wrapping the step

The CWL document below shows the `crop` step wrapped as a CWL CommandLineTool:

```yaml linenums="1" hl_lines="9-12 49-53"
--8<--
cwl-cli/otsu.cwl
--8<--
```

### Steps

Run the CWL document using the `cwltool` CWL runner to execute the `otsu` step with:


```bash linenums="1" hl_lines="9-12 49-53"
--8<--
scripts/cwl-cli-otsu.sh
--8<--
```

```
sh -x ${WORKSPACE}/scripts/cwl-cli-otsu.sh
```

### Expected outcome

The folder `/workspace/runs` contains: 

```
(base) jovyan@coder-mrossi:~/runs$ tree .
.
├── crop_green.tif
├── crop_nir.tif
├── norm_diff.tif
└── otsu.tif

0 directories, 4 files
```