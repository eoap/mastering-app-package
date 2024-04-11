export WORKSPACE=/workspace/mastering-app-package

podman build --format docker -t localhost/norm-diff:latest ${WORKSPACE}/water-bodies/command-line-tools/norm_diff
