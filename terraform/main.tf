provider "aws" {
  region = "us-east-1"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# IAM Policy for DynamoDB Access
resource "aws_iam_policy" "dynamodb_access" {
  name = "dynamodb-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Resource = [
          aws_dynamodb_table.contacts.arn,
          "${aws_dynamodb_table.contacts.arn}/stream/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.contacts_topic.arn
      }
    ]
  })
}

# Attach IAM Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# CloudWatch Log Groups for Lambda Functions
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = toset([
    aws_lambda_function.create_contact.function_name,
    aws_lambda_function.get_contact.function_name,
    aws_lambda_function.dynamodb_trigger.function_name,
    aws_lambda_function.sns_trigger.function_name
  ])

  name              = "/aws/lambda/${each.key}"
  retention_in_days = 7
}

# DynamoDB Table
resource "aws_dynamodb_table" "contacts" {
  name         = "Contacts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}

# SNS Topic
resource "aws_sns_topic" "contacts_topic" {
  name = "ContactsTopic"
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "ContactsAPI"
}

resource "aws_api_gateway_resource" "contacts" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "contacts"
}

resource "aws_api_gateway_resource" "contact_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.contacts.id
  path_part   = "{id}"
}

# Lambda Functions
resource "aws_lambda_function" "create_contact" {
  filename      = "../bin/create-contact.zip"
  function_name = "create-contact"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contacts.name
    }
  }
}

resource "aws_lambda_function" "get_contact" {
  filename      = "../bint-contact.zip"
  function_name = "get-contact"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contacts.name
    }
  }
}

resource "aws_lambda_function" "dynamodb_trigger" {
  filename      = "../biner/dynamodb-trigger.zip"
  function_name = "dynamodb-trigger"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.contacts_topic.arn
    }
  }
}

resource "aws_lambda_function" "sns_trigger" {
  filename      = "../bins-trigger.zip"
  function_name = "sns-trigger"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true
}

# Lambda Permissions
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_contact.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "api_gateway_get" {
  statement_id  = "AllowExecutionFromAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_contact.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_trigger.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.contacts_topic.arn
}

# API Gateway Methods and Integrations
resource "aws_api_gateway_method" "post_contact" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_contact" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.contacts.id
  http_method             = aws_api_gateway_method.post_contact.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_contact.invoke_arn
}

resource "aws_api_gateway_method" "get_contact" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.contact_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_contact" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.contact_id.id
  http_method             = aws_api_gateway_method.get_contact.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_contact.invoke_arn
}

# DynamoDB Stream to Lambda Trigger
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.contacts.stream_arn
  function_name     = aws_lambda_function.dynamodb_trigger.function_name
  starting_position = "LATEST"
}

# SNS Subscription to Lambda
resource "aws_sns_topic_subscription" "sns_trigger_subscription" {
  topic_arn = aws_sns_topic.contacts_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_trigger.arn
}

# API Gateway Deployment and Stage
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on = [
    aws_api_gateway_integration.post_contact,
    aws_api_gateway_integration.get_contact
  ]
}

resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

# Outputs
output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}/${aws_api_gateway_stage.dev.stage_name}"
}

output "lambda_function_names" {
  value = [
    aws_lambda_function.create_contact.function_name,
    aws_lambda_function.get_contact.function_name,
    aws_lambda_function.dynamodb_trigger.function_name,
    aws_lambda_function.sns_trigger.function_name
  ]
}