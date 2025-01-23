# Configuración del proveedor AWS
provider "aws" {
  region = "us-east-1" # Región de AWS donde se desplegarán los recursos
}

# Definir un rol de IAM para la función Lambda
resource "aws_iam_role" "lambda_role" {
  name = "8a-lambda-execution-role" # Nombre del rol con prefijo "8a"

  # Política que permite a Lambda asumir este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" } # Servicio Lambda como principal
    }]
  })
}

# Crear una política para acceso a DynamoDB y SNS
resource "aws_iam_policy" "dynamodb_access" {
  name = "8a-dynamodb-access-policy" # Nombre de la política con prefijo "8a"

  # Definición de la política
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",          # Permite insertar elementos en DynamoDB
          "dynamodb:GetItem",          # Permite obtener elementos de DynamoDB
          "dynamodb:UpdateItem",       # Permite actualizar elementos en DynamoDB
          "dynamodb:DescribeStream",   # Permite describir el stream de DynamoDB
          "dynamodb:GetRecords",       # Permite obtener registros del stream
          "dynamodb:GetShardIterator", # Permite obtener un iterador de shard
          "dynamodb:ListStreams"       # Permite listar los streams de DynamoDB
        ]
        Resource = [
          aws_dynamodb_table.contacts8a.arn,              # ARN de la tabla DynamoDB
          "${aws_dynamodb_table.contacts8a.arn}/stream/*" # ARN del stream de DynamoDB
        ]
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"                      # Permite publicar en un tema SNS
        Resource = aws_sns_topic.contacts8a_topic.arn # ARN del tema SNS
      }
    ]
  })
}

# Adjuntar la política al rol Lambda
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name      # Nombre del rol Lambda
  policy_arn = aws_iam_policy.dynamodb_access.arn # ARN de la política
}

# Crear grupos de logs en CloudWatch para las funciones Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = toset([
    aws_lambda_function.create_contact8a.function_name,   # Logs para create_contact8a
    aws_lambda_function.get_contact8a.function_name,      # Logs para get_contact8a
    aws_lambda_function.dynamodb8a_trigger.function_name, # Logs para dynamodb8a_trigger
    aws_lambda_function.sns8a_trigger.function_name       # Logs para sns8a_trigger
  ])

  name              = "/aws/lambda/${each.key}" # Nombre del grupo de logs
  retention_in_days = 7                         # Retención de logs por 7 días
}

# Crear la tabla DynamoDB para almacenar contactos
resource "aws_dynamodb_table" "contacts8a" {
  name         = "Contacts8a"      # Nombre de la tabla con prefijo "8a"
  billing_mode = "PAY_PER_REQUEST" # Modo de facturación bajo demanda
  hash_key     = "id"              # Clave primaria de la tabla

  attribute {
    name = "id" # Nombre del atributo clave
    type = "S"  # Tipo de dato: String
  }

  stream_enabled   = true        # Habilitar stream de DynamoDB
  stream_view_type = "NEW_IMAGE" # Capturar la nueva imagen del registro
}

# Crear un tema SNS para notificaciones
resource "aws_sns_topic" "contacts8a_topic" {
  name = "Contacts8aTopic" # Nombre del tema SNS con prefijo "8a"
}

# Crear API Gateway para exponer la API
resource "aws_api_gateway_rest_api" "api8a" {
  name = "ContactsAPI8a" # Nombre de la API con prefijo "8a"
}

# Crear recursos en API Gateway
resource "aws_api_gateway_resource" "contacts8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id               # ID de la API
  parent_id   = aws_api_gateway_rest_api.api8a.root_resource_id # Recurso raíz
  path_part   = "contacts8a"                                    # Ruta del recurso
}

resource "aws_api_gateway_resource" "contact_id8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id      # ID de la API
  parent_id   = aws_api_gateway_resource.contacts8a.id # Recurso padre
  path_part   = "{id}"                                 # Ruta con parámetro dinámico "id"
}

