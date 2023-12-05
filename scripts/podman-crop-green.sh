podman run \
    -i \
    --userns=keep-id \
    --mount=type=bind,source=/workspace/runs,target=/runs \
    --workdir=/runs \
    --read-only=true \
    --user=1001:100 \
    --rm \
    --env=HOME=/runs \
    --env=PYTHONPATH=/app \
    localhost/crop:latest \
    python \
    -m \
    app \
    --aoi \
    "-121.399,39.834,-120.74,40.472" \
    --band \
    green \
    --epsg \
    "EPSG:4326" \
    --input-item \
    https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A