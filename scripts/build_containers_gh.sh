WORKSPACE=/workspace/mastering-app-package

version="bids23"
repo="ghcr.io/terradue/${REPO}"

for step in crop norm_diff otsu stac
do
    tag=${repo}/${step}:${version}
    podman build --format docker -t ${tag} ${WORKSPACE}/water-bodies/command-line-tools/crop
    podman push ${tag}

    t="$tag" s="$step" yq eval -i '(.$graph[] | select (.id == env(s)) ).hints.DockerRequirement.dockerPull = env(t)' ${WORKSPACE}/cwl-workflow/app-water-bodies-cloud-native.cwl
done