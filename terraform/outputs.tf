# API Gateway outputs
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "api_execution_arn" {
  description = "API Gateway execution ARN"
  value       = module.api_gateway.api_execution_arn
}

# DynamoDB outputs
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.contacts_table.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.contacts_table.table_arn
}

output "dynamodb_stream_arn" {
  description = "ARN of the DynamoDB stream"
  value       = module.contacts_table.table_stream_arn
}

# Lambda functions outputs
output "lambda_functions" {
  description = "Details of all Lambda functions"
  value = {
    create_contact = {
      name = module.lambda_create.function_name
      arn  = module.lambda_create.function_arn
    }
    get_contact = {
      name = module.lambda_get.function_name
      arn  = module.lambda_get.function_arn
    }
    dynamodb_trigger = {
      name = module.dynamodb_trigger_lambda.function_name
      arn  = module.dynamodb_trigger_lambda.function_arn
    }
    sns_trigger = {
      name = module.sns_trigger_lambda.function_name
      arn  = module.sns_trigger_lambda.function_arn
    }
  }
}

# SNS Topic output
output "sns_topic" {
  description = "Details of the SNS topic"
  value = {
    name = module.sns_topic.topic_name
    arn  = module.sns_topic.topic_arn
  }
}

# Full API URLs
output "api_urls" {
  description = "Complete URLs for API endpoints"
  value = {
    create_contact = "${module.api_gateway.api_endpoint}/contacts"
    get_contact    = "${module.api_gateway.api_endpoint}/contacts/{id}"
  }
}