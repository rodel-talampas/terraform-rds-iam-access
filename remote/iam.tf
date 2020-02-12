resource "random_string" "role_id" {
  length = 5
  special = false
  lower = true
  upper = false
  number = false
}


resource "aws_iam_role" "db_ec2_access_role" {
  name = "db_ec2_access_role_${random_string.role_id.result}"
  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": ["ec2.amazonaws.com"]
    },
    "Action": ["sts:AssumeRole"]
  }]
}
DOC
}

data "aws_iam_policy_document" "db_ec2_aws_policy_document" {

  statement {
    actions   = ["iam:GetGroup"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions   = ["iam:GetSSHPublicKey", "iam:ListSSHPublicKeys"]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/*"]
  }

  statement {
    actions   = ["ec2:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions   = ["rds:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions   = ["secretsmanager:*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "db_ec2_user_policy_document" {
  statement {
    actions   = ["rds-db:connect"]
    effect    = "Allow"
    resources = ["arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.otp_main.resource_id}/${var.db_iam_db_user}"]
  }
}

resource "aws_iam_policy" "db_ec2_user_connect_policy" {
  name        = "db-ec2-user-connect-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  path        = "/"
  description = "Allow DB Access to EC2"
  policy      = data.aws_iam_policy_document.db_ec2_user_policy_document.json
}

resource "aws_iam_policy_attachment" "db_ec2_user_connect_policy_attachment" {
  name       = "db_ec2_user_connect_policy_attachment-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  roles      = [aws_iam_role.db_ec2_access_role.name]
  policy_arn = aws_iam_policy.db_ec2_user_connect_policy.arn
}

resource "aws_iam_policy" "db_ec2_aws_connect_policy" {
  name        = "db-ec2-aws-connect-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  path        = "/"
  description = "Allow DB Access to EC2"
  policy      = data.aws_iam_policy_document.db_ec2_aws_policy_document.json
}

resource "aws_iam_policy_attachment" "db_ec2_aws_connect_policy_attachment" {
  name       = "db_ec2_aws_connect_policy_attachment-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  roles      = [aws_iam_role.db_ec2_access_role.name]
  policy_arn = aws_iam_policy.db_ec2_aws_connect_policy.arn
}

resource "aws_iam_instance_profile" "db_ec2_aws_access_profile" {
  name = "db-ec2-aws-access-profile-${var.ooh_product}-${var.environment}"
  role = aws_iam_role.db_ec2_access_role.name
}

resource "aws_iam_role" "db_ro_ec2_access_role" {
  name = "db_ro_ec2_access_role_${random_string.role_id.result}"
  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": ["ec2.amazonaws.com"]
    },
    "Action": ["sts:AssumeRole"]
  }]
}
DOC
}

resource "aws_iam_role" "db_ro_user_access_role" {
  name = "db_ro_user_access_role_${random_string.role_id.result}"
  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    },
    "Action": ["sts:AssumeRole"]
  }]
}
DOC
}

data "aws_iam_policy_document" "db_ro_policy_document" {

  statement {
    actions   = ["rds-db:connect"]
    effect    = "Allow"
    resources = ["arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.otp_main.resource_id}/${var.db_ro_only_user}"]
  }

}

resource "aws_iam_policy" "db_ro_connect_policy" {
  name        = "db-ro-connect-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  path        = "/"
  description = "Allow DB Access to EC2"
  policy      = data.aws_iam_policy_document.db_ro_policy_document.json
}

resource "aws_iam_policy_attachment" "db_ro_connect_policy_attachment" {
  name       = "db_ro_connect_policy_attachment-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  roles      = [aws_iam_role.db_ro_user_access_role.name,aws_iam_role.db_ro_ec2_access_role.name]
  policy_arn = aws_iam_policy.db_ro_connect_policy.arn
}

resource "aws_iam_group" "db_ro_user_access_group" {
  name = "db_ro_user_access_group"
}

resource "aws_iam_group_policy" "db_ro_group_connect_policy" {
  name       = "db-ro-group-connect-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  policy     = data.aws_iam_policy_document.db_ro_policy_document.json
  group      = aws_iam_group.db_ro_user_access_group.name
}

resource "aws_iam_role" "db_rw_ec2_access_role" {
  name = "db_rw_ec2_access_role_${random_string.role_id.result}"
  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": ["ec2.amazonaws.com"]
    },
    "Action": ["sts:AssumeRole"]
  }]
}
DOC
}

resource "aws_iam_role" "db_rw_user_access_role" {
  name = "db_rw_user_access_role_${random_string.role_id.result}"
  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    },
    "Action": ["sts:AssumeRole"]
  }]
}
DOC
}

data "aws_iam_policy_document" "db_rw_policy_document" {

  statement {
    actions   = ["rds-db:connect"]
    effect    = "Allow"
    resources = ["arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.otp_main.resource_id}/${var.db_rw_only_user}"]
  }

}

resource "aws_iam_policy" "db_rw_connect_policy" {
  name        = "db-rw-connect-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  path        = "/"
  description = "Allow DB Access from IAM"
  policy      = data.aws_iam_policy_document.db_rw_policy_document.json
}

resource "aws_iam_policy_attachment" "db_rw_connect_policy_attachment" {
  name       = "db_rw_connect_policy_attachment-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  roles      = [aws_iam_role.db_rw_user_access_role.name,aws_iam_role.db_rw_ec2_access_role.name]
  policy_arn = aws_iam_policy.db_rw_connect_policy.arn
}
#
# resource "aws_iam_group" "db_rw_user_access_group" {
#   name = "db_rw_user_access_group"
# }
#
# resource "aws_iam_group_policy" "db_rw_group_connect_policy" {
#   name       = "db-rw-group-connect-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
#   policy     = data.aws_iam_policy_document.db_rw_policy_document.json
#   group      = aws_iam_group.db_rw_user_access_group.name
# }

resource "aws_iam_user_policy" "db_rw_iam_connect_policy" {
  name       = "db-rw-iam-connect-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  policy     = data.aws_iam_policy_document.db_rw_policy_document.json
  user       = var.test_user
}

resource "aws_iam_user_policy" "db_ro_iam_connect_policy" {
  name       = "db-ro-iam-connect-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
  policy     = data.aws_iam_policy_document.db_ro_policy_document.json
  user       = var.test_user
}

# resource "aws_iam_user_group_membership" "test_group_membership" {
#   user = var.test_user
#
#   groups = [
#     aws_iam_group.db_rw_user_access_group.name
#   ]
# }


# resource "aws_iam_role" "bastion_aws_access_role" {
#   name = "bastion_access_role_${random_string.role_id.result}"
#   assume_role_policy = <<DOC
# {
#   "Version": "2012-10-17",
#   "Statement": [{
#     "Effect": "Allow",
#     "Principal": {
#       "Service": ["ec2.amazonaws.com"]
#     },
#     "Action": ["sts:AssumeRole"]
#   }]
# }
# DOC
#
# }
#
# data "aws_iam_policy_document" "bastion_aws_policy_document" {
#   statement {
#     actions   = ["iam:GetGroup"]
#     effect    = "Allow"
#     resources = ["*"]
#   }
#
#   statement {
#     actions   = ["iam:GetSSHPublicKey", "iam:ListSSHPublicKeys"]
#     effect    = "Allow"
#     resources = ["arn:aws:iam::*:user/*"]
#   }
#
#   statement {
#     actions   = ["ec2:*"]
#     effect    = "Allow"
#     resources = ["*"]
#   }
#
#   statement {
#     actions   = ["rds:*"]
#     effect    = "Allow"
#     resources = ["*"]
#   }
#
#   statement {
#     actions   = ["secretsmanager:*"]
#     effect    = "Allow"
#     resources = ["*"]
#   }
# }
#
# resource "aws_iam_policy" "bastion_aws_policy" {
#   name        = "bastion-aws-policy-${var.ooh_product}-${var.environment}-${random_string.role_id.result}"
#   path        = "/"
#   description = "Allow fetching of IAM public keys"
#   policy      = data.aws_iam_policy_document.bastion_aws_policy_document.json
# }
#
# resource "aws_iam_policy_attachment" "ssh_keys_attach" {
#   name       = "ssh-public-keys-attachment"
#   roles      = [aws_iam_role.bastion_aws_access_role.name]
#   policy_arn = aws_iam_policy.bastion_aws_policy.arn
# }
#
# resource "aws_iam_instance_profile" "ssh_keys_profile" {
#   name = "bastion-server-${var.ooh_product}-${var.environment}"
#   role = aws_iam_role.bastion_aws_access_role.name
# }
