# modules/dynamodb/main.tf
resource "aws_dynamodb_table" "table" {
  name             = var.table_name
  billing_mode     = var.billing_mode
  hash_key         = var.hash_key
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  attribute {
    name = var.hash_key
    type = "S"
  }

  tags = var.tags
}

# modules/dynamodb/variables.tf
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the table"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Hash key for the table"
  type        = string
  default     = "id"
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type"
  type        = string
  default     = "NEW_IMAGE"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# modules/dynamodb/outputs.tf
output "table_name" {
  value = aws_dynamodb_table.table.name
}

output "table_arn" {
  value = aws_dynamodb_table.table.arn
}

output "table_stream_arn" {
  value = aws_dynamodb_table.table.stream_arn
}