# Create Ansible Server
resource "aws_instance" "ansible-server" {
  ami                         = var.ec2_ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.security_group_ids]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  user_data                   = local.ansible_user_data
  tags = {
    name = var.tag-ansible-server
  }
}