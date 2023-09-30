#Creating bastion host server
resource "aws_instance" "bastion-host-server" {
  ami                         = var.ec2_ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_groups]
  user_data                   = local.bastion-host_user_data
  tags = {
    Name = var.tag-bastion-host
  }
}