# Terraform Backend Bootstrap

This directory contains the Terraform configuration to create the S3 bucket and DynamoDB table used for remote state storage.

## Purpose

The main Terraform configuration uses an S3 backend for storing state. However, that S3 bucket and DynamoDB table must exist before Terraform can use them. This bootstrap configuration creates those resources.

## Initial Setup

**Run this ONCE before using the main Terraform configuration:**

```bash
cd bootstrap

# Set AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"  # Optional

# Initialize Terraform (uses local state)
terraform init

# Review the plan
terraform plan

# Create the backend infrastructure
terraform apply
```

## What Gets Created

- **S3 Bucket:** `my-terraform-state-bobby`
  - Region: us-west-2
  - Versioning enabled
  - Encryption enabled (AES256)
  - Public access blocked

- **DynamoDB Table:** `terraform-state-lock`
  - Hash key: LockID
  - Pay-per-request billing
  - Server-side encryption enabled
  - Point-in-time recovery enabled

## After Bootstrap

Once these resources are created:

1. The main Terraform configuration (in the parent directory) can use the S3 backend
2. Run `terraform init` in the parent directory to migrate state to S3
3. The bootstrap directory state should be kept safe (it uses local state)

## Important Notes

- **Keep the bootstrap state file safe!** It's stored locally in this directory
- This only needs to be run once
- To destroy the backend infrastructure, run `terraform destroy` from this directory
- **Warning:** Destroying the backend will delete your Terraform state bucket!

## Cleanup

To remove the backend infrastructure (only do this if you're sure):

```bash
cd bootstrap
terraform destroy
```

**Note:** You should migrate your main Terraform state back to local storage before destroying the backend bucket.
