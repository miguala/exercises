terraform {
  source = "${get_parent_terragrunt_dir()}/modules//dynamodb"
}

inputs = {
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "id"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}