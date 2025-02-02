terraform {
  source = "${get_parent_terragrunt_dir()}/modules//api-gateway"
}

inputs = {
  cors_enabled       = true
  log_retention_days = 14
}
