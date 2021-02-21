/*
 * output variables
 */

output lambda_function {
  value = aws_lambda_function.this.function_name
  description = "name of Lambda function that generates alarms"
}

output sns_topic {
  value = aws_sns_topic.topic.name
  description = "SNS topic receiving alarms"
}
