export WORKSPACE=/workspace/app-package-training-bids23
export RUNTIME=/workspace/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

python \
    ${WORKSPACE}/water-bodies/command-line-tools/norm_diff/app.py \
    crop_green.tif \
    crop_nir.tif