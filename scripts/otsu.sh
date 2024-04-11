export WORKSPACE=/workspace/mastering-app-package
export RUNTIME=${WORKSPACE}/runs
mkdir -p ${RUNTIME}
cd ${RUNTIME}

python \
    ${WORKSPACE}/water-bodies/command-line-tools/otsu/app.py \
    norm_diff.tif