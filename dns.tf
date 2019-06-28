/**
 * TODO: Use `for_each` instead of `count`.
 */

variable "domains" {
  type = map(object({
    dkim = object({
      public_key = string
    })

    dmarc = object({
      aggregate_reporting_uri = string
      forensic_reporting_uri  = string
    })

    google_site_verification = string
  }))
}

locals {
  # Convert `var.domains` into a list so that we can access it with numeric 
  # indices (i.e. `count.index`).
  domains = [for domain, params in var.domains : merge(params, { name = domain })]
}

resource "aws_route53_zone" "main" {
  name  = local.domains[count.index].name
  count = length(local.domains)
}

resource "aws_route53_record" "dkim" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = "google._domainkey"
  type    = "TXT"
  ttl     = 60 * 60
  records = [format("v=DKIM1; k=rsa; p=%s", local.domains[count.index].dkim.public_key)]
  count   = length(local.domains)
}

# TODO: Change `p=none` to `p=reject` (see https://support.google.com/a/answer/2466563).
# TODO: Tweak DMARC policy (see https://dmarcian.com/dmarc-inspector/ and https://blog.returnpath.com/demystifying-the-dmarc-record/).
resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 60 * 60
  records = [format("v=DMARC1; p=none; rua=%s; ruf=%s; fo=1", local.domains[count.index].dmarc.aggregate_reporting_uri, local.domains[count.index].dmarc.forensic_reporting_uri)]
  count   = length(local.domains)
}

resource "aws_route53_record" "google_site_verification" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = ""
  type    = "TXT"
  ttl     = 60 * 60 * 24
  records = [format("google-site-verification=%s", local.domains[count.index].google_site_verification)]
  count   = length(local.domains)
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

  count = length(local.domains)
}

# TODO: Change `~all` to `-all` (see https://www.bettercloud.com/monitor/spf-dkim-dmarc-email-security/).
resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = ""
  type    = "SPF"
  ttl     = 60 * 60
  records = ["v=spf1 include:_spf.google.com ~all"]
  count   = length(local.domains)
}
