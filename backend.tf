terraform {
  # Temporarily commented out - will be enabled after creating state bucket
  # backend "s3" {
  #   bucket         = "my-terraform-state-bobby"
  #   region         = "us-east-1"
  #   key            = "s3-github-actions/terraform.tfstate"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      version = ">= 5.0.0"
      source  = "hashicorp/aws"
    }
  }
}