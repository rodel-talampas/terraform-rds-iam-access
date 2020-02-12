provider "aws" {
  access_key                  = var.access_key
  region                      = var.aws_region
  s3_force_path_style         = true
  secret_key                  = var.secret_key
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    secretsmanager = join("",[var.localstack_url,":",var.secretmanager_port])
  }
}
