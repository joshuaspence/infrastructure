# TODO: Enable versioning and/or lifecycle rules.
# TODO: Enable server-side encryption.
resource "aws_s3_bucket" "velero" {
  bucket = "spence-velero"
}

resource "aws_s3_bucket_policy" "velero" {
  bucket = aws_s3_bucket.velero.id
  policy = data.aws_iam_policy_document.velero.json
}

# TODO: Can these permissions be further restricted?
# TODO: Add conditions (e.g. `aws:SourceIp`).
data "aws_iam_policy_document" "velero" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.velero.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.velero.arn]
    }
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]

    resources = [format("%s/*", aws_s3_bucket.velero.arn)]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.velero.arn]
    }
  }
}

# TODO: Add a permissions boundary?
resource "aws_iam_user" "velero" {
  name = "velero"
  path = "/system/"
}
