region             = "us-east-1"
country            = "ar"
environment        = "dev"
product            = "onboarding"

dynamo = {
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "id"
  stream_view_type = "NEW_IMAGE"
}

lambdas = {
  create_contact = {
    memory_size        = 128
    timeout           = 10
    log_retention_days = 7
  }
  get_contact = {
    memory_size        = 128
    timeout           = 10
    log_retention_days = 7
  }
  dynamodb_trigger_lambda = {
    memory_size        = 128
    timeout           = 10
    log_retention_days = 7
  }
  sns_trigger_lambda = {
    memory_size        = 128
    timeout           = 10
    log_retention_days = 7
  }
}

api_gateway = {
  cors_enabled       = true
  log_retention_days = 7
}

tags = {
  product     = "onboarding"
  environment = "dev"
  country     = "ar"
  owner       = "terraform"
}

