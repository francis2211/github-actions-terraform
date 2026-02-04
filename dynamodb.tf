resource "aws_dynamodb_table" "terraform_lock" {
  name           = var.state_lock_table
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.state_lock_table
    Environment = var.environment
    Purpose     = "Terraform state locking"
  }
}
