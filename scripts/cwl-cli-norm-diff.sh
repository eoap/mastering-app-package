export WORKSPACE=/workspace/mastering-app-package

cwltool \
    --podman \
    --outdir ${WORKSPACE}/runs \
    ${WORKSPACE}/cwl-cli/norm-diff.cwl \
    --rasters \
    ${WORKSPACE}/runs/crop_green.tif \
    --rasters \
    ${WORKSPACE}/runs/crop_nir.tif