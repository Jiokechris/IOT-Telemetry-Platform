provider "aws" {
  region = "us-east-1"
}

# 1. The S3 Bucket to hold the state file
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "iot-telemetry-tf-state-YOUR-UNIQUE-NAME" # <-- Change YOUR-UNIQUE-NAME
  force_destroy = true # Allows clean deletion later if needed
}

# Enable versioning so you can roll back your state map if it gets corrupted
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt the state file at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 2. The DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "iot-telemetry-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}