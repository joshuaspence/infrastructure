variable "domains" {
  type = map(object({
    dkim = object({
      public_key = string
    })

    dmarc = object({
      aggregate_reporting_uri = string
    })

    google_site_verification = string
  }))
}

locals {
  # Convert `var.domains` into a list so that we can access it with numeric 
  # indices (i.e. `count.index`).
  #
  # TODO: Get rid of this.
  domains = [for domain, params in var.domains : merge(params, { name = domain })]

  primary_domain = local.domains[0].name
}

resource "aws_route53_zone" "main" {
  name     = each.key
  for_each = var.domains
}

resource "aws_route53_record" "dkim" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = "google._domainkey"
  type     = "TXT"
  ttl      = 60 * 60
  records  = [format("v=DKIM1; k=rsa; p=%s", each.value.dkim.public_key)]
  for_each = var.domains
}

# TODO: Change `p=none` to `p=reject` (see https://support.google.com/a/answer/2466563).
# TODO: Tweak DMARC policy (see https://dmarcian.com/dmarc-inspector/ and https://blog.returnpath.com/demystifying-the-dmarc-record/).
resource "aws_route53_record" "dmarc" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = "_dmarc"
  type     = "TXT"
  ttl      = 60 * 60
  records  = [format("v=DMARC1; p=quarantine; rua=%s", each.value.dmarc.aggregate_reporting_uri)]
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
    "10 aspmx2.googlemail.com.",
    "10 aspmx3.googlemail.com.",
  ]

  for_each = var.domains
}

# TODO: Change `~all` to `-all` (see https://www.bettercloud.com/monitor/spf-dkim-dmarc-email-security/).
resource "aws_route53_record" "spf" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = ""
  type     = "TXT"
  ttl      = 60 * 60
  records  = [
    "v=spf1 include:_spf.google.com ~all",

    # TODO: Does this record need to live at the apex?
    format("google-site-verification=%s", each.value.google_site_verification),
  ]
  for_each = var.domains
}
