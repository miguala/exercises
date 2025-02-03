locals {
  environment = "dev"
  product     = "onboarding"
  aws_region  = "us-east-1"

  # País se obtiene del workspace
  country = get_workspace()
}