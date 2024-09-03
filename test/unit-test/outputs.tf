 output "cloudwatch_log_group_name" {
   value = module.test.cloudwatch_log_group_name
 }

 output "data_stream" {
   value = module.test.data_stream
 }

 output "iam_roles" {
   value = module.test.iam_roles
 }

 output "log_subscriptions" {
   value = module.test.log_subscriptions
 }

 output "kms_key_arn" {
   value = module.test.kms_key_arn
 }

 output "firehose_server_side_encryption_key_arn" {
   value = module.test.firehose_server_side_encryption_key_arn
 }
