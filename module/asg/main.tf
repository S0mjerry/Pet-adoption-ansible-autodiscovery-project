# Create Launch Template
resource "aws_launch_template" "stage-lt" {
  name_prefix            = var.stage-lt
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.vpc_security_group_ids]
  key_name               = var.key_name
  user_data              = base64encode(templatefile("${path.root}/module/asg/docker-script.sh", {
    nexus-server-ip      = var.nexus-server-ip,
    api_key              = var.api_key,
    account_id           = var.account_id
  }))
}
#Create Autoscaling Group
resource "aws_autoscaling_group" "stage-asg" {
    name                      =  var.stage-asg-name
    desired_capacity          =  2
    max_size                  =  4
    min_size                  =  1
    health_check_grace_period = 120
    health_check_type         = "EC2"
    force_delete              = true
    vpc_zone_identifier       = var.vpc-zone-identifier
    target_group_arns         = var.tg_arn_stage
      launch_template {
      id = aws_launch_template.stage-lt.id
      version = "$Latest"
    }
    tag {
      key                     = "Name"
      value                   = "stage-instance"
      propagate_at_launch     = true
    }
}

#Create ASG Policy
resource "aws_autoscaling_policy" "asg-policy" {
  name                   = var.stage-asg-policy
  adjustment_type        = "ChangeInCapacity"
  policy_type     = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.stage-asg.id
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  } 
}

# Create Launch Template
resource "aws_launch_template" "prod-lt" {
  name_prefix            = var.prod-lt
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.vpc_security_group_ids]
  key_name               = var.key_name
  user_data              = base64encode(templatefile("${path.root}/module/asg/docker-script.sh", {
    nexus-server-ip      = var.nexus-server-ip,
    api_key              = var.api_key,
    account_id           = var.account_id
  }))
}
#Create Autoscaling Group
resource "aws_autoscaling_group" "prod-asg" {
    name                      =  var.prod-asg-name
    desired_capacity          =  2
    max_size                  =  4
    min_size                  =  1
    health_check_grace_period = 120
    health_check_type         = "EC2"
    force_delete              = true
    vpc_zone_identifier       = var.vpc-zone-identifier
    target_group_arns = var.tg_arn_prod
      launch_template {
      id = aws_launch_template.prod-lt.id
      version = "$Latest"
    }
    tag {
      key                     = "Name"
      value                   = "prod-instance"
      propagate_at_launch     = true
    }
}

#Create ASG Policy
resource "aws_autoscaling_policy" "asg-policy2" {
  name                   = var.prod-asg-policy
  adjustment_type        = "ChangeInCapacity"
  policy_type     = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.prod-asg.id
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  } 
}