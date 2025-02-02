# main.tf in the SNS module

# SNS Topic
resource "aws_sns_topic" "this" {
  name = var.topic_name
  tags = var.tags
}

# Lambda permissions using a map instead of a list
resource "aws_lambda_permission" "sns_lambda" {
  for_each = var.lambda_subscriptions

  statement_id  = "AllowSNSInvoke_${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.this.arn
}

# SNS Topic subscriptions using the same map
resource "aws_sns_topic_subscription" "lambda" {
  for_each = var.lambda_subscriptions

  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = each.value.function_arn
}

# variables.tf in the SNS module
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

# modules/sns/outputs.tf
output "topic_arn" {
  value = aws_sns_topic.this.arn
}

output "topic_name" {
  value = aws_sns_topic.this.name
}