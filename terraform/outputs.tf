output "api_url" {
  value = module.api_gateway.api_url
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "lambda_role_arn" {
  value = module.iam.role_arn
}

output "create_contact_lambda_arn" {
  value = module.lambda.create_contact_arn
}

output "get_contact_lambda_arn" {
  value = module.lambda.get_contact_arn
}