variable "cloudwatch_filter_pattern" {
  type        = string
  description = "A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events."
  default     = ""
}

variable "cloudwatch_log_group_names" {
  type        = list(string)
  description = "List of CloudWatch Log Group names to stream logs from."
}

variable "destination_bucket_arn" {
  type        = string
  description = "ARN of the bucket for CloudWatch filters."
  default     = ""
}

variable "destination_http_endpoint" {
  type        = string
  description = "HTTP endpoint for CloudWatch filters."
  default     = ""
}

variable "destination_http_secret_name" {
  type        = string
  description = "Name of secret to create for http endpoint. Set the value outside of terraform, see https://docs.aws.amazon.com/firehose/latest/dev/secrets-manager-whats-secret.html"
  default     = null
}

variable "name" {
  type        = string
  description = "Optionally provide unique name to help identify resources when multiple instances of module are created, e.g. 'syslog'"
  default     = null
}

variable "s3_compression_format" {
  type        = string
  description = "Allow optional configuration of AWS Data Stream compression. Log Group subscription filters compress logs by default."
  default     = "UNCOMPRESSED"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to be applied to resources."
}
