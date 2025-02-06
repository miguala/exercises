# Required variables
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Region must be in format 'us-east-1'"
  }
}

variable "country" {
  description = "Country code"
  type        = string
  default     = "ar"
  validation {
    condition     = contains(["ar", "co", "mx"], var.country)
    error_message = "Country must be 'ar', 'co' or 'mx'"
  }
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be 'dev', 'staging' or 'prod'"
  }
}

variable "product" {
  description = "Product name"
  type        = string
  default     = "onboarding"
}

# DynamoDB configuration
variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "DynamoDB table hash key"
  type        = string
  default     = "id"
}

variable "stream_view_type" {
  description = "DynamoDB stream view type"
  type        = string
  default     = "NEW_IMAGE"
}

# Lambda configuration
variable "lambda_memory_size" {
  description = "Lambda memory size (MB)"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Lambda timeout (seconds)"
  type        = number
  default     = 10
}

# Logging configuration
variable "log_retention_days" {
  description = "CloudWatch log retention (days)"
  type        = number
  default     = 7
}