# Crear funciones Lambda
resource "aws_lambda_function" "create_contact8a" {
  filename      = "../lambdas/create-contact/create-contact.zip" # Archivo ZIP de la función
  function_name = "create-contact8a-go"                          # Nombre de la función con prefijo "8a"
  role          = aws_iam_role.lambda_role.arn                   # Rol asociado a la función
  runtime       = "provided.al2"                                 # Entorno de ejecución (Go)
  architectures = ["arm64"]                                      # Arquitectura ARM64
  handler       = "bootstrap"                                    # Punto de entrada de la función
  publish       = true                                           # Publicar una nueva versión

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contacts8a.name # Variable de entorno con el nombre de la tabla
    }
  }
}

resource "aws_lambda_function" "get_contact8a" {
  filename      = "../lambdas/get-contact/get-contact.zip" # Archivo ZIP de la función
  function_name = "get-contact8a-go"                       # Nombre de la función con prefijo "8a"
  role          = aws_iam_role.lambda_role.arn             # Rol asociado a la función
  runtime       = "provided.al2"                           # Entorno de ejecución (Go)
  architectures = ["arm64"]                                # Arquitectura ARM64
  handler       = "bootstrap"                              # Punto de entrada de la función
  publish       = true                                     # Publicar una nueva versión

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contacts8a.name # Variable de entorno con el nombre de la tabla
    }
  }
}

resource "aws_lambda_function" "dynamodb8a_trigger" {
  filename      = "../lambdas/dynamodb-trigger/dynamodb-trigger.zip" # Archivo ZIP de la función
  function_name = "dynamodb8a-trigger"                               # Nombre de la función con prefijo "8a"
  role          = aws_iam_role.lambda_role.arn                       # Rol asociado a la función
  runtime       = "provided.al2"                                     # Entorno de ejecución (Go)
  architectures = ["arm64"]                                          # Arquitectura ARM64
  handler       = "bootstrap"                                        # Punto de entrada de la función
  publish       = true                                               # Publicar una nueva versión

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.contacts8a_topic.arn # Variable de entorno con el ARN del tema SNS
    }
  }
}

resource "aws_lambda_function" "sns8a_trigger" {
  filename      = "../lambdas/sns-trigger/sns-trigger.zip" # Archivo ZIP de la función
  function_name = "sns8a-trigger"                          # Nombre de la función con prefijo "8a"
  role          = aws_iam_role.lambda_role.arn             # Rol asociado a la función
  runtime       = "provided.al2"                           # Entorno de ejecución (Go)
  architectures = ["arm64"]                                # Arquitectura ARM64
  handler       = "bootstrap"                              # Punto de entrada de la función
  publish       = true                                     # Publicar una nueva versión
}

# Permisos para API Gateway invocar Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"                          # Identificador único del permiso
  action        = "lambda:InvokeFunction"                                 # Acción permitida
  function_name = aws_lambda_function.create_contact8a.function_name      # Nombre de la función Lambda
  principal     = "apigateway.amazonaws.com"                              # Servicio que puede invocar la función
  source_arn    = "${aws_api_gateway_rest_api.api8a.execution_arn}/*/*/*" # ARN de la API Gateway
}

resource "aws_lambda_permission" "api_gateway_get" {
  statement_id  = "AllowExecutionFromAPIGatewayGet"                       # Identificador único del permiso
  action        = "lambda:InvokeFunction"                                 # Acción permitida
  function_name = aws_lambda_function.get_contact8a.function_name         # Nombre de la función Lambda
  principal     = "apigateway.amazonaws.com"                              # Servicio que puede invocar la función
  source_arn    = "${aws_api_gateway_rest_api.api8a.execution_arn}/*/*/*" # ARN de la API Gateway
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"                         # Identificador único del permiso
  action        = "lambda:InvokeFunction"                         # Acción permitida
  function_name = aws_lambda_function.sns8a_trigger.function_name # Nombre de la función Lambda
  principal     = "sns.amazonaws.com"                             # Servicio que puede invocar la función
  source_arn    = aws_sns_topic.contacts8a_topic.arn              # ARN del tema SNS
}

