export WORKSPACE=/workspace/mastering-app-package

podman \
    build \
    --format docker \
    -t localhost/stage:latest \
    ${WORKSPACE}/water-bodies/command-line-tools/stage

# Current checkout uses separate installed staging commands.
podman build --format docker -t localhost/stage-in:latest ${WORKSPACE}/water-bodies/command-line-tools/stage-in
podman build --format docker -t localhost/stage-out:latest ${WORKSPACE}/water-bodies/command-line-tools/stage-out
