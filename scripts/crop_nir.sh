export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

crop \
    --input-item "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
    --aoi='{"type":"Polygon","coordinates":[[[-121.399,39.834],[-120.74,39.834],[-120.74,40.472],[-121.399,40.472],[-121.399,39.834]]]}' \
    --epsg "4326" \
    --band nir 