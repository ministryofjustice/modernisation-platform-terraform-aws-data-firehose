module "test" {
  source                     = "../../"
  cloudwatch_log_group_names = [aws_cloudwatch_log_group.test.name]
  destination_bucket_arn     = aws_s3_bucket.test.arn
  tags                       = local.tags
}

resource "aws_s3_bucket" "test" {
  bucket_prefix = "test"
  force_destroy = true
  tags          = local.tags
}

resource "aws_cloudwatch_log_group" "test" {
  name_prefix = "test"
  tags        = local.tags
}
