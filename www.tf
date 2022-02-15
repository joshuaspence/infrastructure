locals {
  github_pages_host = format("%s.github.io", data.github_user.current.login)
}

data "dns_a_record_set" "github_pages" {
  host = local.github_pages_host
}

data "dns_aaaa_record_set" "github_pages" {
  host = local.github_pages_host
}

resource "aws_route53_record" "apex_a" {
  zone_id = aws_route53_zone.main[var.primary_domain].zone_id
  name    = ""
  type    = "A"
  ttl     = 300
  records = data.dns_a_record_set.github_pages.addrs
}

resource "aws_route53_record" "apex_aaaa" {
  zone_id = aws_route53_zone.main[var.primary_domain].zone_id
  name    = ""
  type    = "AAAA"
  ttl     = 300
  records = data.dns_aaaa_record_set.github_pages.addrs
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main["joshuaspence.com"].zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 300
  records = [local.github_pages_host]
}
