### Goal

Use a stage-in CWL workflow to stage a Landsat-9 acquisition

### Lab

This step has a dedicated lab at `practice-labs/4-CWL-Workflows/2.1-stage-in.ipynb`.

### Step 1 - Create a stage-in CWL Workflow

Below a `stage-in.cwl` CWL (Common Workflow Language) document for a command-line tool that executes a Python script. 

The document invokes the installed `stage-in --reference <item>` command in
`localhost/stage-in:latest`. The reference remains a string, so existing job
documents continue to work.

```yaml linenums="1" title="stage-in.cwl"
--8<--
cwl-cli/stage-in.cwl
--8<--
```

The Python package reads a STAC Item, downloads its assets with `stac-asset`,
and writes a self-contained `catalog.json` with relative asset links. It keeps
the working directory unchanged and validates that the item ID is a directory
name. HTTP downloads have a 60-second request timeout and up to three attempts.
Failed asset downloads fail the command before publishing a catalog. Progress
and errors are logged to stderr.

```python linenums="1" title="stage_in_impl.py"
--8<--
water-bodies/command-line-tools/stage-in/src/stage/stage_in_impl.py
--8<--
```

### Step 2 - Create a container for the stage-in

The container image is built with: 

```bash linenums="1" hl_lines="8-71"
--8<--
scripts/build-stage-container.sh
--8<--
```

### Step 3 - Stage the Landsat-9 acquisition

Now the Landsat-9 acquisition "https://planetarycomputer.microsoft.com/api/stac/v1/collections/landsat-c2-l2/items/LC09_L2SP_042033_20231015_02_T1" is staged with: 

```bash linenums="1" hl_lines="8"
--8<--
scripts/cwl-cli-stage-in.sh
--8<--
```

### Step 4 - Check the path to the stage Landsat-9 acquisition

The result is redirected to a file named `staged.json` as we use `jq` to get the path of the staged product:

```bash title="terminal"
cat staged.json | jq -r .staged.path
```

This returns a path like `/workspace/mastering-app-package/runs/921x91vw`