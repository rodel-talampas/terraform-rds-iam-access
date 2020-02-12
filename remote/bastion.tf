
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "grant_access" {
  template = file("sql/grant_access.sql")
  vars = {
    db_ro_only_role = var.db_ro_only_role
    db_rw_only_role = var.db_rw_only_role
  }
}

data "template_file" "install_commands" {
  template = file("install_script.sh")
  vars = {
    grant_access_template = data.template_file.grant_access.rendered
    db_host = aws_db_instance.otp_main.address
    db_port = aws_db_instance.otp_main.port
    db_user = var.db_admin
    db_name = aws_db_instance.otp_main.name
    db_password = random_password.password.result
    db_iam_db_user = var.db_iam_db_user
    db_ca_cert_url = var.db_ca_cert_url
    db_ca_pem_file = var.db_ca_pem_file
    db_ro_only_role = var.db_ro_only_role
    db_rw_only_role = var.db_rw_only_role
    db_ro_only_user = var.db_ro_only_user
    db_rw_only_user = var.db_rw_only_user
    secret_id = aws_secretsmanager_secret.postgres_secret.id
  }
}


resource "aws_instance" "bastion" {
  count = var.bastion_count

  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.db_ec2_aws_access_profile.id
  instance_type               = var.bastion_instance
  key_name                    = var.key_name
  subnet_id                   = element([aws_subnet.public_subnet_a.id,aws_subnet.public_subnet_b.id,aws_subnet.public_subnet_c.id], count.index)
  user_data                   = data.template_file.install_commands.rendered

  vpc_security_group_ids = [aws_security_group.office_ssh_sg.id,aws_security_group.internal_secgroup.id]

  tags = {
    Product     = var.ooh_product
    Environment = var.environment
    Name = "bastion-${var.ooh_product}-${var.environment}"
  }
}
