include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/sns.hcl"
}

dependency "lambda_sns_trigger" {
  config_path = "../lambda/sns-trigger"
}

inputs = {
  topic_name = "${local.country}-${local.product}-${local.environment}-contacts"
  lambda_subscriptions = {
    sns_trigger = {
      function_name = dependency.lambda_sns_trigger.outputs.function_name
      function_arn  = dependency.lambda_sns_trigger.outputs.function_arn
    }
  }
}