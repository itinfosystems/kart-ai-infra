terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region                   = var.region
  profile                  = var.aws_profile
}
