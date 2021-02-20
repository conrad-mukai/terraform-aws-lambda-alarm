# Rube Goldberg Alarm Clock

The [Rube Goldberg](https://en.wikipedia.org/wiki/Rube_Goldberg_machine) alarm
clock uses the `lambda-alarm` module to send a notification at a certain time.
The Python code in the `src` directory computes the number of seconds since the
beginning of the UTC day and posts that number to a CloudWatch custom metric.
An alarm is programmed to send a notification when the metric reaches the
desired time.

## How to Use

To run the example do the following:
1. copy `terraform.tfvars.example` to a `terraform.tfvars` file and specify the
   region and threshold values;
1. run `terraform init`;
1. run `terraform apply`;
1. manually add an email subscription to the SNS topic;
1. you will receive an email asking to confirm the subscription;
1. confirm the subscription; and
1. wait for the email alarm.
