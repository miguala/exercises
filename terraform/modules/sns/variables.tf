variable "lambda_subscriptions" {
  description = "Map of Lambda functions to subscribe to the SNS topic"
  type = map(object({
    function_name = string
    function_arn  = string
  }))
  default = {}
}


# modules/sns/variables.tf
variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "country" {
  description = "Country code"
  type        = string
}

variable "product" {
  description = "Product name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_function_arns" {
  description = "List of Lambda function ARNs to subscribe to the topic"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}