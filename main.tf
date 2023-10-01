locals {
  name = "ET2PACAAD"
}

module "vpc" {
  source                 = "./module/vpc"
  vpc_cidr               = "10.0.0.0/16"
  tag-vpc                = "${local.name}-vpc"
  keypair                = "ET2PACAAD"
  public_keypair_path    = "~/keypair/ET2PACAAD.pub"
  tag-keypair            = "${local.name}-keypair"
  AZ1                    = "eu-west-3a"
  PSN1_cidr              = "10.0.1.0/24"
  tag-subnet-1           = "${local.name}-public-subnet-1"
  AZ2                    = "eu-west-3b"
  PSN2_cidr              = "10.0.2.0/24"
  tag-subnet-2           = "${local.name}-public-subnet-2"
  PrSN1_cidr             = "10.0.3.0/24"
  tag-private-subnet-1   = "${local.name}-private-subnet-1"
  PrSN2_cidr             = "10.0.4.0/24"
  tag-private-subnet-2   = "${local.name}-private-subnet-2"
  tag-igw                = "${local.name}-igw"
  tag-ngw                = "${local.name}-ngw"
  tag-public_rt          = "${local.name}-public_rt"
  all_cidr               = "0.0.0.0/0"
  tag-private_rt         = "${local.name}-private_rt"
  ssh_port               = "22"
  port_proxy             = "8080"
  http_port              = "80"
  https_port             = "443"
  tag-docker-sg          = "${local.name}-docker-sg"
  tag-jenkins-sg         = "${local.name}-jenkins-sg"
  tag-bastion_ansible-sg = "${local.name}-bastion_ansible-sg"
  port_nexus             = "8081"
  port_nexus2            = "8085"
  tag-nexus-sg           = "${local.name}-nexus-sg"
  mysql_port             = "3306"
  port_sonarqube         = "9000"
  tag-sonarqube-sg       = "${local.name}-sonarqube-sg"
  tag-mysql              = "${local.name}-mysql"
}

module "bastion-host" {
  source               = "./module/bastion-host"
  ec2_ami              = "ami-0d767e966f3458eb5"
  security_groups      = module.vpc.baston-sg
  instance_type        = "t2.medium"
  subnet_id            = module.vpc.public-subnet1
  key_name             = module.vpc.key-name
  tag-bastion-host     = "${local.name}-bastion-host"
  private_keypair_path = file("~/keypair/ET2PACAAD")
}

module "jenkins" {
  source          = "./module/jenkins"
  ec2_ami         = "ami-0d767e966f3458eb5"
  instance_type   = "t2.medium"
  subnet_id       = module.vpc.private-subnet1
  key_name        = module.vpc.key-name
  security_groups = module.vpc.jenkins-sg
  nexus-ip        = module.nexus.nexus-server-ip
  subnet-id       = [module.vpc.public-subnet1]
  jenkins-elb     = "${local.name}-jenkins-elb"
  tag-jenkins     = "${local.name}-jenkins"
}

module "ansible" {
  source             = "./module/ansible"
  ec2_ami            = "ami-0d767e966f3458eb5"
  instance_type      = "t2.medium"
  security_group_ids = module.vpc.ansible-sg
  subnet_id          = module.vpc.public-subnet1
  key_name           = module.vpc.key-name
  tag-ansible-server = "${local.name}-ansible-server"
  stage-playbook     = "${path.root}/module/ansible/stage-playbook.yml"
  prod-playbook      = "${path.root}/module/ansible/prod-playbook.yml"
  stage-bash-script  = "${path.root}/module/ansible/stage-bash-script.sh"
  prod-bash-script   = "${path.root}/module/ansible/prod-bash-script.sh"
  stage-trigger      = "${path.root}/module/ansible/stage-trigger.yml"
  prod-trigger       = "${path.root}/module/ansible/prod-trigger.yml"
  password           = "${path.root}/module/ansible/password.yml"
  private-key        = file("~/keypair/ET2PACAAD")
  nexus-server-ip    = module.nexus.nexus-server-ip
}

