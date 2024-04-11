cwltool \
    --podman \
    ${WORKSPACE}/cwl-cli/stage-out.cwl \
    --aws_access_key_id $( cat ~/.aws/credentials | grep aws_access_key_id | cut -d "=" -f 2 ) \
    --aws_secret_access_key $( cat ~/.aws/credentials | grep aws_secret_access_key | cut -d "=" -f 2 ) \
    --endpoint_url $( cat ~/.aws/config | grep endpoint_url | head -n 1 | cut -d "=" -f 2 ) \
    --region_name $( cat ~/.aws/config | grep region | cut -d "=" -f 2 ) \
    --s3_bucket processing-results \
    --sub_path processing-results/$( cat /proc/sys/kernel/random/uuid ) \
    --stac_catalog ${WORKSPACE}/runs