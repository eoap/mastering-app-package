podman \
    run \
    -i \
    --userns=keep-id \
    --mount=type=bind,source=/workspace/mastering-app-package/runs,target=/runs \
    --mount=type=bind,source=/workspace/mastering-app-package/runs/crop_green.tif,target=/inputs/crop_green.tif,readonly \
    --mount=type=bind,source=/workspace/mastering-app-package/runs/crop_nir.tif,target=/inputs/crop_nir.tif,readonly \
    --workdir=/runs \
    --read-only=true \
    --user="$(id -u):$(id -g)" \
    --rm \
    --env=HOME=/runs \
    localhost/norm-diff:latest \
    norm_diff \
    --rasters /inputs/crop_green.tif \
    --rasters /inputs/crop_nir.tif