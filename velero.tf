# TODO: Enable versioning and/or lifecycle rules.
# TODO: Enable server-side encryption.
resource "aws_s3_bucket" "velero" {
  bucket = "spence-velero"
}

# TODO: Add a permissions boundary?
resource "aws_iam_user" "velero" {
  name = "velero"
  path = "/system/"
}
