### Goal 

Wrap the `norm_diff` step as a Common Workflow Language CommandLineTool and execute it with a CWL runner.

### CWL CommandLineTool wrapping the step

The CWL document below shows the `norm_diff` step wrapped as a CWL CommandLineTool:

```yaml linenums="1" hl_lines="9-12 49-53" title="cwl-cli/norm-diff.cwl"
--8<--
cwl-cli/norm-diff.cwl
--8<--
```

### Steps

Run the CWL document using the `cwltool` CWL runner to execute the `norm_diff` step with:

```bash linenums="1" hl_lines="9-12 49-53"
--8<--
scripts/cwl-cli-norm-diff.sh
--8<--
```

```
sh -x ${WORKSPACE}/scripts/cwl-cli-norm-diff.sh
```

### Expected outcome

The folder `/workspace/runs` contains: 

```
(base) jovyan@coder-mrossi:~/runs$ tree .
.
├── crop_green.tif
├── crop_nir.tif
└── norm_diff.tif

0 directories, 3 files
```