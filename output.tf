output "jenkins-ip" {
  value = module.jenkins.jenkins-server-ip
}
output "nexus-ip" {
  value = module.nexus.nexus-server-ip
}
output "ansible-ip" {
  value = module.ansible.ansible-server-ip
}
output "sonarqube-ip" {
  value = module.sonarqube.sonarqube-server-ip
}
output "bastion-ip" {
  value = module.bastion-host.bastion-host-ip
}
output "stage-alb" {
  value = module.alb.stage-alb-dns
}
output "prod-alb" {
  value = module.alb.prod-lb-dns
}
output "jenkins-dns" {
  value = module.jenkins.jenkins-dns
}