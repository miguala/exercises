terraform {
  source = "../../.."
}

include {
  path = find_in_parent_folders("common.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  
  dynamo_config = {
    billing_mode      = "PAY_PER_REQUEST"
    hash_key         = "id"
    stream_view_type = "NEW_IMAGE"
  }

  lambda_defaults = {
    memory_size       = 128
    timeout          = 10
    log_retention_days = 7
  }

  api_gateway_config = {
    cors_enabled      = true
    log_retention_days = 7
  }
}

inputs = {
  dynamo = local.dynamo_config

  lambdas = {
    create_contact = local.lambda_defaults
    get_contact = local.lambda_defaults
    dynamodb_trigger_lambda = local.lambda_defaults
    sns_trigger_lambda = local.lambda_defaults
  }

  api_gateway = local.api_gateway_config
  
  # Usar las variables importadas del common.hcl
  tags = merge(
    local.common_vars.locals.common_tags,
    {
      country = local.common_vars.locals.country
    }
  )
}
