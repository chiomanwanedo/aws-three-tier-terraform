resource "aws_secretsmanager_secret" "secret_manager_secret" {
  name                    = "three-tier-secret-manager"
  recovery_window_in_days = 0
}




resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = aws_secretsmanager_secret.secret_manager_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    dbname   = var.db_name
  })
}


# Scoped-down app user credentials — separate from the master credential above.
# The ECS execution role only has permission to read THIS secret, not the master one.

resource "random_password" "app_user_password" {
  length  = 25
  special = true
}

resource "aws_secretsmanager_secret" "app_user_secret" {
  name                    = "three-tier-app-user-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app_user_secret_version" {
  secret_id = aws_secretsmanager_secret.app_user_secret.id
  secret_string = jsonencode({
    username = "app_user"
    password = random_password.app_user_password.result
    dbname   = var.db_name
  })
}