# live/ar/dev/terragrunt.hcl

# Incluimos la configuración común desde el archivo raíz (common.hcl)
include {
  path = find_in_parent_folders("common.hcl")
}

# Referenciamos el módulo que contiene la configuración completa (tu archivo Terraform)
terraform {
 source = "../../../"
}

inputs = {
  # Variables específicas para este ambiente
  country     = "ar"
  environment = "dev"
  
  # Si necesitas sobrescribir o agregar otros valores, hazlo aquí.
}
