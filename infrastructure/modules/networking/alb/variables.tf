variable "alb_name" {
  description = "ALB name"
  type        = string
}

variable "subnet_ids" {
  description = "Target subnet IDs"
  type        = list(string)
}
