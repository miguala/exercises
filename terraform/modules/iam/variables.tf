variable "lambda_role_name" {
  description = "Nombre del rol IAM para Lambda"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN de la tabla DynamoDB"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN del tema SNS"
  type        = string
}