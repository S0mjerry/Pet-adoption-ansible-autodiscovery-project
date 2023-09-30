output "db_name" {
  value = aws_db_instance.mysql_database.db_name
} 
output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet.name
}