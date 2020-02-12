# Create an RDS Postgres Instance
resource "aws_kms_key" "db_key" {
  description = "${var.ooh_product}-${var.environment}: RDS Encryption Key"
}

resource "aws_db_parameter_group" "db_parameter_group" {
  count  = var.db_engine == "postgres" ? 1 : 0
  name   = "${var.ooh_product}-${var.environment}-pg"
  family = "${var.db_engine}${var.db_engine_version}"

  parameter {
    name  = "log_min_duration_statement"
    value = "5000"
  }

  parameter {
    name  = "log_statement"
    value = "none"
  }
}

resource "aws_security_group" "db_secgroup" {
  name        = "${var.ooh_product}-${var.environment}-db-sg"
  description = "Traffic to/from RDS"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Product     = var.ooh_product
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "db_inbound" {
  type      = "ingress"
  from_port = var.db_port
  to_port   = var.db_port
  protocol  = "tcp"

  security_group_id        = aws_security_group.db_secgroup.id
  source_security_group_id = aws_security_group.db_secgroup.id
}

resource "aws_security_group_rule" "db_inbound_from_server" {
  type      = "ingress"
  from_port = var.db_port
  to_port   = var.db_port
  protocol  = "tcp"

  security_group_id        = aws_security_group.db_secgroup.id
  source_security_group_id = aws_security_group.internal_secgroup.id
}

resource "aws_security_group_rule" "db_outbound" {
  type      = "egress"
  from_port = var.db_port
  to_port   = var.db_port
  protocol  = "tcp"

  security_group_id        = aws_security_group.db_secgroup.id
  source_security_group_id = aws_security_group.db_secgroup.id
}

resource "aws_security_group_rule" "db_outbound_from_server" {
  type      = "egress"
  from_port = var.db_port
  to_port   = var.db_port
  protocol  = "tcp"

  security_group_id        = aws_security_group.db_secgroup.id
  source_security_group_id = aws_security_group.internal_secgroup.id
}

resource "random_string" "db_id" {
  length = 5
  special = false
  lower = true
  upper = false
  number = false
}

resource "aws_db_instance" "otp_main" {
  identifier                            = "${var.ooh_product}-${var.environment}-${random_string.db_id.result}-db"
  allocated_storage                     = var.db_size
  backup_retention_period               = var.db_backup_retention
  copy_tags_to_snapshot                 = true
  db_subnet_group_name                  = aws_db_subnet_group.db_subnets.name
  engine                                = var.db_engine
  engine_version                        = var.db_engine_version
  instance_class                        = var.db_instance_type
  kms_key_id                            = var.encrypted ? aws_kms_key.db_key.arn : ""
  multi_az                              = var.db_multi_az
  name                                  = var.db_name
  password                              = random_password.password.result
  storage_encrypted                     = var.encrypted
  username                              = var.db_admin
  license_model                         = var.db_license_model
  publicly_accessible                   = var.db_publicly_accessible
  parameter_group_name                  = aws_db_parameter_group.db_parameter_group[0].name
  final_snapshot_identifier             = "${var.ooh_product}-${var.environment}-${random_string.db_id.result}-final-snapshot"
  storage_type                          = var.db_storage_type
  iam_database_authentication_enabled   = var.db_iam_access_enabled

  performance_insights_enabled          = var.db_performance_insights_enabled
  performance_insights_retention_period = var.db_performance_insights_enabled ? 7 : 0
  performance_insights_kms_key_id       = var.db_performance_insights_enabled ? aws_kms_key.db_key.arn : ""

  vpc_security_group_ids = [aws_security_group.db_secgroup.id]
}
