output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of alb"
}

output "alb_http_listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "The ARN of HTTP listener"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ALB SG id"
}