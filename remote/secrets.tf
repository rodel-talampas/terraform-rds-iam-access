resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_!$"
}

resource "aws_secretsmanager_secret" "postgres_secret" {
  # name = join("",["db_secret_",random_string.secrets.result])
  name = "postgres_otp_db_secret_${var.environment}"
  recovery_window_in_days = 0
}

# This is to save the user db and password into AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "postgres_secret" {
  secret_id     = aws_secretsmanager_secret.postgres_secret.id
  secret_string = "{\"username\":\"${var.db_admin}\",\"password\":\"${random_password.password.result}\",\"db_endpoint\":\"${aws_db_instance.otp_main.address}\",\"db_port\":\"${aws_db_instance.otp_main.port}\",\"db_name\":\"${aws_db_instance.otp_main.name}\"}"
}
