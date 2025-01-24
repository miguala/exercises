output "create_contact_arn" {
  value = aws_lambda_function.create_contact.invoke_arn
}

output "get_contact_arn" {
  value = aws_lambda_function.get_contact.invoke_arn
}

output "dynamodb_trigger_arn" {
  value = aws_lambda_function.dynamodb_trigger.arn
}

output "sns_trigger_arn" {
  value = aws_lambda_function.sns_trigger.arn
}

output "dynamodb_trigger_function_name" {
  value = aws_lambda_function.dynamodb_trigger.function_name
}

output "sns_trigger_function_name" {
  value = aws_lambda_function.sns_trigger.function_name
}