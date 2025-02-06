# Configuraciones comunes para AR

locals {
  # Puedes definir aquí variables comunes para todos los entornos en AR
  region      = "us-east-1"
  country     = "ar"
  environment = "dev"
  product     = "onboarding"

  # Ejemplo de tags comunes
  common_tags = {
    Owner       = "terraform"
    Environment = "dev"
    Country     = "ar"
  }
}

# Opcionalmente, puedes definir argumentos extra para Terraform que serán comunes a todos los módulos
terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var=region=${local.region}",
      "-var=country=${local.country}",
      "-var=environment=${local.environment}",
      "-var=product=${local.product}"
    ]
  }
}
