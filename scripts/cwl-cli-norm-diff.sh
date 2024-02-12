export WORKSPACE=/workspace/mastering-app-package

cwltool \
    --podman \
    --outdir /workspace/runs \
    ${WORKSPACE}/cwl-cli/norm-diff.cwl \
    --rasters \
    /workspace/runs/crop_green.tif \
    --rasters \
    /workspace/runs/crop_nir.tif