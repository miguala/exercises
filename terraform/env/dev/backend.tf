terraform {
  backend "s3" {
    bucket         = "dev-onboarding-terraform-state-bucket"  # Nombre del bucket S3
    key            = "de/onboarding/terraform.tfstate"      # Ruta dentro del bucket
    region         = "us-east-1"                  # Región de AWS
    dynamodb_table = "terraform-lock"             # Tabla DynamoDB para bloqueo
    encrypt        = true                         # Habilitar cifrado del estado
  }
}