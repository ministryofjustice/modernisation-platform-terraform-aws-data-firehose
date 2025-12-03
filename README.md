# Modernisation Platform Terraform AWS Data Firehose Module

[![Standards Icon]][Standards Link] [![Format Code Icon]][Format Code Link] [![Scorecards Icon]][Scorecards Link] [![SCA Icon]][SCA Link] [![Terraform SCA Icon]][Terraform SCA Link]

## Usage

```hcl

module "example-s3" {
  source                     = "github.com/ministryofjustice/modernisation-platform-terraform-aws-data-firehose"
  cloudwatch_log_group_names = ["example-1", "example-2", "example-3"]
  destination_bucket_arn     = aws_s3_bucket.example.arn
  name                       = "example-s3" # optionally provide name for more descriptive resource names
  tags                       = local.tags
}

module "example-http" {
  source                       = "github.com/ministryofjustice/modernisation-platform-terraform-aws-data-firehose"
  cloudwatch_log_group_names   = ["example-1", "example-2", "example-3"]
  destination_http_endpoint    = "https://example-url.com/endpoint"
  destination_http_secret_name = "http-api-keys/example" # optionally specify name of secret to create
  name                         = "example-http"          # optionally provide name for more descriptive resource names
  tags                         = local.tags
}

```

This module creates an [AWS Data Stream](https://aws.amazon.com/kinesis/data-streams/) to be used by a set of AWS CloudWatch Log Groups.
Data is streamed from the Log Groups to either a target S3 bucket or HTTP endpoint using a Cloudwatch Log Subscription Filter.

When an HTTP endpoint is specified, an `aws_secretsmanager_secret` resource is created that is polled at 10-minute intervals for credentials.

The `aws_secretsmanager_secret` **value** must be populated independently of this module.
See [AWS Firehose Secrets](https://docs.aws.amazon.com/firehose/latest/dev/secrets-manager-whats-secret.html) for details of the format.

Included in this module are the necessary IAM policy documents and roles for these actions, as well as a KMS key to encrypt the Data Stream.

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.0  |
| <a name="requirement_random"></a> [random](#requirement_random)          | ~> 3.4  |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | ~> 6.0  |
| <a name="provider_random"></a> [random](#provider_random) | ~> 3.4  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                             | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_cloudwatch_log_group.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                                             | resource    |
| [aws_cloudwatch_log_subscription_filter.cloudwatch-to-firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter)                  | resource    |
| [aws_iam_policy.cloudwatch-to-firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                  | resource    |
| [aws_iam_policy.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                                | resource    |
| [aws_iam_policy_attachment.cloudwatch-to-firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment)                                            | resource    |
| [aws_iam_policy_attachment.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment)                                                          | resource    |
| [aws_iam_role.cloudwatch-to-firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                      | resource    |
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                                    | resource    |
| [aws_kinesis_firehose_delivery_stream.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream)                                    | resource    |
| [aws_kms_alias.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                                                                  | resource    |
| [aws_kms_key.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                                      | resource    |
| [aws_s3_bucket.firehose-errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket_lifecycle_configuration.firehose-errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                           | resource    |
| [aws_s3_bucket_public_access_block.firehose-errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                   | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.firehose-errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_versioning.firehose-errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource    |
| [aws_secretsmanager_secret.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                                                          | resource    |
| [random_id.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                                              | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                                    | data source |
| [aws_iam_policy_document.cloudwatch-logs-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                        | data source |
| [aws_iam_policy_document.cloudwatch-logs-trust-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                       | data source |
| [aws_iam_policy_document.firehose-key-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                | data source |
| [aws_iam_policy_document.firehose-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                               | data source |
| [aws_iam_policy_document.firehose-trust-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                              | data source |

## Inputs

| Name                                                                                                                  | Description                                                                                                                                                           | Type           | Default          | Required |
| --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ---------------- | :------: |
| <a name="input_cloudwatch_filter_pattern"></a> [cloudwatch_filter_pattern](#input_cloudwatch_filter_pattern)          | A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events.                                                                            | `string`       | `""`             |    no    |
| <a name="input_cloudwatch_log_group_names"></a> [cloudwatch_log_group_names](#input_cloudwatch_log_group_names)       | List of CloudWatch Log Group names to stream logs from.                                                                                                               | `list(string)` | n/a              |   yes    |
| <a name="input_destination_bucket_arn"></a> [destination_bucket_arn](#input_destination_bucket_arn)                   | ARN of the bucket for CloudWatch filters.                                                                                                                             | `string`       | `""`             |    no    |
| <a name="input_destination_http_endpoint"></a> [destination_http_endpoint](#input_destination_http_endpoint)          | HTTP endpoint for CloudWatch filters.                                                                                                                                 | `string`       | `""`             |    no    |
| <a name="input_destination_http_secret_name"></a> [destination_http_secret_name](#input_destination_http_secret_name) | Name of secret to create for http endpoint. Set the value outside of terraform, see https://docs.aws.amazon.com/firehose/latest/dev/secrets-manager-whats-secret.html | `string`       | `null`           |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                         | Optionally provide unique name to help identify resources when multiple instances of module are created, e.g. 'syslog'                                                | `string`       | `null`           |    no    |
| <a name="input_s3_compression_format"></a> [s3_compression_format](#input_s3_compression_format)                      | Allow optional configuration of AWS Data Stream compression. Log Group subscription filters compress logs by default.                                                 | `string`       | `"UNCOMPRESSED"` |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                         | Map of tags to be applied to resources.                                                                                                                               | `map(string)`  | n/a              |   yes    |

## Outputs

| Name                                                                                                                                                     | Description |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch_log_group_name](#output_cloudwatch_log_group_name)                                           | n/a         |
| <a name="output_data_stream"></a> [data_stream](#output_data_stream)                                                                                     | n/a         |
| <a name="output_firehose_server_side_encryption_key_arn"></a> [firehose_server_side_encryption_key_arn](#output_firehose_server_side_encryption_key_arn) | n/a         |
| <a name="output_iam_roles"></a> [iam_roles](#output_iam_roles)                                                                                           | n/a         |
| <a name="output_kms_key_arn"></a> [kms_key_arn](#output_kms_key_arn)                                                                                     | n/a         |
| <a name="output_log_subscriptions"></a> [log_subscriptions](#output_log_subscriptions)                                                                   | n/a         |
| <a name="output_secretsmanager_secret_arn"></a> [secretsmanager_secret_arn](#output_secretsmanager_secret_arn)                                           | n/a         |

<!-- END_TF_DOCS -->

[Standards Link]: https://github-community.service.justice.gov.uk/repository-standards/modernisation-platform-terraform-aws-data-firehose "Repo standards badge."
[Standards Icon]: https://github-community.service.justice.gov.uk/repository-standards/api/modernisation-platform-terraform-aws-data-firehose/badge
[Format Code Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-module-template/format-code.yml?labelColor=231f20&style=for-the-badge&label=Formate%20Code
[Format Code Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-module-template/actions/workflows/format-code.yml
[Scorecards Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-module-template/scorecards.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Scorecards
[Scorecards Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-module-template/actions/workflows/scorecards.yml
[SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-module-template/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Secure%20Code%20Analysis
[SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-module-template/actions/workflows/code-scanning.yml
[Terraform SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-module-template/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Terraform%20Static%20Code%20Analysis
[Terraform SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-module-template/actions/workflows/terraform-static-analysis.yml
