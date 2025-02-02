terraform {
  source = "${get_parent_terragrunt_dir()}/modules//sns"
}

inputs = {
  # Common SNS configurations
}
