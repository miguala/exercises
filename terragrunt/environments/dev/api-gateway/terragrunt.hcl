include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/api-gateway.hcl"
}

dependency "lambda_create" {
  config_path = "../lambda/create-contact"
}

dependency "lambda_get" {
  config_path = "../lambda/get-contact"
}

dependency "cognito" {
  config_path = "../cognito"
}

inputs = {
  api_name = "${local.country}-${local.product}-${local.environment}-api"
  routes = {
    "create_contact" = {
      method      = "POST"
      path        = "/contacts"
      lambda_arn  = dependency.lambda_create.outputs.function_arn
      lambda_name = dependency.lambda_create.outputs.function_name
      authorization = "JWT"
      authorizer_id = dependency.cognito.outputs.authorizer_id
    }
    "get_contact" = {
      method      = "GET"
      path        = "/contacts/{id}"
      lambda_arn  = dependency.lambda_get.outputs.function_arn
      lambda_name = dependency.lambda_get.outputs.function_name
      authorization = "JWT"
      authorizer_id = dependency.cognito.outputs.authorizer_id
    }
  }
}