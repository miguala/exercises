terraform {
  source = "${get_parent_terragrunt_dir()}/modules//sns"
}

inputs = {
  # Configuraciones comunes para SNS
}