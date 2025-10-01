terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket  = "terraform-desafio-devops"
    key     = "php_tfstate/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}