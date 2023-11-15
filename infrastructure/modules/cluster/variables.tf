variable "cluster_name" {
  description = "The name to use for cluster"
  type        = string
}


variable "asg_profile" {
  description = "The name of custom role for ASG with assume and permissions"
  default     = ""
  type        = string
}

variable "ami" {
  description = "The AMI to use in the cluster"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances"
  type        = string

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Only free tier is allowed"
  }
}

variable "enable_autoscaling" {
  description = "If auto scaling enabled"
  type        = bool
}

variable "health_check_type" {
  description = "The type of health check to perform"
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "The health_check_type must be : EC2 | ELB."
  }
}


variable "user_data" {
  description = "The User Data script"
  type        = string
  default     = null
}


variable "subnet_ids" {
  description = "Target subnets IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "The ARNs of ELB"
  type        = list(string)
  default     = []
}

variable "min_size" {
  description = "The min EC2 inst. in the ASG"
  type        = number

  validation {
    condition     = var.min_size > 0
    error_message = "EC2 count > 0"
  }

  validation {
    condition     = var.min_size <= 10
    error_message = "EC2 count < 10"
  }
}


variable "max_size" {
  description = "The max EC2 inst. in the ASG"
  type        = number

  validation {
    condition     = var.max_size > 0
    error_message = "EC2 count should be > 0"
  }

  validation {
    condition     = var.max_size <= 10
    error_message = "EC2 count should be < 10"
  }
}

variable "server_port" {
  description = "The port for HTTP requests"
  type        = number
  default     = 8080
}
