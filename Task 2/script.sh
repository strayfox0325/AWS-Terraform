import boto3
import os

def lambda_handler(event, context):
    # SNS klijent
    sns = boto3.client('sns')
    
    # Poruka i tema
    #message = "Hello, world!"
    message = "bHello, world!"
    topic_arn = "arn:aws:sns:eu-central-1:343218202221:DailyEmail"
    
    # Slanje poruke
    response = sns.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject="Daily Notification"
    )
    return {
        'statusCode': 200,
        'body': 'Message sent!'
    }
