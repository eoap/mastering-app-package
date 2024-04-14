export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

cwltool \
    --podman \
    --outdir ${WORKSPACE}/runs \
    ${WORKSPACE}/cwl-cli/stac.cwl \
    --item \
    "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
    --raster \
    ${WORKSPACE}/runs/otsu.tif