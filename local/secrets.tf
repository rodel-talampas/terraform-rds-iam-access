resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "postgres_secret" {
  # name = join("",["db_secret_",random_string.secrets.result])
  name = "postgres_db_secret"
  recovery_window_in_days = 0
  depends_on = [docker_container.secretsmanager]
}

# This is to save the user db and password into AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "postgres_secret" {
  secret_id     = aws_secretsmanager_secret.postgres_secret.id
  secret_string = "{\"username\":\"${var.db_admin}\",\"password\":\"${random_password.password.result}\"}"
}
