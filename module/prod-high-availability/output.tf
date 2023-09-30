output "prod-target-arn" {
  value = aws_lb_target_group.target-group.arn
}

output "prod-lb-dns" {
  value = aws_lb.alb-prod.dns_name
}

output "prod_lb_arn" {
  value = aws_lb.alb-prod.arn
}

output "prod-lb-zone-id" {
  value = aws_lb.alb-prod.zone_id
}