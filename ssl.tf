/**
 * TODO: We should use the `terraform-aws-modules/acm/aws` module but it
 * currently assumes that all domains belong to the same `aws_route53_zone`.
 * See https://github.com/terraform-aws-modules/terraform-aws-acm/issues/21.
 */

# TODO: Enable certificate transparency logging.
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
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
