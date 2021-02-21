/*
 * input variables
 */


# general

variable name {
  type = string
  description = "name for resources"
}


# code

variable code_path {
  type = string
  description = "local path to Lambda function source code"
}

variable s3_bucket {
  type = string
  description = "S3 bucket for storing packages"
}

variable s3_folders {
  type = string
  description = "S3 folders in key (default is no folders)"
  default = ""
}


# lambda

variable lambda_handler {
  type = string
  description = "Lambda handler"
}

variable lambda_runtime {
  type = string
  description = "Lambda runtime"
}

variable lambda_role {
  type = string
  description = "Lambda IAM role"
}

variable lambda_environment {
  type = map(string)
  description = "Lambda environment variables"
  default = {}
}

variable lambda_memory {
  type = number
  description = "Lambda memory (MB)"
  default = 128
}

variable lambda_timeout {
  type = number
  description = "Lambda timeout (sec)"
  default = 3
}

variable lambda_security_group_ids {
  type = list(string)
  description = "list of security group Ids granting access to VPC"
  default = []
}

variable lambda_subnet_ids {
  type = list(string)
  description = "list of subnet Ids granting access to VPC"
  default = []
}

variable lambda_event {
  type = map(any)
  description = "Lambda event input"
  default = {}
}


# eventbridge

variable trigger_period {
  type = string
  description = "triggering period (ex. 10h where units are m, h, d)"
  validation {
    condition = can(regex("^(\\d+)([dhm])$", var.trigger_period))
    error_message = "The trigger_period has an invalid format."
  }
}


# metric

variable metric_name {
  type = string
  description = "CloudWatch metric name"
}

variable metric_namespace {
  type = string
  description = "CloudWatch metric namespace"
}

variable metric_dimensions {
  type = map(string)
  description = "CloudWatch metric dimensions"
  default = {}
}


# alarm

variable alarm_statistic {
  type = string
  description = "CloudWatch alarm statistic to evaluate"
  validation {
    condition = contains([
      "SampleCount",
      "Average",
      "Sum",
      "Minimum",
      "Maximum"
    ], var.alarm_statistic)
    error_message = "Valid alarm_statistic values are SampleCount, Average, Sum, Minimum, and Maximum."
  }
}

variable alarm_evaluation_periods {
  type = number
  description = "CloudWatch alarm number of evaluation periods"
  validation {
    condition = var.alarm_evaluation_periods > 0
    error_message = "The alarm_evaluation_periods must be positive."
  }
}

variable alarm_comparison_operator {
  type = string
  description = "CloudWatch alarm comparison operator"
  validation {
    condition = contains([
      "GreaterThanOrEqualToThreshold",
      "GreaterThanThreshold",
      "LessThanThreshold",
      "LessThanOrEqualToThreshold"
    ], var.alarm_comparison_operator)
    error_message = "Valid alarm_comparison_operator values are GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, and LessThanOrEqualToThreshold."
  }
}

variable alarm_threshold {
  type = number
  description = "CloudWatch alarm threshold"
}

variable alarm_unit {
  type = string
  description = "CloudWatch alarm units"
  default = ""
}
