variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-2"
}

variable "encrypted" {
  default = true
}

# database
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

variable "db_size" {
  type    = string
  default = "20"
}

variable "db_backup_retention" {
  default = 7
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "11"
}

variable "db_license_model" {
  type    = string
  default = "postgresql-license"
}

variable "db_publicly_accessible" {
  type    = bool
  default = false
}

variable "db_instance_type" {
  type    = string
  default = "db.t2.small"
}

variable "db_multi_az" {
  default = true
}

variable "db_storage_type" {
  type    = string
  default = "gp2"
}

variable "db_performance_insights_enabled" {
  default = true
}

variable "db_iam_access_enabled" {
  default = false
}

variable "db_iam_db_user" {
  type = string
  default = "rds_user"
}

variable "db_ca_cert_url" {
  type = string
}

variable "db_ro_only_role" {
  type = string
  default = "otp_ro_role"
}

variable "db_rw_only_role" {
  type = string
  default = "otp_rw_role"
}

variable "db_ro_only_user" {
  type = string
  default = "otp_ro_user"
}

variable "db_rw_only_user" {
  type = string
  default = "otp_rw_user"
}

variable "db_ca_pem_file" {
  type = string
}


# network

variable "vpc_name" {
  description = "VPC NAME"
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

# product
variable "ooh_product" {
  default = "ooh-otp"
}

variable "environment" {
  description = "Deploy Environment"
  default     = "prod"
}

variable "office_ip" {
  description = "Deploy Environment"
  default     = "prod"
}

variable "bastion_ami" {
  description = "AMI to be used"
}

variable "bastion_instance" {
  description = "Type of Server to use"
  default     = "t2.nano"
}

variable "bastion_count" {
  description = "Number of Server to use"
}

variable "key_name" {
  description = "Key Pair Name"
}

variable "test_user" {
  description = "IAM User"
}
