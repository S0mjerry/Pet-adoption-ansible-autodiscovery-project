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
output "stage-high-availability" {
  value = module.stage-high-availability.stage-alb-dns
}
output "prod-high-availability" {
  value = module.prod-high-availability.prod-lb-dns
}
output "jenkins-dns" {
  value = module.jenkins.jenkins-dns
}