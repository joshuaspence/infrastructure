variable "domains" {
  type = map(object({
    dkim = optional(object({
      public_key = string
    }))

    github_pages_verification = optional(object({
      value = string
    }))

    google_site_verification = optional(object({
      key   = string
      value = string
    }))
  }))
}

# TODO: Add validation.
variable "primary_domain" {
  type = string
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
  records  = [join("\"\"", [for chunk in chunklist(split("", format("v=DKIM1; k=rsa; p=%s", each.value.public_key)), 255) : join("", chunk)])]
  for_each = { for domain_name, domain in var.domains : domain_name => domain.dkim if domain.dkim != null }
}

# TODO: Tweak DMARC policy (see https://dmarcian.com/dmarc-inspector/ and https://blog.returnpath.com/demystifying-the-dmarc-record/).
resource "aws_route53_record" "dmarc" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = "_dmarc"
  type     = "TXT"
  ttl      = 60 * 60
  records  = [format("v=DMARC1; p=none; rua=%s", googleworkspace_group.dmarc_reports.email)]
  for_each = var.domains
}

resource "aws_route53_record" "github_pages_verification" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = format("_github-pages-challenge-%s", data.github_user.current.login)
  type     = "TXT"
  ttl      = 24 * 60 * 60
  records  = [each.value.value]
  for_each = { for domain_name, domain in var.domains : domain_name => domain.github_pages_verification if domain.github_pages_verification != null }
}

# TODO: Ideally the validation record would be pulled out of the GSuite API,
# see https://github.com/DeviaVir/terraform-provider-gsuite/issues/67.
resource "aws_route53_record" "google_site_verification" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = each.value.key
  type     = "CNAME"
  ttl      = 24 * 60 * 60
  records  = [format("gv-%s.dv.googlehosted.com", each.value.value)]
  for_each = { for domain_name, domain in var.domains : domain_name => domain.google_site_verification if domain.google_site_verification != null }
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

resource "aws_route53_record" "spf" {
  zone_id  = aws_route53_zone.main[each.key].zone_id
  name     = ""
  type     = "TXT"
  ttl      = 60 * 60
  records  = ["v=spf1 include:_spf.google.com -all"]
  for_each = var.domains
}

# TODO: Use IPv6 address for VPN.
resource "aws_route53_record" "vpn" {
  zone_id = aws_route53_zone.main["spence.network"].zone_id
  name    = "vpn"
  type    = "A"
  ttl     = 60 * 60
  records = [var.unifi_vpn.gateway]
}
