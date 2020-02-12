provider "aws" {
  profile                     = "default"
  region                      = var.aws_region
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

data "aws_caller_identity" "current" {}
