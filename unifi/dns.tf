# Resolve public hostnames to LAN addresses internally (split-horizon DNS).
#
# These are needed when a host's public record is a CNAME rather than an A record. A client's `local_dns_record` only
# overrides `A` queries; every other type (`AAAA`, `HTTPS`, `TXT`, ...) is forwarded upstream and answered with the
# CNAME. Because a CNAME aliases the *whole* name rather than one record type, any resolver that follows it lands on the
# public address and discards the local override.
#
# Overriding the CNAME's target instead catches the alias wherever it is followed, which covers every record type at
# once.
resource "unifi_dns_record" "main" {
  for_each    = var.dns_records
  name        = each.key
  record_type = "A"
  value       = each.value
  ttl         = "60m"
}
