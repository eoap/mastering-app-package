### Goal 

Run the `norm_diff` step in the container image tagged `localhost/norm-diff:latest`.

### Run the container

The command to run the `norm_diff` step in the container is:

```bash linenums="1" hl_lines="5-8 14 18-19"
--8<--
scripts/podman-norm-diff.sh
--8<--
```

### Step

Run the command to run the `norm_diff` step with:

```
sh -x ${WORKSPACE}/scripts/podman-norm-diff.sh
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