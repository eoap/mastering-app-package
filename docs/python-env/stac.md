### Goal

Run the `stac` step in a Python virtual environment.

### Lab

This step has a dedicated lab available at /workspace/mastering-app-package/practice-labs/Application steps/stac.ipynb

### Step 1 - Configure the workspace

The results produced will be available in the local folder `/workspace/runs`

```bash linenums="1" hl_lines="2-4" title="terminal"
--8<--
scripts/setup.sh
--8<--
```

```
source /workspace/mastering-app-package/scripts/setup.sh
```

### Step 2 - Create the Python virtual environment

The required Python modules are installed using `pip`:

```bash linenums="1" hl_lines="3" title="terminal"
--8<--
scripts/stac_env.sh
--8<--
```

```
source ${WORKSPACE}/scripts/stac_env.sh
```

### Step 3 - Generate the STAC Catalog

The command line tool is invoked to produce a STAC Catalog:

```bash linenums="1" hl_lines="7-9"  title="terminal"
--8<--
scripts/stac.sh
--8<--
```

```
source ${WORKSPACE}/scripts/stac.sh
```

### Step 4 - Clean-up

The Python virtual environment is no longer needed.

```bash linenums="1" title="terminal"
--8<--
scripts/stac_deactivate.sh
--8<--
```

```
source ${WORKSPACE}/scripts/stac_deactivate.sh
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