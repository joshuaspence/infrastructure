resource "aws_acm_certificate" "main" {
  domain_name               = local.domains[0].name
  subject_alternative_names = slice(local.domains[*].name, 1, length(local.domains))
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = aws_acm_certificate.main.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.main.domain_validation_options[count.index].resource_record_type
  ttl     = 60
  records = [aws_acm_certificate.main.domain_validation_options[count.index].resource_record_value]
  count   = length(local.domains)
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = aws_route53_record.acm_validation[*].fqdn
}
