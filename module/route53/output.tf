output "stage" {
  value = aws_route53_record.stage.id
}

output "prod" {
  value = aws_route53_record.prod.id
}

output "zone_id" {
  value = data.aws_route53_zone.route53_zone.zone_id
}

