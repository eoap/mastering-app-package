export WORKSPACE=/workspace/mastering-app-package

podman \
    build \
    --format docker \
    -t localhost/stage:latest \
    ${WORKSPACE}/water-bodies/command-line-tools/stage