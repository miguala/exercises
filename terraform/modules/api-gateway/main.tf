# modules/api-gateway/main.tf
resource "aws_apigatewayv2_api" "api" {
  name          = var.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_enabled ? ["*"] : []
    allow_methods = var.cors_enabled ? ["GET", "POST", "PUT", "DELETE"] : []
    allow_headers = var.cors_enabled ? ["*"] : []
  }

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId       = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      path            = "$context.path"
      status          = "$context.status"
      responseLatency = "$context.responseLatency"
    })
  }
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/api-gateway/${var.api_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  for_each = var.routes

  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.lambda_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "route" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.api.id
  route_key = "${each.value.method} ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration[each.key].id}"

  authorization_type = lookup(each.value, "authorization", "NONE")
  authorizer_id      = lookup(each.value, "authorizer_id", null)
}

resource "aws_lambda_permission" "lambda_permission" {
  for_each = var.routes

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# modules/api-gateway/variables.tf
variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "cors_enabled" {
  description = "Enable CORS"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 7
}

variable "routes" {
  description = "Map of API routes and their configurations"
  type = map(object({
    method        = string
    path          = string
    lambda_arn    = string
    lambda_name   = string
    authorization = optional(string)
    authorizer_id = optional(string)
  }))
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# modules/api-gateway/outputs.tf
output "api_id" {
  value = aws_apigatewayv2_api.api.id
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "api_execution_arn" {
  value = aws_apigatewayv2_api.api.execution_arn
}