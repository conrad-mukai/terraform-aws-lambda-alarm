/*
 * Lambda alarm example outputs
 */

output lambda_function {
  value = module.example.lambda_function
}

output sns_topic {
  value = module.example.sns_topic
}
