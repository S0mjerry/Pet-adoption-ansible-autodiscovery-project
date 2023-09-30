output "prod-asg-id" {
    value = aws_autoscaling_group.prod-asg.id
}

output "prod-asg-name" {
    value = aws_autoscaling_group.prod-asg.name
}

output "prod-lt-id" {
    value = aws_launch_template.prod-lt.image_id
}