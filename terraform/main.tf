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

locals {
  common_tags = {
    Product   = var.product
    Environment = var.environment
    Terraform = "true"
  }
}

# Módulo DynamoDB
module "contacts_table" {
  source         = "./modules/dynamodb"
  table_name     = "contacts"
  country        = var.country
  product        = var.product
  environment    = var.environment
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  stream_enabled = true
  stream_view_type = var.stream_view_type
  tags           = local.common_tags
}

# Módulo de API Gateway (Migrado)
module "main_api" {
  source                      = "./modules/api-gateway"
  api_name                    = "contacts"
  country                     = var.country
  product                     = var.product
  environment                 = var.environment
  create_contact_lambda_arn   = module.create_contact_lambda.function_arn
  create_contact_lambda_name  = module.create_contact_lambda.function_name
  get_contact_lambda_arn      = module.get_contact_lambda.function_arn
  get_contact_lambda_name     = module.get_contact_lambda.function_name
  log_retention_days          = var.log_retention_days
  tags                        = local.common_tags
}

# Módulo SNS
module "sns_topic" {
  source      = "./modules/sns"
  topic_name  = "contacts"
  country     = var.country
  product     = var.product
  environment = var.environment
  tags        = local.common_tags
}

# Módulo Cognito
module "cognito" {
  source         = "./modules/cognito"
  user_pool_name = "${var.country}-${var.product}-${var.environment}-user-pool"
  client_name    = "${var.country}-${var.product}-${var.environment}-client"
  api_gateway_id = module.main_api.api_id
  region         = var.region
  tags           = local.common_tags
  environment    = var.environment
}

# Módulo Lambda (Create Contact)
module "create_contact_lambda" {
  source                   = "./modules/lambda"
  function_name            = "create-contact"
  country                  = var.country
  product                  = var.product
  environment              = var.environment
  filename                 = "./../bin/create-contact.zip"
  memory_size              = var.lambda_memory_size
  timeout                  = var.lambda_timeout
  enable_dynamodb_access   = true
  dynamodb_actions         = ["dynamodb:PutItem"]
  dynamodb_table_arn       = module.contacts_table.table_arn
  environment_variables    = {
    TABLE_NAME = module.contacts_table.table_name
  }
  tags = local.common_tags
}

# Módulo Lambda (DynamoDB Trigger)
module "dynamodb_trigger_lambda" {
  source                   = "./modules/lambda"
  function_name            = "dynamodb-trigger"
  country                  = var.country
  product                  = var.product
  environment              = var.environment
  filename                 = "./../bin/dynamodb-trigger.zip"
  memory_size              = var.lambda_memory_size
  timeout                  = var.lambda_timeout
  enable_dynamodb_access   = true
  dynamodb_actions         = [
    "dynamodb:GetRecords",
    "dynamodb:GetShardIterator",
    "dynamodb:DescribeStream",
    "dynamodb:ListStreams"
  ]
  dynamodb_table_arn       = module.contacts_table.table_stream_arn
  enable_sns_access        = true
  sns_topic_arn            = module.sns_topic.topic_arn
  environment_variables    = {
    TABLE_NAME    = module.contacts_table.table_name
    SNS_TOPIC_ARN = module.sns_topic.topic_arn
  }
  tags = local.common_tags
}

# Módulo Lambda (Get Contact)
module "get_contact_lambda" {
  source                   = "./modules/lambda"
  function_name            = "get-contact"
  country                  = var.country
  product                  = var.product
  environment              = var.environment
  filename                 = "./../bin/get-contact.zip"
  memory_size              = var.lambda_memory_size
  timeout                  = var.lambda_timeout
  enable_dynamodb_access   = true
  dynamodb_actions         = ["dynamodb:GetItem"]
  dynamodb_table_arn       = module.contacts_table.table_arn
  environment_variables    = {
    TABLE_NAME = module.contacts_table.table_name
  }
  tags = local.common_tags
}

# Módulo Lambda (SNS Trigger)
module "sns_trigger_lambda" {
  source                   = "./modules/lambda"
  function_name            = "sns-trigger"
  country                  = var.country
  product                  = var.product
  environment              = var.environment
  filename                 = "./../bin/sns-trigger.zip"
  memory_size              = var.lambda_memory_size
  timeout                  = var.lambda_timeout
  enable_dynamodb_access   = true
  dynamodb_actions         = ["dynamodb:UpdateItem"]
  dynamodb_table_arn       = module.contacts_table.table_arn
  environment_variables    = {
    TABLE_NAME = module.contacts_table.table_name
  }
  tags = local.common_tags
}


resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn = module.contacts_table.table_stream_arn
  function_name    = module.dynamodb_trigger_lambda.function_arn
  starting_position = "LATEST"
}

resource "aws_sns_topic_subscription" "sns_trigger_sub" {
  topic_arn = module.sns_topic.topic_arn
  protocol  = "lambda"
  endpoint  = module.sns_trigger_lambda.function_arn
}

resource "aws_lambda_permission" "sns_trigger" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.sns_trigger_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_topic.topic_arn
}
