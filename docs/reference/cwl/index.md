# Generated CWL reference

These pages are generated with
[Transpiler-Mate cwl2markdown](https://github.com/transpiler-mate/cwl2markdown).
Output directories follow the source path so workflows with the same ID do not
overwrite one another.

| CWL source | Workflow reference |
| --- | --- |
| `cwl-workflow/app-water-body.cwl` | [Staged acquisition](cwl-workflow/app-water-body/water-bodies.md) |
| `cwl-workflow/app-water-body-cloud-native.cwl` | [Single cloud-native acquisition](cwl-workflow/app-water-body-cloud-native/water-bodies.md) |
| `cwl-workflow/app-water-bodies-cloud-native.cwl` | [Multiple cloud-native acquisitions](cwl-workflow/app-water-bodies-cloud-native/water-bodies.md), [nested detection workflow](cwl-workflow/app-water-bodies-cloud-native/detect_water_body.md) |

## Regenerate

Run from the repository root using Python 3.12 or later:

```sh
python -m venv /tmp/mastering-cwl-docs
/tmp/mastering-cwl-docs/bin/python -m pip install -r scripts/requirements-cwl-docs.txt
/tmp/mastering-cwl-docs/bin/python scripts/generate-cwl-docs.py
```

The script invokes the plugin on all 12 tracked `.cwl` files. The runtime parses
each document and validates its Schema.org metadata. The nine standalone
`CommandLineTool` documents have no workflows, which the plugin reports as an
unsupported input; the script reports these as skips. Command-line tools within
the workflow graphs appear in the generated workflow pages.

The script supplies a compatibility fallback for cwl2markdown 0.2.1, which asks
for `index.md` but packages `index.md.jinja`, and renames rendered `.md.jinja`
output to `.md`.

## Metadata and output limitations

The creation date and illustrative Jane/John Doe author records come from the
training repository's `codemeta.json`. They are example metadata, not verified
authorship. The license follows `LICENSE.md` and the README (CC-BY-SA-4.0);
CodeMeta currently declares a different license. Existing workflow versions are
preserved; standalone tools use CodeMeta's application version.

The generated pages retain upstream template output, including generation
timestamps, links for optional fields rendered as `None`, and references to UML
and OGC API schema images. The corresponding images are generated separately
with cwl2puml and rendered locally with PlantUML.

## EOAP validation

Validate both `water-bodies` and `detect_water_body` in the multi-workflow
document explicitly using their fragments. Package, metadata, and staging
profiles use these reviewed applicability configurations:

| Entrypoint | Staging configuration |
| --- | --- |
| `app-water-body.cwl` | `validation/staging-staged.json` |
| `app-water-body-cloud-native.cwl` | `validation/staging-cloud-native.json` |
| `app-water-bodies-cloud-native.cwl#water-bodies` | `validation/staging-cloud-native.json` |
| `app-water-bodies-cloud-native.cwl#detect_water_body` | `validation/staging-detection.json` |

The staged workflow accepts acquisition directories at its entrypoint and in
the crop and catalog tools. Cloud-native inputs are remote STAC references;
their internal raster files are intermediate products, not staged acquisition
directories. The three top-level packages expose a Directory-based STAC catalog
produced by the catalog tool. The nested detection workflow returns an
intermediate raster file and declares no package staging boundary.

The validator always flags `EOAP.REQ14.COVERAGE` for declared staged outputs:
execution evidence is needed to prove that all produced EO files are collected.
These review findings remain even when Directory type checks pass.

Standalone command-line tools have no package Workflow entrypoint. Use
`cwltool --validate <tool.cwl>` for their CWL validity; their metadata is also
checked by the EOAP validator, but package and staging checks are blocked by
its workflow-selection requirement.

Container declarations now use mandatory `DockerRequirement` entries rather
than advisory hints, so runners must honor the specified images.

## Typed EOAP inputs

The CWL documents selectively adopt the semantic typing from
`feature/enhancements`: imported GeoJSON `Polygon` and string-format `URI`
records, an EPSG enum (`4326`), and spectral-band enums (`green`, `nir`, `nir08`).
Staged acquisition inputs retain their `Directory` type.

Use `cwl-workflow/typed-cloud-native-inputs.yaml` as an input-shape example:

```sh
cwltool --podman cwl-workflow/app-water-body-cloud-native.cwl \
  cwl-workflow/typed-cloud-native-inputs.yaml
```

The example retains the tutorial's STAC reference; its availability is not
verified by static validation. For the multi-acquisition workflow, supply
`stac_items` as a list of records with a `value` field instead of `item`.

The imported Polygon schema requires both `coordinates` and `bbox`. The crop
binding serializes the full Polygon as JSON; pixels outside the polygon are masked. URI records are unwrapped through `self.value`.
These changes require updating jobs that previously supplied plain AOI and STAC
strings. The imports reference the schemas repository's `main` branch.

Workflow enum definitions are shared through `cwl-workflow/eoap-types.yaml` and imported with `SchemaDefRequirement`. Named enum references allow cwltool to bind array inputs and preserve identical types across workflow/tool boundaries.
