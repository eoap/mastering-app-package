### Goal

Run the `crop` step in a Python virtual environment.

### Lab

This step has a dedicated lab available at /workspace/mastering-app-package/practice-labs/Application steps/crop.ipynb

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
scripts/crop_env.sh
--8<--
```

```
source ${WORKSPACE}/scripts/crop_env.sh
```

### Step 3 - Crop the green band

The command line tool is invoked to crop the green band:

```bash linenums="1" hl_lines="7-11" title="terminal"
--8<--
scripts/crop_green.sh
--8<--
```

```
source ${WORKSPACE}/scripts/crop_green.sh
```

### Step 4 - Crop the NIR band

The command line tool is invoked to crop the NIR band:

```bash linenums="1" hl_lines="7-11" title="terminal"
--8<--
scripts/crop_nir.sh
--8<--
```

```
source ${WORKSPACE}/scripts/crop_nir.sh
```

### Step 5 - Clean-up

The Python virtual environment is no longer needed.

```bash linenums="1" title="terminal"
--8<--
scripts/crop_deactivate.sh
--8<--
```

```
source ${WORKSPACE}/scripts/crop_deactivate.sh
```

### Expected outcome

The folder `/workspace/runs` contains: 

```
(base) jovyan@coder-mrossi:~/runs$ tree .
.
├── crop_green.tif
└── crop_nir.tif

0 directories, 2 files
```