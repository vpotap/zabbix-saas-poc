variable "db_name" {
  description = "db name"
  type        = string
}

variable "db_username" {
  description = "db username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "db pass"
  type        = string
  sensitive   = true
}

# some optional settings

variable "instance_type" {
  description = "The type of EC2 Instances"
  type        = string
  default     =  "db.t2.micro"
}

variable "multi_az" {
  type        = bool
  description = "Set to true to deploy the RDS instance in multiple AZs."
  default     = false
}

variable "maintenance_window" {
  type        = string
  description = "The window to perform maintenance in"
  default     = "Mon:04:00-Mon:06:00"
}

variable "backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created if enabled."
  default     = "01:00-03:00"
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days."
  default     = 7
}

variable "environment" {
  type        = string
  description = "AWS Environment"
  default     = "stage" 
}
