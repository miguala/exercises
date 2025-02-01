variable "api_name" {
  type        = string
  description = "Name of the API Gateway"
}

variable "product" {
  type        = string
  description = "Product name"
}

variable "country" {
  type        = string
  description = "Country code"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

variable "cors_enabled" {
  type        = bool
  description = "Whether to enable CORS for the API"
  default     = false
}

variable "cors_configuration" {
  type = object({
    allow_origins = list(string)
    allow_methods = list(string)
    allow_headers = list(string)
    max_age      = number
  })
  description = "CORS configuration for the API"
  default = {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age      = 7200
  }
}

variable "routes" {
  description = "Map of route configurations"
  type = map(object({
    method          = string
    path            = string
    lambda_arn      = string
    lambda_name     = string
    authorization   = optional(string, "NONE")
    authorizer_id   = optional(string)
    request_parameters = optional(list(object({
      parameter_key   = string
      required       = bool
    })))
  }))
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain API Gateway logs"
  default     = 7
}