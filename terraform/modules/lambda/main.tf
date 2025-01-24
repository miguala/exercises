resource "aws_lambda_function" "create_contact" {
  filename      = "../lambdas/create-contact/create-contact.zip"
  function_name = "create-contact8a-go"
  role          = var.lambda_role_arn
  handler       = "bootstrap"
  runtime       = "provided.al2"
  architectures = ["arm64"]
  publish       = true

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_function" "get_contact" {
  filename      = "../lambdas/get-contact/get-contact.zip"
  function_name = "get-contact8a-go"
  role          = var.lambda_role_arn
  handler       = "bootstrap"
  runtime       = "provided.al2"
  architectures = ["arm64"]
  publish       = true

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_function" "dynamodb_trigger" {
  filename      = "../lambdas/dynamodb-trigger/dynamodb-trigger.zip"
  function_name = "dynamodb8a-trigger"
  role          = var.lambda_role_arn
  handler       = "bootstrap"
  runtime       = "provided.al2"
  architectures = ["arm64"]
  publish       = true

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

resource "aws_lambda_function" "sns_trigger" {
  filename      = "../lambdas/sns-trigger/sns-trigger.zip"
  function_name = "sns8a-trigger"
  role          = var.lambda_role_arn
  handler       = "bootstrap"
  runtime       = "provided.al2"
  architectures = ["arm64"]
  publish       = true
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = {
    create_contact  = aws_lambda_function.create_contact.function_name
    get_contact     = aws_lambda_function.get_contact.function_name
    dynamodb_trigger = aws_lambda_function.dynamodb_trigger.function_name
    sns_trigger     = aws_lambda_function.sns_trigger.function_name
  }

  name              = "/aws/lambda/${each.value}"
  retention_in_days = 7
}