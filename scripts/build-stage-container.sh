export WORKSPACE=/workspace/app-package-training-bids23

podman \
    build \
    --format docker \
    -t localhost/stage:latest \
    ${WORKSPACE}/water-bodies/command-line-tools/stage