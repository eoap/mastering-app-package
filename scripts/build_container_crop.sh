export WORKSPACE=/workspace/mastering-app-package

podman build --format docker -t localhost/crop:latest ${WORKSPACE}/water-bodies/command-line-tools/crop
