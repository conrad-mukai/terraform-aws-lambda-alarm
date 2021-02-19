# AWS Custom Metric Alarm

This repo contains Terraform code to create an alarm from a custom metric
generated by a Lambda function. The Lambda function is triggered periodically
by an EventBridge (formerly CloudWatch Events) event rule.

When initially deployed this module zips the function's source code and uploads
the zip file to S3. The Lambda function is then launched with the zipped
package. In subsequent runs, if a code change is detected this module updates
the package in S3 and triggers a re-launch of the Lambda function.

## Design

The components in this module are shown below:

![layout](https://raw.githubusercontent.com/conrad-mukai/terraform-aws-lambda-alarm/master/draw.io/aws-lambda-alarm.png)

The blue lines indicate actions performed at deploy time. The black lines are
for actions performed every time the event rule is triggered. The red lines are
for actions performed every time an alarm is triggered.

## How to Use

Two resources need to be created before running this code:
1. an S3 bucket for storing the zip file for the Lambda function; and
1. an IAM role granting the Lambda function runtime access.

The S3 bucket should enable versioning to support rollback to previous versions
of the code. The module does not support rollback so it should be done
manually. When a fix is in place the module can be used to deploy the new code.

At a minimum the IAM role should allow `cloudwatch:PutMetricData`. If logging
is desired then `logs:CreateLogGroup`, `logs:CreateLogStream`, and
`logs:PutLogEvents` should be added to the role.

Refer to the `example` directory to see a working invocation of this module.
