podman \
    run \
    -i \
    --userns=keep-id \
    --mount=type=bind,source=/workspace/mastering-app-package/runs,target=/runs \
    --mount=type=bind,source=/workspace/mastering-app-package/runs/otsu.tif,target=/inputs/otsu.tif,readonly \
    --workdir=/runs \
    --read-only=true \
    --user="$(id -u):$(id -g)" \
    --rm \
    --env=HOME=/runs \
    localhost/stac:latest \
    stac \
    --item \
    https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A \
    --rasters \
    /inputs/otsu.tif