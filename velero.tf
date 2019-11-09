# TODO: Enable versioning and/or lifecycle rules.
# TODO: Enable server-side encryption.
resource "aws_s3_bucket" "velero" {
  bucket = "spence-velero"
}
