/**
 * TODO: Use `for_each` instead of `count`.
 */

variable "domains" {
  type = map(object({
    dkim = string
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

# TODO: Change `p=none` to `p=reject` (see https://support.google.com/a/answer/2466563).
# TODO: Tweak DMARC policy (see https://dmarcian.com/dmarc-inspector/ and https://blog.returnpath.com/demystifying-the-dmarc-record/).
resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 60 * 60
  records = ["v=DMARC1; p=none; rua=mailto:josh+dmarc@joshuaspence.com; ruf=mailto:josh+dmarc@joshuaspence.com"]

  count = local.domain_count
}

resource "aws_route53_record" "google_site_verification" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = ""
  type    = "TXT"
  ttl     = 60 * 60 * 24
  records = ["google-site-verification=UsO1pcQY7tYt0o_pwtjUqIoKUkYCXSasOfSObBruaXM"]

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

# TODO: Change `~all` to `-all` (see https://www.bettercloud.com/monitor/spf-dkim-dmarc-email-security/).
resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = ""
  type    = "SPF"
  ttl     = 60 * 60
  records = ["v=spf1 include:_spf.google.com ~all"]

  count = local.domain_count
}
