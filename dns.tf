variable "domains" {
  type = map(object({
    dkim = object({
      public_key = string
    })

    google_site_verification = object({
      key   = string
      value = string
    })
  }))
}

variable "primary_domain" {
  type = string
}

# TODO: Enable query logs (see https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/query-logs.html).
resource "aws_route53_zone" "main" {
  name     = each.key
  for_each = var.domains
}

resource "aws_route53_record" "dkim" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = "google._domainkey"
  type     = "TXT"
  ttl      = 60 * 60
  records  = [join("\"\"", [for chunk in chunklist(split("", format("v=DKIM1; k=rsa; p=%s", each.value.dkim.public_key)), 255): join("", chunk)])]
  for_each = var.domains
}

# TODO: Tweak DMARC policy (see https://dmarcian.com/dmarc-inspector/ and https://blog.returnpath.com/demystifying-the-dmarc-record/).
resource "aws_route53_record" "dmarc" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = "_dmarc"
  type     = "TXT"
  ttl      = 60 * 60
  records  = [format("v=DMARC1; p=none; rua=%s", gsuite_group.dmarc_reports.email)]
  for_each = var.domains
}

# TODO: Ideally the validation record would be pulled out of the GSuite API,
# see https://github.com/DeviaVir/terraform-provider-gsuite/issues/67.
resource "aws_route53_record" "google_site_verification" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = each.value.google_site_verification.key
  type     = "CNAME"
  ttl      = 24 * 60 * 60
  records  = [format("gv-%s.dv.googlehosted.com", each.value.google_site_verification.value)]
  for_each = var.domains
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.main[each.key].zone_id
  name    = ""
  type    = "MX"
  ttl     = 60 * 60

  records = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
  ]

  for_each = var.domains
}

# TODO: Change `~all` to `-all` (see https://www.bettercloud.com/monitor/spf-dkim-dmarc-email-security/).
resource "aws_route53_record" "spf" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = ""
  type     = "TXT"
  ttl      = 60 * 60
  records  = ["v=spf1 include:_spf.google.com ~all"]
  for_each = var.domains
}
