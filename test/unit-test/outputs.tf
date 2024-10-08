locals {
  modules = {
    "s3"   = module.test-s3
    "http" = module.test-http
  }
}

output "cloudwatch_log_group_name" {
  value = { for key, value in local.modules : key => value.cloudwatch_log_group_name }
}

# Only the data_stream ID gets output to preserve the safety of sensitive values
output "data_stream" {
  value = { for key, value in local.modules : key => value.data_stream }
}

output "firehose_server_side_encryption_key_arn" {
  value = { for key, value in local.modules : key => value.firehose_server_side_encryption_key_arn }
}

output "iam_roles" {
  value = { for key, value in local.modules : key => value.iam_roles }
}

output "kms_key_arn" {
  value = { for key, value in local.modules : key => value.kms_key_arn }
}

output "log_subscriptions" {
  value = { for key, value in local.modules : key => value.log_subscriptions }
}

output "secretsmanager_secret_arn" {
  value = { for key, value in local.modules : key => value.secretsmanager_secret_arn }
}
