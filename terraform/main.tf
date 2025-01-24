module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = var.dynamodb_table_name
}

module "sns" {
  source     = "./modules/sns"
  topic_name = var.sns_topic_name
}

module "iam" {
  source             = "./modules/iam"
  lambda_role_name   = var.lambda_role_name
  dynamodb_table_arn = module.dynamodb.table_arn
  sns_topic_arn      = module.sns.topic_arn
}

module "lambda" {
  source              = "./modules/lambda"
  lambda_role_arn     = module.iam.role_arn
  dynamodb_table_name = module.dynamodb.table_name
  sns_topic_arn       = module.sns.topic_arn
  dynamodb_stream_arn = module.dynamodb.stream_arn
}

# Agregar permisos y configuraciones adicionales
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = module.dynamodb.stream_arn
  function_name     = module.lambda.dynamodb_trigger_function_name
  starting_position = "LATEST"
}

resource "aws_sns_topic_subscription" "sns_trigger_subscription" {
  topic_arn = module.sns.topic_arn
  protocol  = "lambda"
  endpoint  = module.lambda.sns_trigger_arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.sns_trigger_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns.topic_arn
}

module "api_gateway" {
  source                    = "./modules/api_gateway"
  create_contact_lambda_arn = module.lambda.create_contact_arn
  get_contact_lambda_arn    = module.lambda.get_contact_arn
}