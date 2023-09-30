# creating nexus server 
resource "aws_instance" "Nexus-server" {
  ami                         = var.ec2_ami
  vpc_security_group_ids      = [var.security_groups]
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  user_data                   = local.nexus_user_data
  tags = {
    name = var.tag-nexus
  }
}