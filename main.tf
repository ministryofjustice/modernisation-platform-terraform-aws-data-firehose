resource "random_id" "name" {
  byte_length = 4
}

resource "aws_kms_key" "firehose" {
  # checkov:skip=CKV_AWS_7
  description             = "KMS key for Firehose delivery streams"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.firehose-key-policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "firehose" {
  name_prefix   = "alias/firehose-log-delivery-${random_id.name.hex}"
  target_key_id = aws_kms_key.firehose.id
}

resource "aws_iam_role" "firehose" {
  assume_role_policy = data.aws_iam_policy_document.firehose-trust-policy.json
  name_prefix        = "firehose"
  tags               = var.tags
}

resource "aws_iam_policy" "firehose" {
  name_prefix = "firehose"
  policy      = data.aws_iam_policy_document.firehose-role-policy.json
  tags        = var.tags
}

resource "aws_iam_policy_attachment" "firehose" {
  name       = "${aws_iam_role.firehose.name}-policy"
  policy_arn = aws_iam_policy.firehose.arn
  roles      = [aws_iam_role.firehose.name]
}

resource "aws_iam_role" "cloudwatch-to-firehose" {
  assume_role_policy = data.aws_iam_policy_document.cloudwatch-logs-trust-policy.json
  name_prefix        = "cloudwatch-to-firehose"
  tags               = var.tags
}

resource "aws_iam_policy" "cloudwatch-to-firehose" {
  name_prefix = "cloudwatch-to-firehose"
  policy      = data.aws_iam_policy_document.cloudwatch-logs-role-policy.json
  tags        = var.tags
}

resource "aws_iam_policy_attachment" "cloudwatch-to-firehose" {
  name       = "${aws_iam_role.cloudwatch-to-firehose.name}-policy"
  policy_arn = aws_iam_policy.cloudwatch-to-firehose.arn
  roles      = [aws_iam_role.cloudwatch-to-firehose.name]
}

resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  destination = length(var.destination_bucket_arn) > 0 ? "extended_s3" : "http_endpoint"
  name        = "cloudwatch-export-${random_id.name.hex}"

  dynamic "extended_s3_configuration" {
    for_each = var.destination_bucket_arn != "" ? [1] : []
    content {
      bucket_arn          = var.destination_bucket_arn
      buffering_size      = 64
      buffering_interval  = 60
      compression_format  = var.s3_compression_format
      role_arn            = aws_iam_role.firehose.arn
      prefix              = "logs/!{timestamp:yyyy/MM/dd}/"
      error_output_prefix = "errors/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"

      cloudwatch_logging_options {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.kinesis.name
        log_stream_name = "DestinationDelivery"
      }

      dynamic_partitioning_configuration {
        enabled = false
      }
    }
  }
  dynamic "http_endpoint_configuration" {
    for_each = var.destination_http_endpoint != "" ? [1] : []
    content {
      buffering_size     = 1
      buffering_interval = 60
      name               = var.destination_http_endpoint
      retry_duration     = 300
      role_arn           = aws_iam_role.firehose.arn
      s3_backup_mode     = "FailedDataOnly"
      url                = var.destination_http_endpoint

      s3_configuration {
        role_arn           = aws_iam_role.firehose.arn
        bucket_arn         = aws_s3_bucket.firehose-errors.arn
        buffering_size     = 10
        buffering_interval = 400
        compression_format = "GZIP"
      }

      request_configuration {
        content_encoding = "GZIP"
      }

      secrets_manager_configuration {
        enabled    = true
        role_arn   = aws_iam_role.firehose.arn
        secret_arn = aws_secretsmanager_secret.firehose.arn
      }
    }
  }

  server_side_encryption {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = aws_kms_key.firehose.arn
  }

  tags = var.tags
}

resource "aws_secretsmanager_secret" "firehose" {
  name_prefix             = "cloudwatch-export-${random_id.name.hex}"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_s3_bucket" "firehose-errors" {
  bucket_prefix = "firehose-errors"
  force_destroy = true
  tags          = var.tags
}

resource "aws_cloudwatch_log_group" "kinesis" {
  #  checkov:skip=CKV_AWS_338:Short life error logs don't need long term retention
  #  checkov:skip=CKV_AWS_158:Default log encryption OK for short life error logs
  name              = "/aws/kinesisfirehose/cloudwatch-to-s3-${random_id.name.hex}"
  retention_in_days = 14
  tags              = var.tags
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch-to-firehose" {
  count           = length(var.cloudwatch_log_group_names)
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose.arn
  filter_pattern  = var.cloudwatch_filter_pattern
  log_group_name  = element(var.cloudwatch_log_group_names, count.index)
  name            = "firehose-delivery-${element(var.cloudwatch_log_group_names, count.index)}-${random_id.name.hex}"
  role_arn        = aws_iam_role.cloudwatch-to-firehose.arn
}
