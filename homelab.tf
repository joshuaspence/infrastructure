resource "aws_iam_user" "external_dns" {
  name = "external-dns"
  path = "/homelab/"
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]

    resources = formatlist("arn:aws:route53:::hostedzone/%s", [aws_route53_zone.main["spence.network"].zone_id])
  }

  statement {
    actions   = ["route53:ListHostedZones"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "external_dns" {
  user   = aws_iam_user.external_dns.name
  policy = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_access_key" "external_dns" {
  user    = aws_iam_user.external_dns.name
  pgp_key = "keybase:joshuaspence"
}

output "aws_iam_access_key" {
  value = {
    external_dns = aws_iam_access_key.external_dns
  }
}
