# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Product     = "my-product"
      Country     = "us"
      Terraform   = "true"
    }
  }
}
