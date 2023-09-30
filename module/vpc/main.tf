#Creating a VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.tag-vpc
  }
}

#Creating an EC2 keypair
resource "aws_key_pair" "keypair" {
  key_name   = var.keypair
  public_key = file(var.public_keypair_path)

  tags = {
    Name = var.tag-keypair
  }
}

#create 2 public subnet 
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ1
  cidr_block        = var.PSN1_cidr

  tags = {
    Name = var.tag-subnet-1
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ2
  cidr_block        = var.PSN2_cidr

  tags = {
    Name = var.tag-subnet-2
  }
}

#create 2 private subnet 
resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ1
  cidr_block        = var.PrSN1_cidr

  tags = {
    Name = var.tag-private-subnet-1
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ2
  cidr_block        = var.PrSN2_cidr

  tags = {
    Name = var.tag-private-subnet-2
  }
}

#Creating Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.tag-igw
  }
}

#Creating elastic ip
resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

#Creating nat gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = var.tag-ngw
  }
}

# creating a public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.tag-public_rt
  }
}

# attaching public subnet 1 to public route table
resource "aws_route_table_association" "public_rt_SN1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public_rt.id
}

# attaching public subnet 2 to public route table
resource "aws_route_table_association" "public_rt_SN2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public_rt.id
}

# creating a private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.all_cidr
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = var.tag-private_rt
  }
}

# attaching private subnet 1 to private route table
resource "aws_route_table_association" "private_rt_SN1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private_rt.id
}

# attaching private subnet 2 to private route table
resource "aws_route_table_association" "private_rt_SN2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Group for Docker Server
resource "aws_security_group" "docker_sg" {
  name        = "Docker"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "port_proxy"
    from_port   = var.port_proxy
    to_port     = var.port_proxy
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "HTTP access"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "HTTPS access"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.tag-docker-sg
  }
}
# Security Group for Jenkins Server
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "port_proxy"
    from_port   = var.port_proxy
    to_port     = var.port_proxy
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "HTTP access"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.tag-jenkins-sg
  }
}

# Security Group for bastion_ansible_host
resource "aws_security_group" "bastion_Ansible_sg" {
  name        = "bastion_Ansible"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.tag-bastion_ansible-sg
  }
}
# Security Group for Nexus Server
resource "aws_security_group" "nexus_sg" {
  name        = "nexus"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "Nexus access"
    from_port   = var.port_nexus
    to_port     = var.port_nexus
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "Nexus access"
    from_port   = var.port_nexus2
    to_port     = var.port_nexus2
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.tag-nexus-sg
  }
}

# Security Group for Sonarqube Server
resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "Sonarqube access"
    from_port   = var.port_sonarqube
    to_port     = var.port_sonarqube
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.tag-sonarqube-sg
  }
}
# Database Security Group
resource "aws_security_group" "mysql_sg" {
  name        = "mysql"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Database access"
    from_port   = var.mysql_port
    to_port     = var.mysql_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = var.tag-mysql
  }
}
