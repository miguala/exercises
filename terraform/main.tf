# Proveedor AWS
provider "aws" {
  region  = "us-east-1"
  profile = "playground"
}

# Definir un rol de IAM para la función Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  # Permitir que Lambda asuma este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" # Permite que los servicios de AWS asuman este rol
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com" # Lambda puede usar este rol
        }
      }
    ]
  })
}

# Crear una política para acceso a DynamoDB
resource "aws_iam_policy" "dynamodb_access" {
  name = "dynamodb-access-policy"

  # Permite acciones específicas en DynamoDB
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"] # Acciones permitidas
        Resource = aws_dynamodb_table.contacts8a.arn                               # Limita el acceso a una tabla específica
      }
    ]
  })
}

# Adjuntar la política de acceso a DynamoDB al rol Lambda
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name      # Rol Lambda
  policy_arn = aws_iam_policy.dynamodb_access.arn # Política DynamoDB
}

# Adjuntar la política básica de ejecución de Lambda para CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Crear la tabla DynamoDB
resource "aws_dynamodb_table" "contacts8a" {
  name         = "Contacts8a"      # Nombre de la tabla
  billing_mode = "PAY_PER_REQUEST" # Modo de facturación por solicitud
  hash_key     = "id"              # Llave primaria de la tabla

  # Definir el esquema de atributos
  attribute {
    name = "id" # Nombre del atributo (llave primaria)
    type = "S"  # Tipo de dato (string)
  }
}

# Crear un recurso API Gateway
resource "aws_api_gateway_rest_api" "api8a" {
  name = "ContactsAPI8a" # Nombre de la API
}

# Crear un recurso "contacts8a" en API Gateway
resource "aws_api_gateway_resource" "contacts8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id               # ID de la API Gateway
  parent_id   = aws_api_gateway_rest_api.api8a.root_resource_id # Raíz de la API
  path_part   = "contacts8a"                                    # Parte de la ruta
}

# Crear un recurso para contactos individuales
resource "aws_api_gateway_resource" "contact_id8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id
  parent_id   = aws_api_gateway_resource.contacts8a.id # Recurso "contacts8a" como padre
  path_part   = "{id}"                                 # Identificador dinámico en la ruta
}

# Definir la función Lambda para crear contactos
resource "aws_lambda_function" "create_contact8a" {
  filename      = "../lambdas/create-contact/create-contact.zip" # Ruta al paquete ZIP del código Lambda
  function_name = "create-contact8a-go"                          # Nombre de la función
  role          = aws_iam_role.lambda_role.arn                   # Rol asignado a la función
  runtime       = "provided.al2"                                 # Tiempo de ejecución personalizado (Go en este caso)
  architectures = ["arm64"]                                      # Arquitectura de la función
  handler       = "bootstrap"                                    # Punto de entrada del código
  publish       = true                                           # Publicar una nueva versión
}

# Definir la función Lambda para obtener contactos
resource "aws_lambda_function" "get_contact8a" {
  filename      = "../lambdas/get-contact/get-contact.zip" # Ruta al paquete ZIP
  function_name = "get-contact8a-go"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  architectures = ["arm64"]
  handler       = "bootstrap"
  publish       = true
}

# Permitir que API Gateway invoque la función Lambda (POST /contacts8a)
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway" # Identificador único para la política
  action        = "lambda:InvokeFunction"        # Permitir invocar la función Lambda
  function_name = aws_lambda_function.create_contact8a.function_name
  principal     = "apigateway.amazonaws.com"                              # API Gateway como principal
  source_arn    = "${aws_api_gateway_rest_api.api8a.execution_arn}/*/*/*" # Limitar a esta API Gateway

  depends_on = [aws_lambda_function.create_contact8a] # Garantizar que Lambda se cree primero
}

# Permitir que API Gateway invoque la función Lambda (GET /contacts8a/{id})
resource "aws_lambda_permission" "api_gateway_get" {
  statement_id  = "AllowExecutionFromAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_contact8a.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api8a.execution_arn}/*/*/*"

  depends_on = [aws_lambda_function.get_contact8a]
}

# Definir el método POST en API Gateway (/contacts8a)
resource "aws_api_gateway_method" "post_contact8a" {
  rest_api_id   = aws_api_gateway_rest_api.api8a.id
  resource_id   = aws_api_gateway_resource.contacts8a.id
  http_method   = "POST" # Método HTTP
  authorization = "NONE" # Sin autorización
}

# Integrar Lambda con API Gateway (POST /contacts8a)
resource "aws_api_gateway_integration" "post_contact8a" {
  rest_api_id             = aws_api_gateway_rest_api.api8a.id
  resource_id             = aws_api_gateway_resource.contacts8a.id
  http_method             = aws_api_gateway_method.post_contact8a.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # Proxy para enviar directamente a Lambda
  uri                     = aws_lambda_function.create_contact8a.invoke_arn
}

# Definir el método GET en API Gateway (/contacts8a/{id})
resource "aws_api_gateway_method" "get_contact8a" {
  rest_api_id   = aws_api_gateway_rest_api.api8a.id
  resource_id   = aws_api_gateway_resource.contact_id8a.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrar Lambda con API Gateway (GET /contacts8a/{id})
resource "aws_api_gateway_integration" "get_contact8a" {
  rest_api_id             = aws_api_gateway_rest_api.api8a.id
  resource_id             = aws_api_gateway_resource.contact_id8a.id
  http_method             = aws_api_gateway_method.get_contact8a.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_contact8a.invoke_arn
}

# Desplegar la API Gateway
resource "aws_api_gateway_deployment" "deployment8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id
  depends_on  = [aws_api_gateway_integration.post_contact8a, aws_api_gateway_integration.get_contact8a]
}

# Crear un "stage" para la API Gateway
resource "aws_api_gateway_stage" "prod8a" {
  stage_name    = "prod8a" # Nombre del stage
  rest_api_id   = aws_api_gateway_rest_api.api8a.id
  deployment_id = aws_api_gateway_deployment.deployment8a.id
}

# Outputs para mostrar información útil
output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.deployment8a.invoke_url}/${aws_api_gateway_stage.prod8a.stage_name}"
}

output "lambda_function_names" {
  value = [
    aws_lambda_function.create_contact8a.function_name,
    aws_lambda_function.get_contact8a.function_name
  ]
}
