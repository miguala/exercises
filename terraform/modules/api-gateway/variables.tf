variable "api_name" {
  type = string
}

variable "country" {
  type = string
}

variable "product" {
  type = string
}

variable "environment" {
  type = string
}

variable "create_contact_lambda_arn" {
  type = string
}

variable "create_contact_lambda_name" {
  type = string
}

variable "get_contact_lambda_arn" {
  type = string
}

variable "get_contact_lambda_name" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "tags" {
  type = map(string)
}
