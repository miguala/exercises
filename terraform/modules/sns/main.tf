resource "aws_sns_topic" "contacts_topic" {
  name = var.topic_name
}