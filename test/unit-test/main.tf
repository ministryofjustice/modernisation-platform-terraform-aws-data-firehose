module "test" {
  source                     = "../../"
  cloudwatch_log_group_names = [aws_cloudwatch_log_group.test.name]
  destination_bucket_arn     = aws_s3_bucket.test.arn
  tags                       = local.tags
}

resource "aws_s3_bucket" "test" {
  #checkov:skip=CKV_AWS_18
  #checkov:skip=CKV_AWS_21
  #checkov:skip=CKV_AWS_144
  #checkov:skip=CKV_AWS_145
  #checkov:skip=CKV2_AWS_6
  #checkov:skip=CKV2_AWS_68
  bucket_prefix = "test"
  force_destroy = true
  tags          = local.tags
}

resource "aws_cloudwatch_log_group" "test" {
  #checkov:skip=CKV_AWS_66
  #checkov:skip=CKV_AWS_158
  #checkov:skip=CKV_AWS_338
  name_prefix = "test"
  tags        = local.tags
}
