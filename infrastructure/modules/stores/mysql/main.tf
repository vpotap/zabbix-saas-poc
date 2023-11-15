terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_db_instance" "rds_mysql" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = var.instance_type
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password


  multi_az                = var.multi_az
  maintenance_window      = var.maintenance_window
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window

  skip_final_snapshot       = true
  deletion_protection       = var.environment == "prod"
}
