export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

cwltool \
    --podman \
    --outdir ${WORKSPACE}/runs \
    ${WORKSPACE}/cwl-cli/norm-diff.cwl \
    --rasters \
    ${WORKSPACE}/runs/crop_green.tif \
    --rasters \
    ${WORKSPACE}/runs/crop_nir.tif