# Métodos e integraciones de API Gateway
resource "aws_api_gateway_method" "post_contact8a" {
  rest_api_id   = aws_api_gateway_rest_api.api8a.id      # ID de la API
  resource_id   = aws_api_gateway_resource.contacts8a.id # ID del recurso
  http_method   = "POST"                                 # Método HTTP
  authorization = "NONE"                                 # Sin autorización
}

resource "aws_api_gateway_integration" "post_contact8a" {
  rest_api_id             = aws_api_gateway_rest_api.api8a.id                 # ID de la API
  resource_id             = aws_api_gateway_resource.contacts8a.id            # ID del recurso
  http_method             = aws_api_gateway_method.post_contact8a.http_method # Método HTTP
  integration_http_method = "POST"                                            # Método HTTP para la integración
  type                    = "AWS_PROXY"                                       # Tipo de integración (Lambda)
  uri                     = aws_lambda_function.create_contact8a.invoke_arn   # ARN de la función Lambda
}

resource "aws_api_gateway_method" "get_contact8a" {
  rest_api_id   = aws_api_gateway_rest_api.api8a.id        # ID de la API
  resource_id   = aws_api_gateway_resource.contact_id8a.id # ID del recurso
  http_method   = "GET"                                    # Método HTTP
  authorization = "NONE"                                   # Sin autorización
}

resource "aws_api_gateway_integration" "get_contact8a" {
  rest_api_id             = aws_api_gateway_rest_api.api8a.id                # ID de la API
  resource_id             = aws_api_gateway_resource.contact_id8a.id         # ID del recurso
  http_method             = aws_api_gateway_method.get_contact8a.http_method # Método HTTP
  integration_http_method = "POST"                                           # Método HTTP para la integración
  type                    = "AWS_PROXY"                                      # Tipo de integración (Lambda)
  uri                     = aws_lambda_function.get_contact8a.invoke_arn     # ARN de la función Lambda
}

# Mapeo de eventos de DynamoDB Stream a Lambda
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.contacts8a.stream_arn             # ARN del stream de DynamoDB
  function_name     = aws_lambda_function.dynamodb8a_trigger.function_name # Nombre de la función Lambda
  starting_position = "LATEST"                                             # Comenzar a procesar desde el último evento
}

# Suscripción de SNS a Lambda
resource "aws_sns_topic_subscription" "sns_trigger_subscription" {
  topic_arn = aws_sns_topic.contacts8a_topic.arn    # ARN del tema SNS
  protocol  = "lambda"                              # Protocolo de suscripción (Lambda)
  endpoint  = aws_lambda_function.sns8a_trigger.arn # ARN de la función Lambda
}

# Despliegue de API Gateway
resource "aws_api_gateway_deployment" "deployment8a" {
  rest_api_id = aws_api_gateway_rest_api.api8a.id # ID de la API
  depends_on = [
    aws_api_gateway_integration.post_contact8a,
    aws_api_gateway_integration.get_contact8a
  ]
}

resource "aws_api_gateway_stage" "prod8a" {
  stage_name    = "prod8a"                                   # Nombre de la etapa
  rest_api_id   = aws_api_gateway_rest_api.api8a.id          # ID de la API
  deployment_id = aws_api_gateway_deployment.deployment8a.id # ID del despliegue
}

# Outputs
output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.deployment8a.invoke_url}/${aws_api_gateway_stage.prod8a.stage_name}" # URL de la API Gateway
}

output "lambda_function_names" {
  value = [
    aws_lambda_function.create_contact8a.function_name,
    aws_lambda_function.get_contact8a.function_name,
    aws_lambda_function.dynamodb8a_trigger.function_name,
    aws_lambda_function.sns8a_trigger.function_name
  ] # Nombres de las funciones Lambda
}