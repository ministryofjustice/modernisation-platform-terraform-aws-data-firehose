output "data_stream" {
  value = aws_kinesis_firehose_delivery_stream.firehose-to-s3
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
