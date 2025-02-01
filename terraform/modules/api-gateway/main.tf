resource "aws_apigatewayv2_api" "this" {
  name          = "${var.country}-${var.product}-${var.environment}-${var.api_name}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_enabled ? var.cors_configuration.allow_origins : []
    allow_methods = var.cors_enabled ? var.cors_configuration.allow_methods : []
    allow_headers = var.cors_enabled ? var.cors_configuration.allow_headers : []
    max_age      = var.cors_enabled ? var.cors_configuration.max_age : null
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.this.name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      ip                     = "$context.identity.sourceIp"
      requestTime            = "$context.requestTime"
      httpMethod             = "$context.httpMethod"
      routeKey              = "$context.routeKey"
      status                 = "$context.status"
      protocol              = "$context.protocol"
      responseLength        = "$context.responseLength"
      integrationError      = "$context.integrationErrorMessage"
    })
  }

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  for_each = var.routes

  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.lambda_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 29000
}

resource "aws_apigatewayv2_route" "route" {
  for_each = var.routes

  api_id             = aws_apigatewayv2_api.this.id
  route_key         = "${each.value.method} ${each.value.path}"
  target            = "integrations/${aws_apigatewayv2_integration.lambda_integration[each.key].id}"
  authorization_type = each.value.authorization
  authorizer_id     = each.value.authorization != "NONE" ? each.value.authorizer_id : null
}

resource "aws_lambda_permission" "lambda_permission" {
  for_each = var.routes

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}