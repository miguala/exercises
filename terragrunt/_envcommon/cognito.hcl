terraform {
  source = "${get_parent_terragrunt_dir()}/modules//cognito"
}

inputs = {
  # Configuraciones comunes para Cognito
}