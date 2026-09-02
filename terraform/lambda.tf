data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "ai_triage_lambda" {
  function_name    = "three-tier-ai-triage"
  role             = aws_iam_role.lambda_task_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout = 30
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      CLAUDE_SECRET_NAME = aws_secretsmanager_secret.claude_api_key_secret.name
      SLACK_SECRET_NAME  = aws_secretsmanager_secret.slack_webhook_secret.name
    }
  }
}