# ----------------------------------------------------------------------------
# DEPLOY A LAMBDA ALARM IN AWS
# Deploy a Python based lambda-alarm to demonstrate how to use the module. The
# Python script sends the UTC time in seconds to the metric Example/Time. An
# alarm is raised when the metric is greater than or equal to the threshold.
# Adding a subscription to the SNS topic receiving the alarm creates an overly
# complex alarm clock.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# PROVIDER
# Configure the AWS provider. The configuration specifies the AWS region.
# ----------------------------------------------------------------------------
provider aws {
  region = var.region
}

# ----------------------------------------------------------------------------
# S3 BUCKET
# Create an S3 bucket for the example. The bucket is created with versioning
# enabled to archive all versions of the package.
# ----------------------------------------------------------------------------
resource aws_s3_bucket repository {
  bucket_prefix = var.name
  acl = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
}

# ----------------------------------------------------------------------------
# IAM ROLE FOR LAMBDA FUNCTION
# Create an IAM role for the Lambda function that allows it to put the metric
# data in CloudWatch.
# ----------------------------------------------------------------------------

data aws_iam_policy_document lambda-assume {
  statement {
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource aws_iam_role lambda {
  name = var.name
  assume_role_policy = data.aws_iam_policy_document.lambda-assume.json
}

data aws_iam_policy_document lambda {
  statement {
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }
}

resource aws_iam_role_policy lambda {
  role = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

# ----------------------------------------------------------------------------
# LAMBDA-ALARM
# Call the module to create an alarm. The input event used to trigger the
# function is created here. It specifies the metric namespace and name so the
# function writes to the same metric being monitored for the alarm.
# ----------------------------------------------------------------------------

locals {
  lambda_event = {
    MetricNamespace = var.metric_namespace
    MetricName = var.metric_name
  }
}

module example {
  source = "../../"
  name = var.name
  code_path = "./src"
  s3_bucket = aws_s3_bucket.repository.bucket
  lambda_handler = "timer.handler"
  lambda_runtime = "python3.8"
  lambda_role = aws_iam_role.lambda.arn
  lambda_event = local.lambda_event
  trigger_period = "1m"
  metric_name = var.metric_name
  metric_namespace = var.metric_namespace
  alarm_statistic = "Maximum"
  alarm_evaluation_periods = 1
  alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_threshold = var.alarm_threshold
  alarm_unit = "Seconds"
}
