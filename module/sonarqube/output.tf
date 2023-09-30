output "sonarqube-server-ip" {
  value = aws_instance.sonarqube_server.public_ip
}