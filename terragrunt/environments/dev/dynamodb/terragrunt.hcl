include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/dynamodb.hcl"
}

dependency "lambda_dynamodb_trigger" {
  config_path = "../lambda/dynamodb-trigger"
}

inputs = {
  table_name = "${local.country}-${local.product}-${local.environment}-contacts"
  lambda_event_sources = {
    dynamodb_trigger = {
      function_name     = dependency.lambda_dynamodb_trigger.outputs.function_name
      starting_position = "LATEST"
    }
  }
}