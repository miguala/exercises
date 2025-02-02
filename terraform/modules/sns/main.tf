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

# modules/sns/outputs.tf
output "topic_arn" {
  value = aws_sns_topic.this.arn
}

output "topic_name" {
  value = aws_sns_topic.this.name
}