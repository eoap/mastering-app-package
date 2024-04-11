podman \
    run \
    -i \
    --userns=keep-id \
    --mount=type=bind,source=/workspace/mastering-app-package/runs,target=/runs \
    --mount=type=bind,source=/workspace/mastering-app-package/runs/norm_diff.tif,target=/inputs/norm_diff.tif,readonly \
    --workdir=/runs \
    --read-only=true \
    --user=1001:100 \
    --rm \
    --env=HOME=/runs \
    --env=PYTHONPATH=/app \
    localhost/otsu:latest \
    python \
    -m \
    app \
    /inputs/norm_diff.tif