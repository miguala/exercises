variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "filename" {
  description = "Path to the Lambda deployment package"
  type        = string
}

variable "memory_size" {
  description = "Memory size for Lambda function"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for Lambda function"
  type        = number
  default     = 10
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Retención de logs en CloudWatch"
  type        = number
  default     = 7
}

variable "enable_dynamodb_access" {
  description = "Enable DynamoDB access"
  type        = bool
  default     = false
}

variable "dynamodb_actions" {
  description = "DynamoDB actions to allow"
  type        = list(string)
  default     = []
}

variable "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  type        = string
  default     = ""
}

variable "enable_sns_access" {
  description = "Enable SNS access"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "SNS topic ARN"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}