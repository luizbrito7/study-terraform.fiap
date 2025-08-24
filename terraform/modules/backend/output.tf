output "bucket_name" {
  description = "Nome do bucket S3 criado para armazenar o Terraform State"
  value       = aws_s3_bucket.tfstate.bucket
}
