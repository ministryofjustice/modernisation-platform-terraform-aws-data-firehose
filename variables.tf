variable "cloudwatch_log_group_names" {
  type        = list(string)
  description = "List of CloudWatch Log Group names to stream logs from."
}

variable "destination_bucket_arn" {
  type        = string
  description = "ARN of the bucket for CloudWatch filters."
}

variable "cloudwatch_filter_pattern" {
  type        = string
  description = "A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to be applied to resources."
}
