### Goal

Run `crop` in the same Hatch environment used by the
[practice notebook](https://github.com/eoap/mastering-app-package/blob/feature/metadata/practice-labs/1-Application_Steps/crop.ipynb).
The notebook is stored at `practice-labs/1-Application_Steps/crop.ipynb`.

### Requirements

Install Python 3.12 or newer, Hatch, and Task. The remote STAC item and its assets must be reachable.
See [developer tooling](../development.md) for the available tasks.

### Register the notebook kernel

From the checkout root, run:

```bash
task kernel:install TOOL=crop
```

Select **Bash (crop Hatch)** in Jupyter or VS Code. This kernel uses the
package's default Hatch environment. An ordinary Bash kernel can also activate
that environment using the commands below. Run the workspace setup from inside
the checkout so Git can locate its root.

### Configure the workspace

```bash
export WORKSPACE="$(git rev-parse --show-toplevel)"
export RUNTIME=${WORKSPACE}/runs
mkdir -p "${RUNTIME}"
cd "${RUNTIME}"
```

Outputs are written to `runs/` in the current checkout.

### Activate the Hatch environment

```bash
cd "${WORKSPACE}/water-bodies/command-line-tools/crop"
hatch env create default
source "$(hatch env find default)/bin/activate"
cd "${RUNTIME}"

which python
which crop
crop --help
```

Hatch installs the Python project and its dependencies; a separate `pip install`
cell is unnecessary. Activation keeps the console command available after changing
to the output directory.

### Run the step

```bash
crop \
    --input-item "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
    --aoi='{"type":"Polygon","coordinates":[[[-121.399,39.834],[-120.74,39.834],[-120.74,40.472],[-121.399,40.472],[-121.399,39.834]]]}' \
    --epsg "4326" \
    --band green
```

```bash
crop \
    --input-item "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
    --aoi='{"type":"Polygon","coordinates":[[[-121.399,39.834],[-120.74,39.834],[-120.74,40.472],[-121.399,40.472],[-121.399,39.834]]]}' \
    --epsg "4326" \
    --band nir
```

The notebook supplies Polygon JSON. Crop masks pixels outside the polygon, retains the source pixel datatype, and writes LZW-compressed COGs. The command also accepts a comma-separated bounding box. `--epsg 4326` describes the AOI coordinate system.

### Expected outcome

The step adds these files under `runs/`:

```text
crop_green.tif
crop_nir.tif
```

Earlier steps' outputs remain available.

### Finish the session

```bash
deactivate
```

Keep the Hatch environment for subsequent runs. The pip-based scripts under
`scripts/` remain an alternative for manual shell use.
