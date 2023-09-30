output "vpc-id" {
  value = aws_vpc.vpc.id
}
output "key-name" {
  value = aws_key_pair.keypair.key_name
}
output "key-id" {
  value = aws_key_pair.keypair.id
}
output "public-subnet1" {
  value = aws_subnet.public-subnet-1.id
}
output "public-subnet2" {
  value = aws_subnet.public-subnet-2.id
}
output "private-subnet1" {
  value = aws_subnet.private-subnet-1.id
}
output "private-subnet2" {
  value = aws_subnet.private-subnet-2.id
}
output "baston-sg" {
  value = aws_security_group.bastion_Ansible_sg.id
}
output "jenkins-sg" {
  value = aws_security_group.jenkins_sg.id
}
output "ansible-sg" {
  value = aws_security_group.bastion_Ansible_sg.id
}
output "sonarqube-sg" {
  value = aws_security_group.sonarqube_sg.id
}
output "nexus-sg" {
  value = aws_security_group.nexus_sg.id
}
output "docker-sg" {
  value = aws_security_group.docker_sg.id
}
output "rds-sg" {
  value = aws_security_group.mysql_sg.id
}