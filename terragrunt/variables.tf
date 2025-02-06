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

variable "dynamo" {
  description = "Configuración de DynamoDB"
  type = object({
    billing_mode     = string
    hash_key         = string
    stream_view_type = string
  })
  default = {
    billing_mode     = "PAY_PER_REQUEST"
    hash_key         = "id"
    stream_view_type = "NEW_IMAGE"
  }

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamo.billing_mode)
    error_message = "Billing mode must be 'PAY_PER_REQUEST' or 'PROVISIONED'"
  }

  validation {
    condition     = contains(["NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES", "KEYS_ONLY"], var.dynamo.stream_view_type)
    error_message = "Stream view type must be 'NEW_IMAGE', 'OLD_IMAGE', 'NEW_AND_OLD_IMAGES' or 'KEYS_ONLY'"
  }
}

variable "lambdas" {
  description = "Configuraciones de las Lambdas"
  type = map(object({
    memory_size        = number
    timeout           = number
    log_retention_days = number
  }))
  default = {
    create_contact = {
      memory_size        = 128
      timeout           = 10
      log_retention_days = 7
    }
    get_contact = {
      memory_size        = 128
      timeout           = 10
      log_retention_days = 7
    }
    dynamodb_trigger_lambda = {
      memory_size        = 128
      timeout           = 10
      log_retention_days = 7
    }
    sns_trigger_lambda = {
      memory_size        = 128
      timeout           = 10
      log_retention_days = 7
    }
    
  }
}

variable "api_gateway" {
  description = "Configuración de API Gateway"
  type = object({
    cors_enabled       = bool
    log_retention_days = number
  })
  default = {
    cors_enabled       = true
    log_retention_days = 7
  }
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

