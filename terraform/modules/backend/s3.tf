resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_tfstate

  lifecycle {
    prevent_destroy = true
  }
}
