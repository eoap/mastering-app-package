podman \
    run \
    -i \
    --userns=keep-id \
    --mount=type=bind,source=/workspace/mastering-app-package/runs,target=/runs \
    --mount=type=bind,source=/workspace/mastering-app-package/runs/norm_diff.tif,target=/inputs/norm_diff.tif,readonly \
    --workdir=/runs \
    --read-only=true \
    --user="$(id -u):$(id -g)" \
    --rm \
    --env=HOME=/runs \
    localhost/otsu:latest \
    otsu \
    --raster /inputs/norm_diff.tif