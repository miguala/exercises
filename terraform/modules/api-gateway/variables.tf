variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "cors_enabled" {
  description = "Enable CORS"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 7
}

variable "routes" {
  description = "Map of API routes and their configurations"
  type = map(object({
    method        = string
    path          = string
    lambda_arn    = string
    lambda_name   = string
    authorization = optional(string)
    authorizer_id = optional(string)
  }))
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}