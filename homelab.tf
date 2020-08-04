resource "aws_iam_user" "cert_manager" {
  name = "cert-manager"
}

resource "aws_iam_access_key" "cert_manager" {
  user = aws_iam_user.cert_manager.name
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

    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    actions = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "cert_manager" {
  user   = aws_iam_user.cert_manager.name
  policy = data.aws_iam_policy_document.cert_manager.json
}

resource "aws_iam_user" "external_dns" {
  name = "external-dns"
}

resource "aws_iam_access_key" "external_dns" {
  user = aws_iam_user.external_dns.name
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]

    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    actions = ["route53:ListHostedZones"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "external_dns" {
  user   = aws_iam_user.external_dns.name
  policy = data.aws_iam_policy_document.external_dns.json
}
