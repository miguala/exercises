variable "region" {
  description = "AWS region"
  type        = string
}

variable "country" {
  description = "Country code"
  type        = string
}

variable "product" {
  description = "Product name (onboarding, payments, etc)"
  type        = string
  default     = "onboarding"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED, PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "DynamoDB table hash key name (attribute)"
  type        = string
  default     = "id"
}

variable "stream_view_type" {
  description = "DynamoDB stream view type (NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY)"
  type        = string
  default     = "NEW_IMAGE"
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}