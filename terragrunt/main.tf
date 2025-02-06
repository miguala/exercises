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
  prefix = "${var.country}-${var.product}-${var.environment}"
}

# DynamoDB table for contacts
module "contacts_table" {
  source           = "./modules/dynamodb"
  table_name       = "${local.prefix}-contacts"
  billing_mode     = var.dynamo.billing_mode
  hash_key         = var.dynamo.hash_key
  stream_enabled   = true
  stream_view_type = var.dynamo.stream_view_type
  tags             = var.tags
  lambda_event_sources = {
    dynamodb_trigger = {
      function_name     = module.dynamodb_trigger_lambda.function_name
      starting_position = "LATEST"
    }
  }
}

# Cognito User Pool for authentication
module "cognito" {
  source         = "./modules/cognito"
  user_pool_name = "${local.prefix}-user-pool"
  client_name    = "${local.prefix}-client"
  api_gateway_id = module.api_gateway.api_id
  region         = var.region
  environment    = var.environment
  tags           = var.tags
}

# API Gateway configuration
module "api_gateway" {
  source             = "./modules/api-gateway"
  api_name           = "${local.prefix}-api"
  cors_enabled       = true
  log_retention_days = var.api_gateway.log_retention_days
  tags               = var.tags

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
  function_name          = "${local.prefix}-create-contact"
  filename               = "./../bin/create-contact.zip"
  memory_size            = var.lambdas.create_contact.memory_size
  timeout                = var.lambdas.create_contact.timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:PutItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  log_retention_days = var.lambdas.create_contact.log_retention_days
  tags               = var.tags
}

module "lambda_get" {
  source                 = "./modules/lambda"
  function_name          = "${local.prefix}-get-contact"
  filename               = "./../bin/get-contact.zip"
  memory_size            = var.lambdas.get_contact.memory_size
  timeout                = var.lambdas.get_contact.timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:GetItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  log_retention_days = var.lambdas.get_contact.log_retention_days
  tags               = var.tags
}

# SNS Topic for notifications
module "sns_topic" {
  source      = "./modules/sns"
  topic_name  = "${local.prefix}-contacts"
  country     = var.country
  product     = var.product
  environment = var.environment
  tags        = var.tags

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
  function_name          = "${local.prefix}-dynamodb-trigger"
  filename               = "./../bin/dynamodb-trigger.zip"
  memory_size            = var.lambdas.dynamodb_trigger_lambda.memory_size
  timeout                = var.lambdas.dynamodb_trigger_lambda.timeout
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
  log_retention_days = var.lambdas.dynamodb_trigger_lambda.log_retention_days
  tags               = var.tags
}

# Lambda function for SNS message processing
module "sns_trigger_lambda" {
  source                 = "./modules/lambda"
  function_name          = "${local.prefix}-sns-trigger"
  filename               = "./../bin/sns-trigger.zip"
  memory_size            = var.lambdas.sns_trigger_lambda.memory_size
  timeout                = var.lambdas.sns_trigger_lambda.timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:UpdateItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  log_retention_days = var.lambdas.sns_trigger_lambda.log_retention_days
  tags               = var.tags
}
