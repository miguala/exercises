output "stream_arn" {
  value = aws_dynamodb_table.contacts.stream_arn
}

output "table_arn" {
  value = aws_dynamodb_table.contacts.arn
}

output "table_name" {
  value = aws_dynamodb_table.contacts.name
}