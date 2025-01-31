variable "region" {
  description = "AWS region"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "La región debe tener el formato 'us-east-1'."
  }
}

variable "country" {
  description = "Country code"
  type        = string
  validation {
    condition     = contains(["ar", "co", "mx", ], var.country)
    error_message = "El país debe ser 'ar', 'co' o 'mx'."
  }
}

variable "product" {
  description = "Product name (onboarding, payments, etc)"
  type        = string
  default     = "onboarding"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev', 'staging' o 'prod'."
  }
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED, PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "El modo de facturación debe ser 'PROVISIONED' o 'PAY_PER_REQUEST'."
  }
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
  validation {
    condition     = contains(["NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES", "KEYS_ONLY"], var.stream_view_type)
    error_message = "El tipo de vista de stream debe ser 'NEW_IMAGE', 'OLD_IMAGE', 'NEW_AND_OLD_IMAGES' o 'KEYS_ONLY'."
  }
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "El tamaño de memoria debe estar entre 128 y 10240 MB."
  }
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "El timeout debe estar entre 1 y 900 segundos."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 365
    error_message = "La retención de logs debe estar entre 1 y 365 días."
  }
}