variable "velero_config" {
  type = object({
    bucket         = string
    plugin_version = string
    version        = string
  })
}

# TODO: Enable server-side encryption.
resource "aws_s3_bucket" "velero" {
  bucket = var.velero_config.bucket
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

resource "aws_iam_access_key" "velero" {
  user = aws_iam_user.velero.name
}

# TODO: Encrypt backups.
# TODO: Set `metrics.enabled` and `metrics.serviceMonitor.enabled`.
# TODO: Add schedules.
resource "helm_release" "velero" {
  name      = "velero"
  chart     = "stable/velero"
  namespace = "velero"

  set {
    name  = "image.tag"
    value = format("v%s", var.velero_config.version)
  }

  set {
    name  = "configuration.backupStorageLocation.name"
    value = "aws"
  }

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = aws_s3_bucket.velero.id
  }

  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = aws_s3_bucket.velero.region
  }

  set {
    name  = "configuration.provider"
    value = "aws"
  }

  set_sensitive {
    name  = "credentials.secretContents.cloud"
    value = format("[default]\naws_access_key_id=%s\naws_secret_access_key=%s", aws_iam_access_key.velero.id, aws_iam_access_key.velero.secret)
  }

  set {
    name  = "snapshotsEnabled"
    value = false
  }

  set {
    name  = "initContainers[0].name"
    value = "aws"
  }

  set {
    name  = "initContainers[0].image"
    value = format("velero/velero-plugin-for-aws:v%s", var.velero_config.plugin_version)
  }

  set {
    name  = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  }

  set {
    name  = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  }
}
