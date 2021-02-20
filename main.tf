# ----------------------------------------------------------------------------
# DEPLOY AN ALARM USING LAMBDA AND A CUSTOM METRIC
# This module uses AWS resources to generate an alarm based upon custom
# calculations performed by a Lambda function. The module is given the path to
# the source code run by the Lambda function. This is used to create a zip file
# that is published to an S3 bucket which the Lambda function subsequently
# downloads at launch time. In addition to the Lambda function the module also
# creates an EventBridge event rule, a custom CloudWatch metric and alarm, and
# an SNS topic.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12.6"
}

# -----------------------------------------------------------------------------
# CREATE ZIP FILE
# Generate a zip file from the source code. This is performed everytime
# terraform is executed (even during terraform plan). The zip file will be
# placed in the current working directory.
# -----------------------------------------------------------------------------

locals {
  package_name = "${var.name}.zip"
  package_path = "${path.cwd}/${local.package_name}"
}

data archive_file package {
  source_dir = var.code_path
  output_path = local.package_path
  type = "zip"
}

# -----------------------------------------------------------------------------
# PUBLISH ZIP FILE
# The zip file is published to the designated S3 bucket. Users can optionally
# specify a folder path. A hash of the zip file triggers uploads to S3 when a
# code change is detected.
# -----------------------------------------------------------------------------

locals {
  s3_key = length(var.s3_folders) == 0 ? local.package_name : "${var.s3_folders}/${local.package_name}"
}

resource aws_s3_bucket_object package {
  bucket = var.s3_bucket
  key = local.s3_key
  source = data.archive_file.package.output_path
  etag = data.archive_file.package.output_md5
}

# -----------------------------------------------------------------------------
# LAMBDA FUNCTION
# The Lambda function is created/updated here. It pulls the zip file uploaded
# to S3 and is configured with the various input variables. A hash of the zip
# file triggers re-launch of the function when a code change is detected.
#
# Rollback to a previous version of the function should be done manually. When
# a new version of the code is ready use terraform to fix forward.
# -----------------------------------------------------------------------------

resource aws_lambda_function function {
  function_name = var.name
  handler = var.lambda_handler
  role = var.lambda_role
  runtime = var.lambda_runtime
  s3_bucket = aws_s3_bucket_object.package.bucket
  s3_key = aws_s3_bucket_object.package.key
  source_code_hash = data.archive_file.package.output_base64sha256
  publish = true
  memory_size = var.lambda_memory
  timeout = var.lambda_timeout
  dynamic environment {
    for_each = length(var.lambda_environment) == 0 ? [] : [1]
    content {
      variables = var.lambda_environment
    }
  }
  vpc_config {
    security_group_ids = var.lambda_security_group_ids
    subnet_ids = var.lambda_subnet_ids
  }
}

# -----------------------------------------------------------------------------
# TRIGGER
# A scheduled event is setup using the trigger_period variable. The variable is
# a string with number followed by a time unit, for example 10h indicates a 10
# hour period. The allowable units are m (minute), h (hour), and d (day). This
# variable is parsed and converted to a CloudWatch rate expression. The event
# uses the lambda_event variable to send a constant JSON input to the Lambda
# function. An aws_lambda_permission resource enables access from the
# triggering event service to the Lambda function.
# -----------------------------------------------------------------------------

locals {
  trigger_expr = regex("(\\d+)([dhm])", var.trigger_period)
  trigger_unit_single = local.trigger_expr[1] == "d" ? "day" : local.trigger_expr[1] == "h" ? "hour" : "minute"
  trigger_unit = "${local.trigger_unit_single}${local.trigger_expr[0] == "1" ? "" : "s"}"
  schedule_expression = "rate(${local.trigger_expr[0]} ${local.trigger_unit})"
  qualifier = regex(":(\\d+)$", aws_lambda_function.function.qualified_arn)[0]
}

resource aws_cloudwatch_event_rule trigger {
  name = var.name
  description = "trigger Lambda function ${var.name}"
  schedule_expression = local.schedule_expression
}

resource aws_cloudwatch_event_target function {
  arn = aws_lambda_function.function.qualified_arn
  rule = aws_cloudwatch_event_rule.trigger.name
  input = var.lambda_event
}

resource aws_lambda_permission function {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  qualifier = local.qualifier
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.trigger.arn
}

# -----------------------------------------------------------------------------
# ALARM
#
# Trigger an SNS message when the CloudWatch metric alarms. The metric is
# specified by the metric_namespace, metric_name, and optionally
# metric_dimensions variables. These parameters are not part of the Lambda
# resource configuration, but can be passed to the Lambda function through the
# lambda_event JSON string. The metric coordinates can be hard coded in the
# function, but that is not recommended since it limits the flexibility of the
# Lambda function.
#
# The sampling period of the alarm is based upon the value specified in the
# trigger_period. The number of sampling periods required to trigger an alarm
# is specified with the alarm_evaluation_periods variable. The triggering
# criteria is based on the alarm_comparison_operator and alarm_threshold
# variables.
#
# The alarm is sent to an SNS topic. The user can then manually add
# subscriptions to the topic to configure the method of communication.
# -----------------------------------------------------------------------------

locals {
  period = local.trigger_expr[0] * (local.trigger_expr[1] == "d" ? 86400 : local.trigger_expr[1] == "h" ? 3600 : 60)
}

resource aws_sns_topic topic {
  name = var.name
}

resource aws_cloudwatch_metric_alarm alarm {
  alarm_name = var.name
  comparison_operator = var.alarm_comparison_operator
  period = local.period
  metric_name = var.metric_name
  namespace = var.metric_namespace
  dimensions = var.metric_dimensions
  statistic = var.alarm_statistic
  evaluation_periods = var.alarm_evaluation_periods
  threshold = var.alarm_threshold
  unit = var.alarm_unit
  alarm_actions = [aws_sns_topic.topic.arn]
  ok_actions = [aws_sns_topic.topic.arn]
}
