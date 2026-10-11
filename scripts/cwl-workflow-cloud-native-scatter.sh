export WORKSPACE=${WORKSPACE:-/workspace/mastering-app-package}
mkdir -p "${WORKSPACE}/runs"

cwltool \
    --podman \
    --outdir "${WORKSPACE}/runs" \
    "${WORKSPACE}/cwl-workflow/app-water-bodies-cloud-native.cwl#water-bodies" \
    "${WORKSPACE}/cwl-workflow/typed-scatter-inputs.yaml"
