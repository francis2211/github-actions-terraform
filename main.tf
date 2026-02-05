provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.example.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create a separate bucket for access logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_name}-logs"

  tags = {
    Name        = "${var.bucket_name}-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.log_bucket]

  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_ownership_controls" "log_bucket" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.example.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window

  tags = {
    Name        = "${var.bucket_name}-kms-key"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}