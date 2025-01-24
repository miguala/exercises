variable "lambda_role_arn" {
  description = "ARN del rol IAM para Lambda"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN del tema SNS"
  type        = string
}

variable "dynamodb_stream_arn" {
  description = "ARN del stream de DynamoDB"
  type        = string
}

