# Script local workflow execution

Build the processing images first and run this Python example from the checkout
root. It invokes the public cwltool CLI, uses the checked-out typed scatter job,
and reads the workflow's JSON output. Adjust the job's acquisition references
and AOI before running it.

```python
import json
import subprocess
from pathlib import Path

workspace = Path.cwd()
output = workspace / "runs" / "scripted"
output.mkdir(parents=True, exist_ok=True)
result = subprocess.run(
    [
        "cwltool", "--podman", "--parallel", "--outdir", str(output),
        str(workspace / "cwl-workflow/app-water-bodies-cloud-native.cwl") + "#water-bodies",
        str(workspace / "cwl-workflow/typed-scatter-inputs.yaml"),
    ],
    check=True, capture_output=True, text=True,
)
outputs = json.loads(result.stdout)
print(outputs["stac_catalog"]["location"])
```

`check=True` raises an exception on runner failure. Logs are captured in
`result.stderr` on success, or the exception's `stderr` on failure. The output
Directory contains the catalog and referenced masks.

This example uses the CLI from Python so it can share the same inputs as the
[scatter lab](../cwl-workflow/scatter-cloud-native.md). The historical script
`scripts/cwltool-scripted-execution.py` targets release 1.4.1 and its older
input format; it is separate from this checkout-based example.
