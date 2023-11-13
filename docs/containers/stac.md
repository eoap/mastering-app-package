### Goal 

Run the `stac` step in the container image tagged `localhost/stac:latest`.

### Run the container

The command to run the `stac` step in the container is:

```bash linenums="1" hl_lines="5-7 13 17-20"
--8<--
scripts/podman-stac.sh
--8<--
```

### Step

Run the command to run the `stac` step with:

```
sh -x ${WORKSPACE}/scripts/podman-stac.sh
```

### Expected outcome

The folder `/workspace/runs` contains: 

```
(base) jovyan@coder-mrossi:~/runs$ tree .
.
├── S2B_10TFK_20210713_0_L2A
│   ├── S2B_10TFK_20210713_0_L2A.json
│   └── otsu.tif
├── catalog.json
├── crop_green.tif
├── crop_nir.tif
├── norm_diff.tif
└── otsu.tif

1 directory, 7 files
```