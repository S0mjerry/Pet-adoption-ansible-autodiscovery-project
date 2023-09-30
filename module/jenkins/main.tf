#Creating jenkins server
resource "aws_instance" "jenkins_server" {
  ami                         = var.ec2_ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_groups]
  user_data                   = local.jenkins_user_data
  tags = {
    Name = var.tag-jenkins
  }
}
#Create a new load balancer
resource "aws_elb" "lb" {
  name               = var.jenkins-elb
  subnets = var.subnet-id
  security_groups = [var.security_groups]
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 30
  }
  instances                   = [aws_instance.jenkins_server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Name = var.jenkins-elb
  }
}