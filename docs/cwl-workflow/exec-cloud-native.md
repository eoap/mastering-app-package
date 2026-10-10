### Goal

Run the `app-water-body-cloud-native.1.0.0.cwl` released application package using `cwltool`.

### Relationship to the current lab

This page demonstrates a historical released package using the download and
execution scripts below. Its input format and container versions belong to
that release.

The current notebook, `practice-labs/4-CWL-Workflows/1-cloud-native.ipynb`,
runs the checked-out typed CWL and locally built images instead. Follow the
[current workflow guide](cloud-native.md) for its job format and commands.

### Step 1 - Configure the workspace

The results produced will be available in the local folder `/workspace/mastering-app-package/runs`

```bash linenums="1" hl_lines="2-4" title="terminal"
--8<--
scripts/setup.sh
--8<--
```

```
source /workspace/mastering-app-package/scripts/setup.sh
```

### Step 2 - Download the released Application package

```bash linenums="1" hl_lines="5" title="scripts/download-app-water-body-cloud-native.sh"
--8<--
scripts/download-app-water-body-cloud-native.sh
--8<--
```

```
sh ${WORKSPACE}/scripts/download-app-water-body-cloud-native.sh
```

### Step 3 - Execute the Application Package

```bash linenums="1" hl_lines="6" title="scripts/exec-app-water-body-cloud-native.sh"
--8<--
scripts/exec-app-water-body-cloud-native.sh
--8<--
```

```
sh ${WORKSPACE}/scripts/exec-app-water-body-cloud-native.sh
```

### Expected outcome

The folder `/workspace/mastering-app-package/runs` contains: 

``` hl_lines="3"
(base) jovyan@coder-fbrito:~/runs$ tree .
/workspace/mastering-app-package/runs/
├── app-water-body-cloud-native.1.0.0.cwl
└── cmtriamc
    ├── S2B_10TFK_20210713_0_L2A
    │   ├── S2B_10TFK_20210713_0_L2A.json
    │   └── otsu.tif
    └── catalog.json

2 directories, 4 files
```


These commands target downloaded release packages and retain those releases' input format. For local typed CWL files, use the YAML job examples in the workflow authoring labs.
