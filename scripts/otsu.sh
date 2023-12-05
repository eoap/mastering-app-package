export WORKSPACE=/workspace/app-package-training-bids23
export RUNTIME=/workspace/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

python \
    ${WORKSPACE}/water-bodies/command-line-tools/otsu/app.py \
    norm_diff.tif