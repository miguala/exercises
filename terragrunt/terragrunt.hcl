remote_state {
  backend = "s3"
  config = {
    bucket         = "${get_env("TG_BUCKET_PREFIX", "")}-terraform-state-${get_env("TG_ENVIRONMENT", "")}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      Environment = "${local.environment}"
      Product     = "${local.product}"
      Country     = "${local.country}"
      Terraform   = "true"
    }
  }
}
EOF
}