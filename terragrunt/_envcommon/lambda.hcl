terraform {
  source = "${get_parent_terragrunt_dir()}/modules//lambda"
}

inputs = {
  memory_size       = 128
  timeout           = 30
  log_retention_days = 14
}