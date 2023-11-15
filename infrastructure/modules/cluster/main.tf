terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


resource "aws_launch_configuration" "asg_config" {
  image_id        = var.ami
  instance_type   = var.instance_type
  
  iam_instance_profile = var.asg_profile
  security_groups = [aws_security_group.instance.id]
  user_data       = var.user_data

  # Using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
    # Check if aws free tier flag
    precondition {
      condition     = data.aws_ec2_instance_type.instance.free_tier_eligible
      error_message = "${var.instance_type} is not part of the AWS Free Tier!"
    }
  }
}


resource "aws_autoscaling_group" "demo" {

  name                 = var.cluster_name
  launch_configuration = aws_launch_configuration.asg_config.name

  vpc_zone_identifier  = var.subnet_ids

  # Configure integrations with a load balancer
  # ! use aws_autoscaling_attachment insteed directly set 
  #target_group_arns    = var.target_group_arns
  health_check_type    = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  # rolling ASG roll out 
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 30
    }
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  # dynamic "tag" {  }
  
  lifecycle {
    postcondition {
      condition     = length(self.availability_zones) > 1
      error_message = "use more than one AZ fo HA"
    }
  }
}


# Define autoscaling scale out/in logic
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.cluster_name}-scale-out"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  # TODO define in variables.tf as parameter
  recurrence             = "0 8 * * *"
  autoscaling_group_name = aws_autoscaling_group.demo.name
}


resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.cluster_name}-scale-in"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 22 * * *"
  autoscaling_group_name = aws_autoscaling_group.demo.name
}


resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 80
  unit                = "Percent"

  alarm_description   = "High CPU utilization, trigger scale-out policy"
  
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]

}


resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name  = "${var.cluster_name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"

  alarm_description   = "Low CPU credit balance, trigger scale-in policy"
  
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
}


resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.cluster_name}-scale-out-policy"
  scaling_adjustment    = 1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.demo.name
}


resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.cluster_name}-scale-in-policy"
  scaling_adjustment    = -1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.demo.name
}


data "aws_ec2_instance_type" "instance" {
  instance_type = var.instance_type
}

# Security group and rule for EC2 instances in ASG 
resource "aws_security_group" "ec2_instance_sg" {
  name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.ec2_instance_sg.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}


locals {
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}