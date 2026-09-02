import json
import boto3
import anthropic
import urllib3
import os

def lambda_handler(event, context):
    sns_message = event["Records"][0]["Sns"]["Message"]
    alarm_data = json.loads(sns_message)
    alarm_name = alarm_data["AlarmName"]
    reason = alarm_data["NewStateReason"]
    metric_name = alarm_data["Trigger"]["MetricName"]
    threshold = alarm_data["Trigger"]["Threshold"]

    prompt = f"""My system is an ECS Fargate container connected to Aurora as the backend database and Redis for caching. A CloudWatch alarm just fired: {alarm_name} ({metric_name}, threshold {threshold}). Details: {reason}. What likely caused this, why, and what's the most obvious first step to investigate or fix it?"""

    secrets_client = boto3.client("secretsmanager")

    secret_response = secrets_client.get_secret_value(SecretId=os.environ["CLAUDE_SECRET_NAME"])
    secret_string = secret_response["SecretString"]
    secret_data = json.loads(secret_string)
    api_key = secret_data["api_key"]

    client = anthropic.Anthropic(api_key=api_key)
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=500,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    ai_summary = response.content[0].text

    slack_secret_response = secrets_client.get_secret_value(SecretId=os.environ["SLACK_SECRET_NAME"])
    slack_secret_data = json.loads(slack_secret_response["SecretString"])
    slack_webhook_url = slack_secret_data["webhook_url"]

    http = urllib3.PoolManager()
    slack_payload = {"text": ai_summary}
    http.request("POST", slack_webhook_url, body=json.dumps(slack_payload))

    return {"statusCode": 200, "body": ai_summary}