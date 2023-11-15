variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = "example_database_stage"
}

variable "db_remote_state_bucket" {
  description = "S3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
}

variable "server_text" {
  description = "Text the web server should return"
  default     = ""
  type        = string
}

variable "environment" {
  description = "Env name"
  type        = string
  default     = "stage"
}


variable "ami" {
  description = "The AMI to use in the cluster"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of EC2 Instances"
  type        = string
  default     = "t2.micro"
}

variable "enable_autoscaling" {
  description = "If auto scaling enabled"
  type        = bool
  default     = true
}

variable "min_size" {
  description = "The min EC2 inst. in the ASG"
  type        = number
  default     = 1
 
}

variable "max_size" {
  description = "The max EC2 inst. in the ASG"
  type        = number
  default     = 10
}

variable "server_port" {
  description = "The port for HTTP requests"
  type        = number
  default     = 80
}
