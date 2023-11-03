#aws provider
provider "aws" {
  region  = var.aws_region
  profile = var.profile
}
#create aws keypair
resource "aws_key_pair" "vault" {
  key_name   = "keypair"
  public_key = file(var.public_keypair_path)
}
# Security Group for vault Server
resource "aws_security_group" "vault_sg" {
  name        = "vault"
  description = "Allow inbound traffic"
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port_vault"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "vault_sg"
  }
}

#vault instance
resource "aws_instance" "vault-server" {
  ami                         = var.ec2_ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.vault_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vault.key_name
  iam_instance_profile        = aws_iam_instance_profile.vault-kms-unseal2.id
  user_data                   = templatefile ("./vault-script.sh" , {
   domain_name = var.domain_name,
   email = var.email,
   aws_region = var.aws_region,
   kms_key = aws_kms_key.vault.id,
   api_key = var.api_key,
   account_id = var.account_id
  })
  tags = {
    name = "vault-server"
  }
}
#kms key for vault
resource "aws_kms_key" "vault" {
  description             = "vault unseal key"
  deletion_window_in_days = 10
  tags = {
    name = "kms-key-vault-server"
  }
}

# Route 53 hosted zone
data "aws_route53_zone" "route53_zone" {
  name         = var.domain_name
  private_zone = false
}

#Create route 53 A record
resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain_name
  type    = "A"
  records = [aws_instance.vault-server.public_ip]
  ttl = 300
}