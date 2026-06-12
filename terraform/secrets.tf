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


