# Route 53 hosted zone
data "aws_route53_zone" "route53_zone" {
  name         = var.domain-name
  private_zone = false
}

#Create route 53 A record for stage
resource "aws_route53_record" "stage" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain-name1
  type    = "A"
  alias {
    name                   = var.stage_lb_dns_name
    zone_id                = var.stage_lb_zoneid
    evaluate_target_health = false
  }
}

#Create route 53 A record for prod
resource "aws_route53_record" "prod" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain-name2
  type    = "A"
  alias {
    name                   = var.prod_lb_dns_name
    zone_id                = var.prod_lb_zoneid
    evaluate_target_health = false
  }
}