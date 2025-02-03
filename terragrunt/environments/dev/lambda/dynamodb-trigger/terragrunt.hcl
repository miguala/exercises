include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/lambda.hcl"
}

dependency "dynamodb" {
  config_path = "../../dynamodb"
}

dependency "sns" {
  config_path = "../../sns"
}

inputs = {
  function_name         = "${local.country}-${local.product}-${local.environment}-dynamodb-trigger"
  filename              = "${get_terragrunt_dir()}/../../../bin/dynamodb-trigger.zip"
  enable_dynamodb_access = true
  dynamodb_actions      = [
    "dynamodb:GetRecords",
    "dynamodb:GetShardIterator",
    "dynamodb:DescribeStream",
    "dynamodb:ListStreams"
  ]
  dynamodb_table_arn    = dependency.dynamodb.outputs.table_stream_arn
  enable_sns_access     = true
  sns_topic_arn         = dependency.sns.outputs.topic_arn
  environment_variables = {
    SNS_TOPIC_ARN = dependency.sns.outputs.topic_arn
  }
}