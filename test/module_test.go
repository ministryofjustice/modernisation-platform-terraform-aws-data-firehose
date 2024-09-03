package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test CloudWatch Log Group exists
	cloudwatchLogGroupName := terraform.Output(t, terraformOptions, "cloudwatch_log_group_name")
	assert.Contains(t, cloudwatchLogGroupName, "/aws/kinesisfirehose/cloudwatch-to-s3", "CloudWatch Log Group name should contain '/aws/kinesisfirehose/cloudwatch-to-s3'")

	// Retrieve and test the 'data_stream' output as a map
	dataStream := terraform.OutputMap(t, terraformOptions, "data_stream")
    assert.Contains(t, dataStream["name"], "cloudwatch-to-s3", "Data stream name should contain 'cloudwatch-to-s3'")

    // Test IAM Roles exist
    iamRoles := terraform.OutputMap(t, terraformOptions, "iam_roles")
    assert.Contains(t, iamRoles["firehose-to-s3"], "arn:aws:iam", "Firehose-to-S3 role ARN should contain 'arn:aws:iam'")
    assert.Contains(t, iamRoles["cloudwatch-to-firehose"], "arn:aws:iam", "CloudWatch-to-Firehose role ARN should contain 'arn:aws:iam'")

    // Test Log Subscriptions exist
    logSubscriptions := terraform.OutputList(t, terraformOptions, "log_subscriptions")
    assert.NotEmpty(t, logSubscriptions, "Log subscriptions should not be empty")

	// Test KMS Key ARN and Firehose Server Side Encryption Key ARN match
	kmsKeyArn := terraform.Output(t, terraformOptions, "kms_key_arn")
	firehoseEncryptionKeyArn := terraform.Output(t, terraformOptions, "firehose_server_side_encryption_key_arn")
	assert.Equal(t, kmsKeyArn, firehoseEncryptionKeyArn, "KMS Key ARN and Firehose Server-Side Encryption Key ARN should match")

}
