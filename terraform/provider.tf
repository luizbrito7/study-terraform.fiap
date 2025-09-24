# PROVIDER
terraform {

  required_version = "~> 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9.0"
    }
  }

  backend "s3" {
    bucket       = "bucket-tfstate-5737483"
    key          = "tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}