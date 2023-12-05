cwltool \
    --podman \
    --outdir /workspace/runs \
    ${WORKSPACE}/cwl-cli/stac.cwl \
    --item \
    "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
    --raster \
    /workspace/runs/otsu.tif