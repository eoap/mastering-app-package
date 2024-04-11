### Goal

Run the `otsu` step in a Python virtual environment.

### Lab

This step has a dedicated lab available at /workspace/mastering-app-package/practice-labs/Application steps/otsu.ipynb

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
scripts/otsu_env.sh
--8<--
```

```
source ${WORKSPACE}/scripts/otsu_env.sh
```

### Step 3 - Calculate the ostu threshold

The command line tool is invoked to calculate  Otsu threshold against the normalized difference:

```bash linenums="1" hl_lines="7-9"  title="terminal"
--8<--
scripts/otsu.sh
--8<--
```

```
source ${WORKSPACE}/scripts/otsu.sh
```

### Step 4 - Clean-up

The Python virtual environment is no longer needed.

```bash linenums="1" title="terminal"
--8<--
scripts/otsu_deactivate.sh
--8<--
```

```
source ${WORKSPACE}/scripts/otsu_deactivate.sh
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