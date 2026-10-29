resource "aws_route53_record" "github_pages_apex_ipv4" {
  zone_id = aws_route53_zone.main["spence.com.au"].zone_id
  name    = ""
  type    = "A"
  ttl     = 60 * 60

  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "github_pages_apex_ipv6" {
  zone_id = aws_route53_zone.main["spence.com.au"].zone_id
  name    = ""
  type    = "AAAA"
  ttl     = 60 * 60

  records = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153",
  ]
}

resource "aws_route53_record" "github_pages_www" {
  zone_id = aws_route53_zone.main["spence.com.au"].zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 60 * 60
  records = ["spence-com-au.github.io"]
}
