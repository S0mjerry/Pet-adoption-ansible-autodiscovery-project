output "ansible-server-ip" {
  value = aws_instance.ansible-server.public_ip
}