export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

cwltool \
    --podman \
    --outdir ${WORKSPACE}/runs \
    ${WORKSPACE}/cwl-cli/otsu.cwl \
    --raster \
    ${WORKSPACE}/runs/norm_diff.tif