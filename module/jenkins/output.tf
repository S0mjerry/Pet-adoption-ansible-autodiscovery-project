output "jenkins-server-ip" {
  value = aws_instance.jenkins_server.private_ip
}
output "jenkins-dns" {
  value = aws_elb.lb.dns_name
}