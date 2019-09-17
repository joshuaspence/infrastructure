resource "aws_acm_certificate" "main" {
  domain_name               = var.primary_domain
  subject_alternative_names = [for domain in keys(var.domains) : domain if domain != var.primary_domain]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = each.value.resource_record_name
  type     = each.value.resource_record_type
  ttl      = 60
  records  = [each.value.resource_record_value]
  for_each = { for certificate in aws_acm_certificate.main.domain_validation_options : certificate.domain_name => certificate }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn

  # TODO: We shouldn't need `values(...)` here, see
  # https://github.com/hashicorp/terraform/issues/22476.
  validation_record_fqdns = values(aws_route53_record.acm_validation)[*].fqdn
}
