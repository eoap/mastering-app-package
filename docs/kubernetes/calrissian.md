# Run the checked-out workflow with Calrissian

The lab is `practice-labs/5-Kubernetes/1-calrissian.ipynb`. It packs the current
checkout, runs the typed scatter workflow directly with Calrissian, then submits
the same package as a Kubernetes Job. Calrissian creates a pod for each processing
command-line tool.

## Prepare the local deployment

Use the editor and Minikube setup described in
`practice-labs/5-Kubernetes/README.md`. From the
`dev-platform-eoap/mastering-app-package` deployment module directory, the
image-loading task is:

```bash
task labs:kubernetes-images MINIKUBE_PROFILE=eoap-mastering-app-package-docker
```

This task belongs to the deployment repository, separately from this checkout's
developer Taskfile. Build the four current processing images in the editor first
using the container labs, then load them into the node. Repeat image loading
after a rebuild. The packed package uses `localhost/<tool>:metadata` tags so
Kubernetes can use the locally loaded images.

The editor and processing pods need the shared `/calrissian` volume, the
Calrissian service account, and a node-selector configuration. The commands below
use the deployment's `/workspace/mastering-app-package` checkout path.

## Pack the current checkout

Packing selects `#water-bodies` and renames the selected entrypoint to `#main`.
The notebook then changes local image tags and copies the typed scatter job:


```bash
export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}
```


```bash
mkdir -p /calrissian
cwltool --pack "${WORKSPACE}/cwl-workflow/app-water-bodies-cloud-native.cwl#water-bodies" > /calrissian/app-water-bodies-cloud-native.cwl
# A non-latest tag lets Kubernetes use images loaded into the local node.
python - <<'PYCODE'
import json
from pathlib import Path
path = Path("/calrissian/app-water-bodies-cloud-native.cwl")
package = json.loads(path.read_text())
def use_local_images(value):
    if isinstance(value, dict):
        for key, child in value.items():
            if key == "dockerPull" and isinstance(child, str) and child.startswith("localhost/") and child.endswith(":latest"):
                value[key] = child.removesuffix(":latest") + ":metadata"
            else:
                use_local_images(child)
    elif isinstance(value, list):
        for child in value:
            use_local_images(child)
use_local_images(package)
path.write_text(json.dumps(package, indent=2))
PYCODE
cp "${WORKSPACE}/cwl-workflow/typed-scatter-inputs.yaml" /calrissian/params.yaml
```

## Execute directly

`--max-ram` and `--max-cores` limit aggregate resources for running processing
pods. Temporary outputs and final results must be on the shared volume.
`--usage-report` writes resource usage, `--tool-logs-basepath` collects tool logs,
and `--pod-nodeselectors` supplies the deployment's node selectors.


```bash
mkdir -p /calrissian/logs
calrissian \
    --stdout /calrissian/results.json \
    --stderr /calrissian/app.log \
    --max-ram 3G \
    --max-cores 2 \
    --tmp-outdir-prefix /calrissian/tmp \
    --outdir /calrissian/results \
    --usage-report /calrissian/usage.json \
    --tool-logs-basepath /calrissian/logs \
    --pod-nodeselectors /etc/calrissian/pod-node-selector.yaml \
    /calrissian/app-water-bodies-cloud-native.cwl#main \
    /calrissian/params.yaml
```

While the workflow runs, inspect its pods with `kubectl get pods`.
On success, the output JSON points to a STAC catalog directory containing the
item documents and their masks. Inspect it with:


```bash
tree $( cat /calrissian/results.json | jq -r .stac_catalog.path )
```

## Submit the Kubernetes Job

The notebook also runs the same package with this manifest:

```yaml
--8<--
practice-labs/5-Kubernetes/k8s-job.yaml
--8<--
```

The Job uses `eoepca/pde-code-server:amd64` and the installed Calrissian command
at `/opt/calrissian-venv/bin/calrissian`. Adapt the image for a different PDE
build. The manifest mounts `calrissian-claim`, uses `calrissian-sa`, and reads
the packed package and parameters from `/calrissian`.

The notebook copies the node selectors onto that volume, recreates the Job on
repeat runs, and checks both success and failure:


```bash
cp /etc/calrissian/pod-node-selector.yaml /calrissian/pod-node-selector.yaml
# Recreate the Job so repeated notebook execution runs it again.
kubectl delete job water-bodies-detection --ignore-not-found
kubectl apply -f "${WORKSPACE}/practice-labs/5-Kubernetes/k8s-job.yaml"
completed=false
for attempt in {1..240}; do
    if kubectl wait --for=condition=complete --timeout=5s job/water-bodies-detection 2>/dev/null; then
        completed=true
        break
    fi
    if [ "$(kubectl get job water-bodies-detection -o jsonpath='{.status.failed}')" = "1" ]; then
        kubectl logs job/water-bodies-detection --tail=100
        break
    fi
done
[ "$completed" = true ]
```

The Job has no automatic retries (`backoffLimit: 0`) and retains its status for
one hour. On failure, inspect the Job logs and retry the lab after resolving the
cause. Proceed to the [benchmarking lab](../benchmarking/calrissian-benchmark.md)
using the prepared package.

## Published execution

The local lab uses the checkout and loaded images. Published deployments need
accessible versioned images and a distributed application package. Historical
release download scripts remain separate examples; they are not the preparation
steps for this lab.
