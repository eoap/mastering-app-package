# Script Calrissian execution

Complete the [Kubernetes lab](../kubernetes/calrissian.md) first to prepare the
published packed workflow, registry images, matching typed parameters, and shared volume. Run this
example in the deployed editor's Python environment:

```python
import json
import subprocess
import tempfile
from pathlib import Path

run = Path(tempfile.mkdtemp(prefix="scripted-", dir="/calrissian"))
(run / "logs").mkdir()
subprocess.run(
    [
        "calrissian", "--max-cores", "2", "--max-ram", "3G",
        "--tmp-outdir-prefix", str(run / "tmp"),
        "--outdir", str(run / "out"),
        "--stdout", str(run / "results.json"),
        "--stderr", str(run / "app.log"),
        "--usage-report", str(run / "usage.json"),
        "--tool-logs-basepath", str(run / "logs"),
        "--pod-nodeselectors", "/etc/calrissian/pod-node-selector.yaml",
        "/calrissian/app-water-bodies-cloud-native.cwl#main",
        "/calrissian/params.yaml",
    ],
    check=True,
)
outputs = json.loads((run / "results.json").read_text())
usage = json.loads((run / "usage.json").read_text())
print(outputs["stac_catalog"]["location"])
```

Each invocation retains its outputs, logs, and usage report in a separate shared
volume directory. Failure raises an exception. The
[benchmarking notebook](../benchmarking/calrissian-benchmark.md) uses this same
public CLI approach and adds charts and tables.

The historical `scripts/calrissian-scripted-execution.py` targets older releases
and internal runner APIs; use the CLI example above for the current lab.
