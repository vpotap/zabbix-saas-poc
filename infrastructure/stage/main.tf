
terraform {
  # Require any 1.x version of Terraform
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}



# use security module to define instance profile with role
module "security" {
   source = "../modules/security"
}


#data "aws_secretsmanager_secret_version" "mysql_password" {
#  secret_id = "your-secret-id"
#}

module "mysql" {
  source = "../modules/stores/mysql"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # if aws_secretsmanager_secret_version is used then
  # db_password = data.aws_secretsmanager_secret_version.mysql_password.secret_string
}


# use of ASG module 
# TODO: define lauch config as parameter for zero downtime deployment
module "asg" {
  source = "../modules/cluster"

  cluster_name  = "zabbix-saas-${var.environment}"

  # search last ami 
  ami           = data.aws_ami.zabbix_saas_ami.id
  # or use hardcoded one
  #ami           = var.ami
  instance_type = var.instance_type

  asg_profile   = module.security.asg_instance_profile 


  user_data     = templatefile("${path.module}/user-data.sh", {
    # ...
  })

  min_size           = var.min_size
  max_size           = var.max_size
  enable_autoscaling = var.enable_autoscaling

  subnet_ids        = data.aws_subnets.default.ids
  # join ASG with alb target group, replaced with aws_autoscaling_attachment
  # target_group_arns = [aws_lb_target_group.asg.arn] 
  health_check_type = "ELB"
  
}

# use alb module
module "alb" {
  source = "../modules/networking/alb"

  alb_name   = "zabbix-saas-${var.environment}"
  subnet_ids = data.aws_subnets.default.ids
}


resource "aws_lb_target_group" "asg" {
  name     = "zabbix-saas-${var.environment}"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}


resource "aws_autoscaling_attachment" "asg_attach_lb_tg" {
  autoscaling_group_name = module.asg.asg_name
  lb_target_group_arn    = aws_lb_target_group.asg.arn
}



data "aws_ami" "zabbix_saas_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["zabbix-saas-${var.environment}*"]
  }

  # define zabbix owner id from aws marketplace
  owners = ["123456789123"]
}

# TODO move this to network configuration module with default settings
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "eu-central-1"
  }
}