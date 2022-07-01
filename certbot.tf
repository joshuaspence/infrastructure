resource "aws_iam_user" "certbot" {
  name = "certbot"
}

data "aws_iam_policy_document" "certbot" {
  statement {
    actions = [
      "route53:GetChange",
      "route53:ListHostedZones",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]

    resources = formatlist("arn:aws:route53:::hostedzone/%s", [aws_route53_zone.main["spence.network"].zone_id])
  }
}

resource "aws_iam_user_policy" "certbot" {
  user   = aws_iam_user.certbot.name
  policy = data.aws_iam_policy_document.certbot.json
}

resource "aws_iam_access_key" "certbot" {
  user = aws_iam_user.certbot.name
}
