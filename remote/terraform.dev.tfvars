# remote account
aws_region = "ap-southeast-1"
encrypted   = false
# database
db_admin = "otp_admin"
db_name  = "otp_poc"
db_port  = "5432"
db_multi_az = false
db_iam_access_enabled = true
db_iam_db_user = "iam_rds_user"
db_ca_cert_url = "https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem"
db_ca_pem_file = "rds-combined-ca-bundle.pem"

# network
vpc_cidr = "10.0.0.0/16"
vpc_name = "Ooh VPC"

# product
ooh_product = "ooh-poc"
environment = "dev"

# default access
office_ip = "59.100.250.18/32"

# Bastion
bastion_ami = "ami-0267ddfb946ea55b9"
bastion_instance = "t2.micro"
bastion_count = 1

key_name = "ooh-rodel-key"



test_user = "rodel.talampas"
