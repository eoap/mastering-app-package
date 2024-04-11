export WORKSPACE=/workspace/mastering-app-package

podman build --format docker -t localhost/otsu:latest ${WORKSPACE}/water-bodies/command-line-tools/otsu
