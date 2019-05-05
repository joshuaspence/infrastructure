/**
 * TODO: Use `for_each` instead of `count`.
 */

variable "domains" {
  type = map(object({
    dkim                     = string
    google_site_verification = string
  }))
}

locals {
  domain_count = length(var.domains)
  domain_names = keys(var.domains)
}

resource "aws_route53_zone" "main" {
  name = local.domain_names[count.index]

  count = local.domain_count
}

resource "aws_route53_record" "dkim" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = "google._domainkey"
  type    = "TXT"
  ttl     = 60 * 60
  records = ["v=DKIM1; k=rsa; p=${var.domains[local.domain_names[count.index]]["dkim"]}"]

  count = local.domain_count
}

resource "aws_route53_record" "google_site_verification" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = ""
  type    = "TXT"
  ttl     = 60 * 60 * 24
  records = ["google-site-verification=${var.domains[local.domain_names[count.index]]["google_site_verification"]}"]

  count = local.domain_count
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = ""
  type    = "MX"
  ttl     = 60 * 60

  records = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 aspmx2.googlemail.com.",
    "10 aspmx3.googlemail.com.",
  ]

  count = local.domain_count
}

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = ""
  type    = "SPF"
  ttl     = 60 * 60
  records = ["v=spf1 a include:_spf.google.com ~all"]

  count = local.domain_count
}
