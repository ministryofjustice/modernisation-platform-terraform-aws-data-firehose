resource "random_id" "name" {
  byte_length = 4
}

locals {
  name_prefix = var.name != null ? "firehose-${var.name}" : "firehose"
  name_unique = coalesce(var.name, random_id.name.hex)
}

resource "aws_kms_key" "firehose" {
  # checkov:skip=CKV_AWS_7
  description             = "KMS key for Firehose delivery streams"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.firehose-key-policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "firehose" {
  name          = var.name != null ? "alias/firehose-${var.name}-log-delivery" : null
  name_prefix   = var.name == null ? "alias/firehose-log-delivery-${random_id.name.hex}" : null
  target_key_id = aws_kms_key.firehose.id
}

resource "aws_iam_role" "firehose" {
  assume_role_policy = data.aws_iam_policy_document.firehose-trust-policy.json
  name               = var.name != null ? "firehose-${var.name}" : null
  name_prefix        = var.name == null ? "firehose" : null
  tags               = var.tags
}

resource "aws_iam_policy" "firehose" {
  name        = var.name != null ? "firehose-${var.name}" : null
  name_prefix = var.name == null ? "firehose" : null
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
  name               = var.name != null ? "cloudwatch-to-firehose-${var.name}" : null
  name_prefix        = var.name == null ? "cloudwatch-to-firehose" : null
  tags               = var.tags
}

resource "aws_iam_policy" "cloudwatch-to-firehose" {
  name        = var.name != null ? "cloudwatch-to-firehose-${var.name}" : null
  name_prefix = var.name == null ? "cloudwatch-to-firehose" : null
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
  name        = "cloudwatch-export-${local.name_unique}"

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
  # checkov:skip=CKV2_AWS_57
  description             = "populate with http endpoint credentials, e.g. API key or username/password"
  kms_key_id              = aws_kms_key.firehose.id
  name                    = var.destination_http_secret_name
  name_prefix             = var.destination_http_secret_name == null ? "cloudwatch-export-${local.name_unique}" : null
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_s3_bucket" "firehose-errors" {
  # checkov:skip=CKV_AWS_18:Access logging not required
  # checkov:skip=CKV_AWS_144:Replication not required
  # checkov:skip=CKV_AWS_145:Standard encryption fine
  # checkov:skip=CKV2_AWS_62:Notifications not necessary
  bucket_prefix = "${local.name_prefix}-errors"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "firehose-errors" {
  bucket = aws_s3_bucket.firehose-errors.id
   versioning_configuration {
     status = "Enabled"
   }
 }

resource "aws_s3_bucket_lifecycle_configuration" "firehose-errors" {
  bucket = aws_s3_bucket.firehose-errors.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    id = "rule-1"
    filter {}
    expiration {
      days = 14
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "firehose-errors" {
  bucket                  = aws_s3_bucket.firehose-errors.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "firehose-errors" {
  bucket = aws_s3_bucket.firehose-errors.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudwatch_log_group" "kinesis" {
  #  checkov:skip=CKV_AWS_338:Short life error logs don't need long term retention
  #  checkov:skip=CKV_AWS_158:Default log encryption OK for short life error logs

  name        = var.name != null ? "/aws/kinesisfirehose/cloudwatch-to-s3-${var.name}" : null
  name_prefix = var.name == null ? "/aws/kinesisfirehose/cloudwatch-to-s3" : null

  retention_in_days = 14
  tags              = var.tags
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch-to-firehose" {
  count           = length(var.cloudwatch_log_group_names)
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose.arn
  filter_pattern  = var.cloudwatch_filter_pattern
  log_group_name  = element(var.cloudwatch_log_group_names, count.index)
  name            = "firehose-delivery-${element(var.cloudwatch_log_group_names, count.index)}-${local.name_unique}"
  role_arn        = aws_iam_role.cloudwatch-to-firehose.arn
}
