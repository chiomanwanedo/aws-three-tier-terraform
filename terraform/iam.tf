resource "aws_iam_role" "ecs_execution_role" {
  name = "three-tier-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "three-tier-execution-role"
  }
}



resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Scoped-down secret access: the execution role can ONLY read the app_user
# secret's value. It has no access to the master credential's secret.

data "aws_iam_policy_document" "app_user_secret_access" {
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.app_user_secret.arn,
      aws_secretsmanager_secret.secret_manager_secret.arn
    ]
  }
}

resource "aws_iam_role_policy" "app_user_secret_policy" {
  name   = "app-user-secret-read-only"
  role   = aws_iam_role.ecs_execution_role.id
  policy = data.aws_iam_policy_document.app_user_secret_access.json
}


data "aws_iam_policy_document" "ecs_task_role_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "three-tier-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_trust.json
}


resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# --- Lambda IAM setup for AI incident-triage function ---

data "aws_iam_policy_document" "lambda_task_role_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_task_role" {
  name               = "three-tier-lambda-task-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_task_role_trust.json
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_secrets_access" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.claude_api_key_secret.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.slack_webhook_secret.arn]
  }
}

resource "aws_iam_role_policy" "lambda_secret_policy" {
  name   = "lambda-secret-read-only"
  role   = aws_iam_role.lambda_task_role.id
  policy = data.aws_iam_policy_document.lambda_secrets_access.json
}


resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ai_triage_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.three_tier_topic.arn
}