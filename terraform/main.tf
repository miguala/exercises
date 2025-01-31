
provider "aws" {
  region = "us-east-1"
}


resource "aws_iam_role" "lambda_role" {
  name = "8a-lambda-execution-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}


resource "aws_iam_policy" "dynamodb_access" {
  name = "8a-dynamodb-access-policy"


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
          aws_dynamodb_table.contacts8a.arn,
          "${aws_dynamodb_table.contacts8a.arn}/stream/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.contacts8a_topic.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}


resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = toset([
    aws_lambda_function.create_contact8a.function_name,
    aws_lambda_function.get_contact8a.function_name,
    aws_lambda_function.dynamodb8a_trigger.function_name,
    aws_lambda_function.sns8a_trigger.function_name
  ])

  name              = "/aws/lambda/${each.key}"
  retention_in_days = 7
}


resource "aws_dynamodb_table" "contacts8a" {
  name         = "Contacts8a"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}


resource "aws_sns_topic" "contacts8a_topic" {
  name = "Contacts8aTopic"
}


resource "aws_api_gateway_rest_api" "api8a" {
  name = "ContactsAPI8a"
}


resource "aws_api_gateway_resource" "contacts8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id
  parent_id   = aws_api_gateway_rest_api.api8a.root_resource_id
  path_part   = "contacts8a"
}

resource "aws_api_gateway_resource" "contact_id8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id
  parent_id   = aws_api_gateway_resource.contacts8a.id
  path_part   = "{id}"
}


resource "aws_lambda_function" "create_contact8a" {
  filename      = "../lambdas/create-contact/create-contact.zip"
  function_name = "create-contact8a-go"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contacts8a.name
    }
  }
}

resource "aws_lambda_function" "get_contact8a" {
  filename      = "../lambdas/get-contact/get-contact.zip"
  function_name = "get-contact8a-go"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contacts8a.name
    }
  }
}

resource "aws_lambda_function" "dynamodb8a_trigger" {
  filename      = "../lambdas/dynamodb-trigger/dynamodb-trigger.zip"
  function_name = "dynamodb8a-trigger"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.contacts8a_topic.arn
    }
  }
}

resource "aws_lambda_function" "sns8a_trigger" {
  filename      = "../lambdas/sns-trigger/sns-trigger.zip"
  function_name = "sns8a-trigger"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true
}


resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_contact8a.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api8a.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "api_gateway_get" {
  statement_id  = "AllowExecutionFromAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_contact8a.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api8a.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns8a_trigger.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.contacts8a_topic.arn
}


resource "aws_api_gateway_method" "post_contact8a" {
  rest_api_id   = aws_api_gateway_rest_api.api8a.id
  resource_id   = aws_api_gateway_resource.contacts8a.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_contact8a" {
  rest_api_id             = aws_api_gateway_rest_api.api8a.id
  resource_id             = aws_api_gateway_resource.contacts8a.id
  http_method             = aws_api_gateway_method.post_contact8a.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_contact8a.invoke_arn
}

resource "aws_api_gateway_method" "get_contact8a" {
  rest_api_id   = aws_api_gateway_rest_api.api8a.id
  resource_id   = aws_api_gateway_resource.contact_id8a.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_contact8a" {
  rest_api_id             = aws_api_gateway_rest_api.api8a.id
  resource_id             = aws_api_gateway_resource.contact_id8a.id
  http_method             = aws_api_gateway_method.get_contact8a.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_contact8a.invoke_arn
}


resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.contacts8a.stream_arn
  function_name     = aws_lambda_function.dynamodb8a_trigger.function_name
  starting_position = "LATEST"
}


resource "aws_sns_topic_subscription" "sns_trigger_subscription" {
  topic_arn = aws_sns_topic.contacts8a_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns8a_trigger.arn
}


resource "aws_api_gateway_deployment" "deployment8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id
  depends_on = [
    aws_api_gateway_integration.post_contact8a,
    aws_api_gateway_integration.get_contact8a
  ]
}

resource "aws_api_gateway_stage" "prod8a" {
  stage_name    = "prod8a"
  rest_api_id   = aws_api_gateway_rest_api.api8a.id
  deployment_id = aws_api_gateway_deployment.deployment8a.id
}


output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.deployment8a.invoke_url}/${aws_api_gateway_stage.prod8a.stage_name}"
}

output "lambda_function_names" {
  value = [
    aws_lambda_function.create_contact8a.function_name,
    aws_lambda_function.get_contact8a.function_name,
    aws_lambda_function.dynamodb8a_trigger.function_name,
    aws_lambda_function.sns8a_trigger.function_name
  ]
}