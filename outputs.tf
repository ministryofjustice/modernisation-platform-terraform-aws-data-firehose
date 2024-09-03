output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.kinesis.name
}

output "data_stream" {
  value = aws_kinesis_firehose_delivery_stream.firehose-to-s3
}

output "kms_key_arn" {
  value = aws_kms_key.firehose.arn
}

output "log_subscriptions" {
  value = aws_cloudwatch_log_subscription_filter.cloudwatch-to-firehose
}

output "iam_roles" {
  value = {
    "cloudwatch-to-firehose" = aws_iam_role.cloudwatch-to-firehose,
    "firehose-to-s3" = aws_iam_role.firehose-to-s3
  }
}

output "firehose_server_side_encryption_key_arn" {
  value = aws_kinesis_firehose_delivery_stream.firehose-to-s3.server_side_encryption[0].key_arn
}
