package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test CloudWatch Log Group exists for both `http` and `s3` streams
	cloudwatchLogGroupName := terraform.OutputMap(t, terraformOptions, "cloudwatch_log_group_name")
	assert.Contains(t, cloudwatchLogGroupName["http"], "/aws/kinesisfirehose/cloudwatch-to-s3", "HTTP CloudWatch Log Group name should contain '/aws/kinesisfirehose/cloudwatch-to-s3'")
	assert.Contains(t, cloudwatchLogGroupName["s3"], "/aws/kinesisfirehose/cloudwatch-to-s3", "S3 CloudWatch Log Group name should contain '/aws/kinesisfirehose/cloudwatch-to-s3'")

	// Retrieve and test the 'data_stream' output as a map
	dataStream := terraform.OutputMap(t, terraformOptions, "data_stream")
	assert.Contains(t, dataStream["http"], "cloudwatch-export", "HTTP Data stream ARN should contain 'cloudwatch-export'")
	assert.Contains(t, dataStream["s3"], "cloudwatch-export", "S3 Data stream ARN should contain 'cloudwatch-export'")

	// Test KMS Key ARN and Firehose Server Side Encryption Key ARN match
	kmsKeyArn := terraform.OutputMap(t, terraformOptions, "kms_key_arn")
	firehoseServerSideEncryptionKeyArn := terraform.OutputMap(t, terraformOptions, "firehose_server_side_encryption_key_arn")
	assert.Contains(t, firehoseServerSideEncryptionKeyArn["http"], kmsKeyArn["http"], "HTTP Encryption keys do not match")
	assert.Contains(t, firehoseServerSideEncryptionKeyArn["s3"], kmsKeyArn["s3"], "S3 Encryption keys do not match")

	// Test IAM Roles exist
	iamRoles := terraform.OutputMap(t, terraformOptions, "iam_roles")
	assert.NotEmpty(t, iamRoles["http"], "HTTP IAM roles should not be empty")
	assert.NotEmpty(t, iamRoles["s3"], "S3 IAM roles should not be empty")

	// Test Log Subscriptions exist
	logSubscriptions := terraform.OutputMap(t, terraformOptions, "log_subscriptions")
	assert.NotEmpty(t, logSubscriptions["http"], "HTTP Log subscriptions should not be empty")
	assert.NotEmpty(t, logSubscriptions["s3"], "S3 Log subscriptions should not be empty")

}
