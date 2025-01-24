variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}

variable "sns_topic_name" {
  description = "Nombre del tema SNS"
  type        = string
  default     = "Contacts8aTopic"
}

variable "lambda_role_name" {
  description = "Nombre del rol IAM para Lambda"
  type        = string # Ensure this is correctly declared
}