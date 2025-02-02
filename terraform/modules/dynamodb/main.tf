# modules/dynamodb/main.tf

resource "aws_dynamodb_table" "this" {
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

  dynamic "replica" {
    for_each = var.replica_region != "" ? [1] : []
    content {
      region_name = var.replica_region
      kms_key_arn = var.kms_key_arn
    }
  }
}


resource "aws_lambda_event_source_mapping" "dynamodb_trigger_mapping" {
  for_each = var.lambda_event_sources

  event_source_arn  = aws_dynamodb_table.this.stream_arn
  function_name     = each.value.function_name
  starting_position = lookup(each.value, "starting_position", "LATEST")
  enabled           = lookup(each.value, "enabled", true)
  batch_size        = lookup(each.value, "batch_size", 10)
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_stream_arn" {
  value = aws_dynamodb_table.this.stream_arn
}