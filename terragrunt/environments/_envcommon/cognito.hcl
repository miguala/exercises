terraform {
  source = "${get_parent_terragrunt_dir()}/modules//cognito"
}

inputs = {
  # Common Cognito configurations
}