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
  type = string
  description = "Lambda event input in JSON format"
  default = ""
}


# eventbridge

variable trigger_period {
  type = string
  description = "triggering period (ex. 10h where units are m, h, d)"
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
}

variable alarm_evaluation_periods {
  type = number
  description = "CloudWatch alarm number of evaluation periods"
}

variable alarm_comparison_operator {
  type = string
  description = "CloudWatch alarm comparison operator"
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
