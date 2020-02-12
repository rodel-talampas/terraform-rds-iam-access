variable "access_key" {
  description = "AWS Access Key."
  default     = ""
}

variable "secret_key" {
  description = "AWS Secret Key."
  default     = ""
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "db_admin" {
  description = "Default DB Admin user"
  default     = "admin"
}

variable "db_name" {
  description = "Default DB Name"
  default     = "otp"
}

variable "db_port" {
  description = "Default DB Port"
  default     = "5432"
}

variable "localstack_url" {
  description = "Default localstack url"
  default     = "http://localhost"
}

variable "secretmanager_port" {
  description = "Default secretsmanager port"
  default     = "4584"
}
