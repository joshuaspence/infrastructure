resource "aws_iam_user" "cert_manager" {
  name = "cert-manager"
  path = "/homelab/"
}

# See https://cert-manager.io/docs/configuration/acme/dns01/route53/#set-up-an-iam-role
data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]

    resources = formatlist("arn:aws:route53:::hostedzone/%s", [aws_route53_zone.main["spence.network"].zone_id])
  }
}

resource "aws_iam_user_policy" "cert_manager" {
  user   = aws_iam_user.cert_manager.name
  policy = data.aws_iam_policy_document.cert_manager.json
}

resource "aws_iam_access_key" "cert_manager" {
  user    = aws_iam_user.cert_manager.name
  pgp_key = "keybase:joshuaspence"
}

resource "aws_iam_user" "external_dns" {
  name = "external-dns"
  path = "/homelab/"
}

# See https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md.
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
    cert_manager = aws_iam_access_key.cert_manager
    external_dns = aws_iam_access_key.external_dns
  }
}

resource "random_string" "home_assistant_project_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "google_project" "home_assistant" {
  name       = "Home Assistant"
  project_id = "home-assistant-${random_string.home_assistant_project_suffix.result}"
  org_id     = data.google_organization.main.org_id
}
