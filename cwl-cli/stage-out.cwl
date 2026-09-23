cwlVersion: v1.2


class: CommandLineTool
id: stage-out

doc: "Stage-out the results to S3"
inputs:
  s3_bucket:
    type: string
  sub_path:
    type: string
  aws_access_key_id:
    type: string
  aws_secret_access_key:
    type: string
  region_name:
    type: string
  endpoint_url:
    type: string
  stac_catalog:
    type: Directory
outputs:
  s3_catalog_output:
    outputBinding:
      outputEval: ${  return "s3://" + inputs.s3_bucket + "/" + inputs.sub_path + "/catalog.json"; }
    type: string
baseCommand: stage-out
arguments:
  - $( inputs.stac_catalog.path )
  - $( inputs.s3_bucket )
  - $( inputs.sub_path )
requirements:
  DockerRequirement:
    dockerPull: localhost/stage-out:latest
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
  EnvVarRequirement:
    envDef:
      aws_access_key_id: $( inputs.aws_access_key_id )
      aws_secret_access_key: $( inputs.aws_secret_access_key )
      aws_region_name: $( inputs.region_name )
      aws_endpoint_url: $( inputs.endpoint_url )
  ResourceRequirement: {}
