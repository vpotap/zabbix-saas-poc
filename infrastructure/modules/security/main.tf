terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "asg_role" {
    name               = "assume_asg_role"
    assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


# TODO refactor this for not so general usage
data "aws_iam_policy_document" "asg_instance_access" {
  statement {
    actions  = [
        "logs:*",
        "s3:*",
        "dynamodb:*",
        "cloudwatch:*",
        "sns:*",
        "lambda:*",
        "connect:*",
        "secretsmanager:*",
        "ds:*",
        "ec2:*",
        "rds:*"
    ]
    effect   = "Allow"
    resources = ["*"]
  }
}


resource "aws_iam_policy" "asg_instance_access" {
  name        = "asg_instance_access"
  description = "Policy for ASG instance access"
  policy      = data.aws_iam_policy_document.asg_instance_access.json
}


resource "aws_iam_role_policy_attachment" "attach_asg_instance_access" {
  role       = aws_iam_role.asg_role.name
  policy_arn = aws_iam_policy.asg_instance_access.arn
}


resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.asg_role.name
}
