data "aws_route53_zone" "zone" {
  zone_id = var.hosted_zone
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name = "ckan.nstephenson-ckan-dev.link"
  type = "A"

  alias {
    evaluate_target_health = true
    name                   = "${aws_alb.application-load-balancer.dns_name}"
    zone_id                = "${aws_alb.application-load-balancer.zone_id}"
  }
}

/*
resource "aws_route53_record" "zone_apex" {
  name = ""
  type = "TXT"
  records = ["hello"]
  zone_id = data.aws_route53_zone.zone.zone_id
  ttl = 300
}


resource "aws_route53_record" "ckan_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  #zone_id         = data.aws_route53_zone.zone.zone_id
  zone_id = "/hostedzone/${var.hosted_zone}"
}
*/

resource "aws_route53_record" "rds_cname" {
  name = "db"
  type = "CNAME"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_db_instance.database.endpoint}"]
  ttl = 300
}