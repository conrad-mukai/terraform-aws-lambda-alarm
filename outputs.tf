/*
 * output variables
 */

output lambda_function {
  value = aws_lambda_function.function.function_name
  description = "name of Lambda function that generates alarms"
}

output lambda_version {
  value = local.qualifier
  description = "version of Lambda function"
}

output sns_topic {
  value = aws_sns_topic.topic.name
  description = "SNS topic receiving alarms"
}
