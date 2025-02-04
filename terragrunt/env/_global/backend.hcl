remote_state {
  backend = "s3"
  config = {
    bucket         = "dev-onboarding-terraform-state-bucket"
    key            = "de/onboarding/${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}