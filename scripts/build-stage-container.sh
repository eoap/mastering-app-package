export WORKSPACE=/workspace/mastering-app-package

# Current checkout uses separate installed staging commands.
podman build --format docker -t localhost/stage-in:latest ${WORKSPACE}/water-bodies/command-line-tools/stage-in
podman build --format docker -t localhost/stage-out:latest ${WORKSPACE}/water-bodies/command-line-tools/stage-out
