export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

cwltool \
    --podman \
    --outdir ${WORKSPACE}/runs \
    ${WORKSPACE}/cwl-cli/crop.cwl \
    --item "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
    --aoi="-121.399,39.834,-120.74,40.472" \
    --epsg "EPSG:4326" \
    --band "green" 