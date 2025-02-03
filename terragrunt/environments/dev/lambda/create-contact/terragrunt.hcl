include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/lambda.hcl"
}

dependency "dynamodb" {
  config_path = "../../dynamodb"
}

inputs = {
  function_name         = "${local.country}-${local.product}-${local.environment}-create-contact"
  filename              = "${get_terragrunt_dir()}/../../../bin/create-contact.zip"
  enable_dynamodb_access = true
  dynamodb_actions      = ["dynamodb:PutItem"]
  environment_variables = {
    TABLE_NAME = dependency.dynamodb.outputs.table_name
  }
  dynamodb_table_arn    = dependency.dynamodb.outputs.table_arn
}