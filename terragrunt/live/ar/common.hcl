locals {
  region      = "us-east-1"
  country     = "ar"
  environment = "dev"
  product     = "onboarding"
  
  # Centralizar tags comunes
  common_tags = {
    product     = local.product
    country     = local.country
    owner       = "terraform"
    environment = local.environment
  }
}