remote_state {
  backend = "local"
  config = {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  # Inputs generales (por ejemplo, región, producto, etc.)
  region             = "us-east-1"
  product            = "onboarding"
  billing_mode       = "PAY_PER_REQUEST"
  hash_key           = "id"
  stream_view_type   = "NEW_IMAGE"
  lambda_memory_size = 128
  lambda_timeout     = 10
  log_retention_days = 7
}
