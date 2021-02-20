"""
write time of day to metrics
"""

# system imports
import datetime

# 3rd party imports
import boto3

def handler(event, context):
    dt = datetime.datetime.now()
    t = dt.time()
    tsec = ((t.hour * 60) + t.minute) * 60 + t.second
    client = boto3.client('cloudwatch')
    client.put_metric_data(
        Namespace=event['MetricNamespace'],
        MetricData=[
            {
                'MetricName': event['MetricName'],
                'Timestamp': dt,
                'Value': tsec,
                'Unit': 'Seconds'
            }
        ]
    )
