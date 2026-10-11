# Run a published workflow with Calrissian

The lab is `practice-labs/5-Kubernetes/1-calrissian.ipynb`. It downloads a
published packed application package and its matching inputs, runs it with
Calrissian, then submits the same package as a Kubernetes Job. Processing pods
pull digest-pinned images from the registry on any suitably configured cluster.

## Prepare the cluster

Install Calrissian and configure its service account and RBAC, a shared RWX
volume mounted at `/calrissian`, and node-selector configuration. All nodes
running processing pods must be able to pull the published images and access
the input STAC data. Private registries additionally need image-pull credentials.
Use your cluster's namespace, PVC and service-account names in the Job manifest.
The runner image must contain Calrissian at the command path used by the Job;
replace the example PDE image if your deployment uses a different runner.

The editor example uses `/workspace/mastering-app-package`. Set `WORKSPACE` to
your own checkout location. Minikube is an optional development environment;
local builds and image-loading tasks are not prerequisites for chapter 5.

## Download the selected release

```bash
export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p "${RUNTIME}"
cd "${RUNTIME}"
# Default: 2.0.0 after publication. For pre-release testing, set the actual candidate tag.
# export APPLICATION_PACKAGE_VERSION=2.0.0-rc.<run-number>.<run-attempt>
bash "${WORKSPACE}/scripts/prepare-kubernetes-lab.sh"
```

The helper downloads packed CWL and `typed-scatter-inputs.yaml` from the same
GitHub release, validates them, checks the selected version and registry image
digests, then writes the workflow and `params.yaml` under `/calrissian`.
It fails if the release does not exist; it does not substitute a local package.
The packed entrypoint is `#main`.

Before a final release exists, run the candidate CI workflow from `develop`,
then select that published candidate here. Both chapter 5 notebooks and the Job
use the same downloaded workflow and parameters. See the
[release-candidate procedure](../release/ci.md#validate-chapter-5-before-a-stable-release).

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

This lab downloads published CWL and uses registry-hosted images. Deployments need
accessible versioned images and a distributed application package. Historical
release download scripts remain separate examples; they are not the preparation
steps for this lab.
