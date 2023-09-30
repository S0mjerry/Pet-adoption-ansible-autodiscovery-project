output "bastion-host-ip" {
  value = aws_instance.bastion-host-server.public_ip
}