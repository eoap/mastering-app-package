export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

norm_diff \
    --rasters crop_green.tif \
    --rasters crop_nir.tif