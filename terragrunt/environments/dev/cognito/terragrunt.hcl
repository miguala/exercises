include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/cognito.hcl"
}

dependency "api_gateway" {
  config_path = "../api-gateway"
}

inputs = {
  user_pool_name = "${local.country}-${local.product}-${local.environment}-user-pool"
  client_name    = "${local.country}-${local.product}-${local.environment}-client"
  api_gateway_id = dependency.api_gateway.outputs.api_id
}