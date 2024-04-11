### Goal

Use a stage-in CWL workflow to stage a Landsat-9 acquisition

### Lab

This step has a dedicated lab available at /workspace/mastering-app-package/practice-labs/Workflows/stage-in.ipynb

### Step 1 - Create a stage-in CWL Workflow

Below a `stage-in.cwl` CWL (Common Workflow Language) document for a command-line tool that executes a Python script. 

The document is designed to use a container and execute a Python script named "stage.py":

```yaml linenums="1" hl_lines="26-59" title="stage-in.cwl"
--8<--
cwl-cli/stage-in.cwl
--8<--
```

The `stage.py` Python script uses the `pystac` and `stac_asset` libraries to stage STAC Items, download them, and create a STAC Catalog. 
It's designed to be run from the command line, taking the URL of a STAC Item as a command-line argument. 

Here's a breakdown of what the script does:

* The script imports the necessary libraries: `pystac`, `stac_asset`, `asyncio`, `os`, and `sys`.

* It sets up the configuration for the stac_asset library with `warn=True`.

* The script defines an `async` function named `main`, which takes a STAC Item URL (href) as an argument.

* Inside the `main` function:

    * It reads the STAC Item using `pystac.read_file(href)` and stores it in the item variable.
    * It creates a directory with the same name as the STAC Item's ID if it doesn't exist using `os.makedirs(item.id, exist_ok=True)`.
    * It temporarily changes the current working directory to the newly created directory using `os.chdir(item.id)`.
    * It downloads the STAC Item's assets to the current directory using `stac_asset.download_item(item=item, directory=".", config=config)`.
    * It returns the STAC Item.

After defining the `main` function, the script sets the href variable to the first command-line argument provided (`sys.argv[1]`).

* It uses `asyncio.run` to execute the main function asynchronously with the specified href.

* In the `main` function, a new STAC Catalog is created:

    * It's given the ID "catalog" and a description and title that mention the staged STAC Item.
    * The staged STAC Item is added to the catalog.
    * The catalog's hrefs are normalized relative to the current working directory.
    * The catalog is saved as a self-contained catalog.

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