terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Common tags for all resources
locals {
  common_tags = {
    Product     = var.product
    Environment = var.environment
    Terraform   = "true"
  }
}

# DynamoDB table for contacts
module "contacts_table" {
  source           = "./modules/dynamodb"
  table_name       = "${var.country}-${var.product}-${var.environment}-contacts"
  billing_mode     = var.billing_mode
  hash_key         = var.hash_key
  stream_enabled   = true
  stream_view_type = var.stream_view_type
  tags             = local.common_tags
}

# Cognito User Pool for authentication
module "cognito" {
  source         = "./modules/cognito"
  user_pool_name = "${var.country}-${var.product}-${var.environment}-user-pool"
  client_name    = "${var.country}-${var.product}-${var.environment}-client"
  api_gateway_id = module.api_gateway.api_id
  region         = var.region
  environment    = var.environment
  tags           = local.common_tags
}

# API Gateway configuration
module "api_gateway" {
  source             = "./modules/api-gateway"
  api_name           = "${var.country}-${var.product}-${var.environment}-api"
  cors_enabled       = true
  log_retention_days = var.log_retention_days
  tags               = local.common_tags

  routes = {
    "create_contact" = {
      method      = "POST"
      path        = "/contacts"
      lambda_arn  = module.lambda_create.function_arn
      lambda_name = module.lambda_create.function_name
      # authorization = "JWT"
      # authorizer_id = module.cognito.authorizer_id
    }
    "get_contact" = {
      method      = "GET"
      path        = "/contacts/{id}"
      lambda_arn  = module.lambda_get.function_arn
      lambda_name = module.lambda_get.function_name
      # authorization = "JWT"
      # authorizer_id = module.cognito.authorizer_id
    }
  }
}

# Lambda functions for API endpoints
module "lambda_create" {
  source                 = "./modules/lambda"
  function_name          = "${var.country}-${var.product}-${var.environment}-create-contact"
  filename               = "./../bin/create-contact.zip"
  memory_size            = var.lambda_memory_size
  timeout                = var.lambda_timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:PutItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  log_retention_days = var.log_retention_days
  tags               = local.common_tags
}

module "lambda_get" {
  source                 = "./modules/lambda"
  function_name          = "${var.country}-${var.product}-${var.environment}-get-contact"
  filename               = "./../bin/get-contact.zip"
  memory_size            = var.lambda_memory_size
  timeout                = var.lambda_timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:GetItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  log_retention_days = var.log_retention_days
  tags               = local.common_tags
}

# SNS Topic for notifications
module "sns_topic" {
  source      = "./modules/sns"
  topic_name  = "${var.country}-${var.product}-${var.environment}-contacts"
  country     = var.country
  product     = var.product
  environment = var.environment
  tags        = local.common_tags

  lambda_subscriptions = {
    sns_trigger = {
      function_name = module.sns_trigger_lambda.function_name
      function_arn  = module.sns_trigger_lambda.function_arn
    }
    # Add more Lambda subscriptions here if needed
  }
}

# Lambda function for DynamoDB Stream processing
module "dynamodb_trigger_lambda" {
  source                 = "./modules/lambda"
  function_name          = "${var.country}-${var.product}-${var.environment}-dynamodb-trigger"
  filename               = "./../bin/dynamodb-trigger.zip"
  memory_size            = var.lambda_memory_size
  timeout                = var.lambda_timeout
  enable_dynamodb_access = true
  dynamodb_actions = [
    "dynamodb:GetRecords",
    "dynamodb:GetShardIterator",
    "dynamodb:DescribeStream",
    "dynamodb:ListStreams"
  ]
  dynamodb_table_arn = module.contacts_table.table_stream_arn
  enable_sns_access  = true
  sns_topic_arn      = module.sns_topic.topic_arn
  environment_variables = {
    SNS_TOPIC_ARN = module.sns_topic.topic_arn
  }
  log_retention_days = var.log_retention_days
  tags               = local.common_tags
}

# Lambda function for SNS message processing
module "sns_trigger_lambda" {
  source                 = "./modules/lambda"
  function_name          = "${var.country}-${var.product}-${var.environment}-sns-trigger"
  filename               = "./../bin/sns-trigger.zip"
  memory_size            = var.lambda_memory_size
  timeout                = var.lambda_timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:UpdateItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  log_retention_days = var.log_retention_days
  tags               = local.common_tags
}