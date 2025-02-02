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