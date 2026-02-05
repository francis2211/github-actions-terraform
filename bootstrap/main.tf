# Bootstrap configuration to create S3 backend infrastructure
# This should be run once before enabling the backend in the main configuration

provider "aws" {
  region = "us-west-2"
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bobby"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "infrastructure"
    Purpose     = "Terraform remote state storage"
  }
}

# Enable versioning for state bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for state bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "infrastructure"
    Purpose     = "Terraform state locking"
  }
}

# Outputs
output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Name of the S3 bucket for Terraform state"
}

output "state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "ARN of the S3 bucket for Terraform state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "Name of the DynamoDB table for state locking"
}
