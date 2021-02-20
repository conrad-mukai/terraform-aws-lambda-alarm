/*
 * Lambda alarm example outputs
 */

output lambda_function {
  value = module.example.lambda_function
  description = "name of Lambda function checking time"
}

output sns_topic {
  value = module.example.sns_topic
  description = "SNS topic receiving the alarm"
}
