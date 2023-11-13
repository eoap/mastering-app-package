### Goal 

Run the `otsu` step in the container image tagged `localhost/otsu:latest`.

### Run the container

The command to run the `otsu` step in the container is:

```bash linenums="1" hl_lines="5-7 13 17"
--8<--
scripts/podman-otsu.sh
--8<--
```

### Step

Run the command to run the `otsu` step with:

```
sh -x ${WORKSPACE}/scripts/podman-otsu.sh
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