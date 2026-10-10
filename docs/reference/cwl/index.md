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
and OGC API schema images. cwl2markdown does not generate those images; they
require separate transpilers and renderers.
