# environments/dev/lambda/terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/lambda.hcl"
}

# Dependencies
dependency "dynamodb" {
  config_path = "../dynamodb"
}

dependency "sns" {
  config_path = "../sns"
}

locals {
  lambda_functions = {
    create_contact = {
      filename               = "${get_terragrunt_dir()}/../../../bin/create-contact.zip"
      enable_dynamodb_access = true
      dynamodb_actions       = ["dynamodb:PutItem"]
      environment_variables = {
        TABLE_NAME = dependency.dynamodb.outputs.table_name
      }
      dynamodb_table_arn = dependency.dynamodb.outputs.table_arn
    }

    get_contact = {
      filename               = "${get_terragrunt_dir()}/../../../bin/get-contact.zip"
      enable_dynamodb_access = true
      dynamodb_actions       = ["dynamodb:GetItem"]
      environment_variables = {
        TABLE_NAME = dependency.dynamodb.outputs.table_name
      }
      dynamodb_table_arn = dependency.dynamodb.outputs.table_arn
    }

    dynamodb_trigger = {
      filename               = "${get_terragrunt_dir()}/../../../bin/dynamodb-trigger.zip"
      enable_dynamodb_access = true
      dynamodb_actions = [
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeStream",
        "dynamodb:ListStreams"
      ]
      dynamodb_table_arn = dependency.dynamodb.outputs.table_stream_arn
      enable_sns_access  = true
      sns_topic_arn      = dependency.sns.outputs.topic_arn
      environment_variables = {
        SNS_TOPIC_ARN = dependency.sns.outputs.topic_arn
      }
    }

    sns_trigger = {
      filename               = "${get_terragrunt_dir()}/../../../bin/sns-trigger.zip"
      enable_dynamodb_access = true
      dynamodb_actions       = ["dynamodb:UpdateItem"]
      dynamodb_table_arn     = dependency.dynamodb.outputs.table_arn
      environment_variables = {
        TABLE_NAME = dependency.dynamodb.outputs.table_name
      }
    }
  }
}

inputs = {
  # Common configurations from _envcommon/lambda.hcl
  memory_size       = 128
  timeout          = 30
  log_retention_days = 14

  # Generate all Lambda functions
  for_each = local.lambda_functions

  functions = {
    for name, config in local.lambda_functions : name => merge(
      {
        function_name = "${local.country}-${local.product}-${local.environment}-${name}"
      },
      config
    )
  }
}

# Generate outputs for all Lambda functions
generate = {
  path      = "outputs.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    output "function_names" {
      value = {
        for name, func in module.lambda : name => func.function_name
      }
    }

    output "function_arns" {
      value = {
        for name, func in module.lambda : name => func.function_arn
      }
    }
  EOF
}