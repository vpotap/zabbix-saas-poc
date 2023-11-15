output "address" {
  value       = aws_db_instance.rds_mysql.address
  description = "db endpoint"
}

output "port" {
  value       = aws_db_instance.rds_mysql.port
  description = "db port"
}
