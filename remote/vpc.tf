resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = var.vpc_name
    Product = var.ooh_product
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_routes" {
  count = 3
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "Public routes #${count.index + 1}"
    Environment = var.environment
    Network     = "Public"
  }
}

resource "aws_route" "internet_route" {
  count = 3

  route_table_id         = element(aws_route_table.public_routes.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route_table_association" "public_route_association" {
  count = 3

  subnet_id      = element([aws_subnet.public_subnet_a.id,aws_subnet.public_subnet_b.id,aws_subnet.public_subnet_c.id], count.index)
  route_table_id = element(aws_route_table.public_routes.*.id, count.index)
}

resource "aws_subnet" "private_subnets" {
  count = 3
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(["${var.aws_region}a","${var.aws_region}b","${var.aws_region}c"], count.index)
  cidr_block        = cidrsubnet(var.vpc_cidr, 5, count.index + 1)

  tags = {
    Name    = "${var.ooh_product} private subnet #${count.index + 1}"
    Product = var.ooh_product
    Tier    = "Private"
  }
}

resource "aws_subnet" "rds_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.aws_region}a"
  cidr_block        = cidrsubnet(var.vpc_cidr, 5, 4)

  tags = {
    Name    = "${var.ooh_product} Private Subnet A"
    Product = var.ooh_product
    Tier    = "Private"
  }
}

resource "aws_subnet" "rds_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.aws_region}b"
  cidr_block        = cidrsubnet(var.vpc_cidr, 5, 5)

  tags = {
    Name    = "${var.ooh_product} Private Subnet B"
    Product = var.ooh_product
    Tier    = "Private"
  }
}

resource "aws_subnet" "rds_subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.aws_region}c"
  cidr_block        = cidrsubnet(var.vpc_cidr, 5, 6)

  tags = {
    Name    = "${var.ooh_product} Private Subnet C"
    Product = var.ooh_product
    Tier    = "Private"
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.ooh_product}-${var.environment}-rds-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet_a.id,aws_subnet.rds_subnet_b.id,aws_subnet.rds_subnet_c.id]

  tags = {
    Product     = var.ooh_product
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 5, 11)
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name    = "${var.ooh_product} Public Subnet A"
    Product = var.ooh_product
    Tier    = "Public"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 5, 12)
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"

  tags = {
    Name    = "${var.ooh_product} Public Subnet B"
    Product = var.ooh_product
    Tier    = "Public"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 5, 13)
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}c"

  tags = {
    Name    = "${var.ooh_product} Public Subnet C"
    Product = var.ooh_product
    Tier    = "Public"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Product = var.ooh_product
  }
}

resource "aws_security_group_rule" "default_allow_all_local" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [var.vpc_cidr]

  security_group_id = aws_default_security_group.default.id
}

resource "aws_security_group_rule" "default_can_talk_locally" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [var.vpc_cidr]

  security_group_id = aws_default_security_group.default.id
}

resource "aws_security_group_rule" "default_can_talk_to_the_world" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_default_security_group.default.id
}

resource "aws_security_group" "office_ssh_sg" {
  name        = "${var.ooh_product}-${var.environment}-bastion-sg"
  description = "Traffic to/from Bastion Box"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [var.office_ip]
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [var.office_ip]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Product     = var.ooh_product
    Environment = var.environment
  }
}

resource "aws_security_group" "internal_secgroup" {
  name        = "${var.ooh_product}-${var.environment}-internal-sg"
  description = "Traffic to/from internal servers"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Product     = var.ooh_product
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "internal_access" {
  type      = "ingress"
  from_port   = 0
  to_port     = 0
  protocol  = "tcp"

  security_group_id        = aws_security_group.internal_secgroup.id
  source_security_group_id = aws_security_group.internal_secgroup.id
}

resource "aws_security_group_rule" "external_access" {
  type      = "egress"
  from_port   = 0
  to_port     = 0
  protocol  = "tcp"

  security_group_id        = aws_security_group.internal_secgroup.id
  source_security_group_id = aws_security_group.internal_secgroup.id
}
