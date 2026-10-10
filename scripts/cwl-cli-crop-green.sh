export WORKSPACE=${WORKSPACE:-/workspace/mastering-app-package}
mkdir -p "${WORKSPACE}/runs"

cwltool \
    --podman \
    --outdir "${WORKSPACE}/runs" \
    "${WORKSPACE}/cwl-cli/crop.cwl" \
    "${WORKSPACE}/cwl-cli/crop-green-params.yaml"
