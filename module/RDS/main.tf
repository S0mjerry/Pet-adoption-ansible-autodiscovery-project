# Create Database
resource "aws_db_instance" "mysql_database" {
  identifier             = var.db_identifier
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [var.security_groups]
  multi_az               = true 
  allocated_storage      = 10
  db_name                = var.db-name
  engine                 = "mySQL"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.db-username
  password               = var.db-password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_type           = "gp2"
}

# Database Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.tag-db_subnet_group_name
  }
}