/*
 * Lambda alarm example variables
 */

variable region {
  type = string
  description = "AWS region"
}

variable name {
  type = string
  description = "Resource name"
  default = "rube-goldberg-alarm-clock"
}

variable metric_namespace {
  type = string
  description = "Metric namespace"
  default = "Example"
}

variable metric_name {
  type = string
  description = "Metric name"
  default = "Time"
}

variable alarm_threshold {
  type = number
  description = "Time when alarm goes off"
}