module "asg-stage" {
  source                 = "./module/asg-stage"
  stage-lt               = "${local.name}-stage-lt"
  image_id               = "ami-0d767e966f3458eb5"
  instance_type          = "t2.medium"
  vpc_security_group_ids = module.vpc.docker-sg
  key_name               = module.vpc.key-name
  nexus-server-ip        = module.nexus.nexus-server-ip
  api_key                = "NRAK-BG9JS0ABQS0C3VWQZNG2GYVYLSC"
  account_id             = "4092157"
  stage-asg-name         = "${local.name}-stage-asg"
  vpc-zone-identifier    = [module.vpc.private-subnet1, module.vpc.private-subnet2]
  tg_arn                 = [module.stage-high-availability.stage-target-arn]
  stage-asg-policy       = "${local.name}-asg-policy"
}

module "asg-prod" {
  source                 = "./module/asg-prod"
  prod-lt                = "${local.name}-prod-lt"
  image_id               = "ami-0d767e966f3458eb5"
  instance_type          = "t2.medium"
  vpc_security_group_ids = module.vpc.docker-sg
  key_name               = module.vpc.key-name
  nexus-server-ip        = module.nexus.nexus-server-ip
  api_key                = "NRAK-BG9JS0ABQS0C3VWQZNG2GYVYLSC"
  prod-asg-name          = "${local.name}-prod-asg"
  vpc-zone-identifier    = [module.vpc.private-subnet1, module.vpc.private-subnet2]
  tg_arn                 = [module.prod-high-availability.prod-target-arn]
  prod-asg-policy        = "${local.name}-asg-policy"
  account_id             = "4092157"
}

module "prod-high-availability" {
  source             = "./module/prod-high-availability"
  port_proxy         = "8080"
  vpc_id             = module.vpc.vpc-id
  security_group_ids = [module.vpc.docker-sg]
  subnets            = [module.vpc.private-subnet1, module.vpc.private-subnet2]
  tag-prod-alb       = "${local.name}-prod-alb"
  http_port          = "80"
  https_port         = "443"
  certificate_arn    = module.ssl.certificate_arn
}

module "stage-high-availability" {
  source             = "./module/stage-high-availability"
  port_proxy         = "8080"
  vpc_id             = module.vpc.vpc-id
  security_group_ids = [module.vpc.docker-sg]
  subnets            = [module.vpc.private-subnet1, module.vpc.private-subnet2]
  tag-stage-alb      = "${local.name}-stage-alb"
  http_port          = "80"
  https_port         = "443"
  certificate_arn    = module.ssl.certificate_arn

}

module "nexus" {
  source          = "./module/nexus"
  ec2_ami         = "ami-0d767e966f3458eb5"
  instance_type   = "t2.medium"
  subnet_id       = module.vpc.public-subnet2
  key_name        = module.vpc.key-name
  security_groups = module.vpc.nexus-sg
  tag-nexus       = "${local.name}-nexus"
}

module "sonarqube" {
  source               = "./module/sonarqube"
  ubuntu_ami           = "ami-05b5a865c3579bbc4"
  instance_type        = "t2.medium"
  security_group_ids   = module.vpc.sonarqube-sg
  subnet_id            = module.vpc.public-subnet1
  key_name             = module.vpc.key-name
  tag-sonarqube-server = "${local.name}-sonarqube-server"
}

module "RDS" {
  source                   = "./module/RDS"
  db_identifier            = "et2pacaad-db"
  security_groups          = module.vpc.rds-sg
  db-name                  = "ET2PACAAD_db"
  db-username              = "admin" #data.vault_generic_secret.db_secret.data["username"]
  db-password              = "admin123" #data.vault_generic_secret.db_secret.data["password"]
  subnet_ids               = [module.vpc.private-subnet1, module.vpc.private-subnet2]
  tag-db_subnet_group_name = "${local.name}-db-subnet-group"
}

module "route53" {
  source            = "./module/route53"
  domain-name       = "jerry-nwaogbogu.com"
  domain-name1      = "stage.jerry-nwaogbogu.com"
  stage_lb_dns_name = module.stage-high-availability.stage-alb-dns
  stage_lb_zoneid   = module.stage-high-availability.stage-alb-zone-id
  domain-name2      = "prod.jerry-nwaogbogu.com"
  prod_lb_dns_name  = module.prod-high-availability.prod-lb-dns
  prod_lb_zoneid    = module.prod-high-availability.prod-lb-zone-id
}

module "ssl" {
  source       = "./module/ssl"
  domain_name  = "jerry-nwaogbogu.com"
  domain_name2 = "*.jerry-nwaogbogu.com"
}