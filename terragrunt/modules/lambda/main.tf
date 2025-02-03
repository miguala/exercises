# modules/lambda/main.tf
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = "provided.al2"
  handler       = "bootstrap"
  architectures = ["arm64"]
  filename      = var.filename
  memory_size   = var.memory_size
  timeout       = var.timeout
  role          = aws_iam_role.role.arn

  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "cloudwatch_log" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_iam_role" "role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_logs" {
  role = aws_iam_role.role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Permisos adicionales para DynamoDB y SNS (si están habilitados)
resource "aws_iam_role_policy" "dynamodb_access" {
  count = var.enable_dynamodb_access ? 1 : 0

  role = aws_iam_role.role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = var.dynamodb_actions
        Effect   = "Allow"
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "sns_access" {
  count = var.enable_sns_access ? 1 : 0

  role = aws_iam_role.role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sns:Publish"]
        Effect   = "Allow"
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# modules/lambda/outputs.tf
output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "function_arn" {
  value = aws_lambda_function.this.arn
}

output "role_arn" {
  value = aws_iam_role.role.arn
}