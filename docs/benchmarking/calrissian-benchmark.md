# Benchmark the checked-out workflow

The lab is `practice-labs/5-Kubernetes/2-benchmark.ipynb`. Complete the
[Calrissian lab](../kubernetes/calrissian.md) first: it prepares
`/calrissian/app-water-bodies-cloud-native.cwl` with local `:metadata` images.
The benchmark runs that packed package at `#main`.

Select **Python (Mastering Application Package)** in the deployed editor.
This lab uses its Python environment, including Calrissian, matplotlib, NumPy,
pandas, and PyYAML. The application-step Hatch Bash kernels are for the processing
labs; the benchmark itself is a Python notebook.

## Run the benchmark

The notebook's `Benchmark` class invokes the public Calrissian CLI through
`subprocess.run(..., check=True)`, using `--max-cores 2` and `--max-ram 3G` by
default. Each run creates a separate `/calrissian/benchmark-*` directory:

| File or directory | Contents |
| --- | --- |
| `params.yaml` | The run's typed workflow inputs |
| `results.json` | Workflow outputs |
| `app.log` | Runner log |
| `usage.json` | Calrissian resource-usage report |
| `logs/` | Individual tool logs |
| `out/` | Final results |
| `tmp*` | Temporary processing outputs |

An unsuccessful CLI run raises an exception instead of producing a successful
benchmark report. The class and imports are:


```python
import random
import json
import subprocess
import tempfile
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import matplotlib.dates as mdates
import yaml

class Benchmark:
    def __init__(self, parameters, max_cores="2", max_ram="3G"):
        self.parameters = parameters
        self.max_cores = max_cores
        self.max_ram = max_ram
        self.cwl_path = Path("/calrissian/app-water-bodies-cloud-native.cwl")

    def run(self):
        # Use the public CLI and its usage report instead of internal Python APIs.
        directory = Path(tempfile.mkdtemp(prefix="benchmark-", dir="/calrissian"))
        (directory / "logs").mkdir()
        parameters = directory / "params.yaml"
        parameters.write_text(yaml.safe_dump(self.parameters))
        subprocess.run([
            "calrissian", "--max-cores", self.max_cores, "--max-ram", self.max_ram,
            "--tmp-outdir-prefix", str(directory / "tmp"),
            "--outdir", str(directory / "out"),
            "--stdout", str(directory / "results.json"),
            "--stderr", str(directory / "app.log"),
            "--usage-report", str(directory / "usage.json"),
            "--tool-logs-basepath", str(directory / "logs"),
            "--pod-nodeselectors", "/etc/calrissian/pod-node-selector.yaml",
            f"{self.cwl_path}#main", str(parameters),
        ], check=True)
        return {
            "application_package": {"uri": str(self.cwl_path), "cwl": json.loads(self.cwl_path.read_text())},
            "results": json.loads((directory / "results.json").read_text()),
            "usage": json.loads((directory / "usage.json").read_text()),
            "parameters": self.parameters,
        }
```

Read the checkout's typed scatter example and execute the first run:


```python
parameters = yaml.safe_load(Path("/workspace/mastering-app-package/cwl-workflow/typed-scatter-inputs.yaml").read_text())
benchmark = Benchmark(parameters)
report = benchmark.run()
```

The second run reverses the STAC item order while retaining the other inputs:


```python
# Repeat with reversed scatter inputs to compare another run.
parameters = dict(parameters, stac_items=list(reversed(parameters["stac_items"])))
benchmark = Benchmark(parameters)
```


```python
report = benchmark.run()
```

The returned report contains the packed CWL, parameters, workflow results, and
parsed usage report. Both runs retain their files in separate directories.
Changing item order is another execution sample; it does not by itself establish
a performance improvement.

## Analyze the usage report

The notebook plots each processing step's start time and elapsed duration as a
Gantt chart. It assigns colors by tool ID from the packed CWL. The tables show
per-step usage and the overall report:


```python
usage_df = pd.DataFrame.from_dict(report["usage"]["children"])

usage_df
```


```python
import copy

overall_report = copy.deepcopy(report["usage"])

del overall_report["children"]


pd.DataFrame.from_dict([overall_report])
```

Run the full notebook to define and call `plot_usage(report)` for the Gantt
chart. The plotted report is the most recent run; retain the first returned
report separately when comparing runs. Actual timings depend on cluster
resources, remote data access, and cache state.
