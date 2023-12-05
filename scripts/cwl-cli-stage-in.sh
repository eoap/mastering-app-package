ls9_ref="https://planetarycomputer.microsoft.com/api/stac/v1/collections/landsat-c2-l2/items/LC09_L2SP_042033_20231015_02_T1"

cwltool \
    --podman \
    --outdir /workspace/runs \
    ${WORKSPACE}/cwl-cli/stage-in.cwl \
    --reference \
    ${ls9_ref} > staged.json