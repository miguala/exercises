# Outputs del módulo DynamoDB
# output "dynamodb_table_name" {
#   description = "Nombre de la tabla DynamoDB"
#   value       = module.contacts_table.table_name
# }

# output "dynamodb_table_arn" {
#   description = "ARN de la tabla DynamoDB"
#   value       = module.contacts_table.table_arn
# }

# output "dynamodb_table_stream_arn" {
#   description = "ARN del stream de la tabla DynamoDB"
#   value       = module.contacts_table.table_stream_arn
# }

# Outputs del módulo API Gateway
output "api_gateway_endpoint" {
  description = "Endpoint del API Gateway"
  value       = module.api_gateway.api_endpoint
}

# output "api_gateway_execution_arn" {
#   description = "ARN de ejecución del API Gateway"
#   value       = module.api_gateway.api_execution_arn
# }

# # Outputs del módulo Lambda (Create Contact)
# output "create_contact_lambda_arn" {
#   description = "ARN de la función Lambda 'create-contact'"
#   value       = module.create_contact_lambda.function_arn
# }

# # Outputs del módulo Lambda (Get Contact)
# output "get_contact_lambda_arn" {
#   description = "ARN de la función Lambda 'get-contact'"
#   value       = module.get_contact_lambda.function_arn
# }

# # Outputs del módulo Lambda (DynamoDB Trigger)
# output "dynamodb_trigger_lambda_arn" {
#   description = "ARN de la función Lambda 'dynamodb-trigger'"
#   value       = module.dynamodb_trigger_lambda.function_arn
# }

# # Outputs del módulo Lambda (SNS Trigger)
# output "sns_trigger_lambda_arn" {
#   description = "ARN de la función Lambda 'sns-trigger'"
#   value       = module.sns_trigger_lambda.function_arn
# }

# # Outputs del módulo SNS
# output "sns_topic_arn" {
#   description = "ARN del tema SNS"
#   value       = module.sns_topic.topic_arn
# }
