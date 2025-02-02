variable "table_name" {
  type = string
}

variable "billing_mode" {
  type = string
  default = "PAY_PER_REQUEST"
}

variable "hash_key" {
    type = string
}

variable "stream_enabled" {
  type    = bool
  default = false
}

variable "stream_view_type" {
  type    = string
  default = "NEW_AND_OLD_IMAGES"
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "lambda_event_sources" {
    type = map(object({
        function_name = string
        starting_position = optional(string)
        enabled = optional(bool)
        batch_size = optional(number)
    }))
    default = {}
    description = "Map of lambda functions that will be subscribed to the dynamoDB stream."
}
variable "replica_region" {
  type        = string
  description = "The region where the DynamoDB table replica will be created."
  default = ""
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key that will be used to encrypt the replica"
  default     = ""
}