export WORKSPACE=/workspace/app-package-training-bids23

cwltool \
    --podman \
    --outdir /workspace/runs \
    ${WORKSPACE}/cwl-workflow/app-water-bodies-cloud-native.cwl \
    --stac_items "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
    --stac_items "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2A_10TFK_20220524_0_L2A" \
    --aoi="-121.399,39.834,-120.74,40.472" \
    --epsg "EPSG:4326"